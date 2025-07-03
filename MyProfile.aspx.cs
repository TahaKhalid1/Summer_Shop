using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.Security;

namespace Next_ae.User
{
    public partial class Profile : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["CustomerID"] == null)
                {
                    Response.Redirect("~/User/Login.aspx?ReturnUrl=" + Server.UrlEncode(Request.Url.PathAndQuery));
                    return;
                }

                LoadCustomerProfile();
                LoadOrderStatistics();
            }
        }

        private void LoadCustomerProfile()
        {
            int customerId = Convert.ToInt32(Session["CustomerID"]);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                SqlCommand cmd = new SqlCommand(
                    @"SELECT FirstName, LastName, Email, Phone, CreatedAt 
                      FROM Customer 
                      WHERE CustomerID = @CustomerID", con);
                cmd.Parameters.AddWithValue("@CustomerID", customerId);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        txtFirstName.Text = reader["FirstName"].ToString();
                        txtLastName.Text = reader["LastName"].ToString();
                        txtEmail.Text = reader["Email"].ToString();
                        txtPhone.Text = reader["Phone"].ToString();
                        litMemberSince.Text = Convert.ToDateTime(reader["CreatedAt"]).ToString("MMMM dd, yyyy");

                        // Set avatar initials
                        string initials = reader["FirstName"].ToString().Substring(0, 1).ToUpper();
                        if (!string.IsNullOrEmpty(reader["LastName"].ToString()))
                        {
                            initials += reader["LastName"].ToString().Substring(0, 1).ToUpper();
                        }
                        avatarInitials.InnerText = initials;
                    }
                }
            }
        }

        private void LoadOrderStatistics()
        {
            int customerId = Convert.ToInt32(Session["CustomerID"]);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                // Total orders
                SqlCommand totalCmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Orders WHERE CustomerID = @CustomerID", con);
                totalCmd.Parameters.AddWithValue("@CustomerID", customerId);
                litTotalOrders.Text = totalCmd.ExecuteScalar().ToString();

                // Completed orders
                SqlCommand completedCmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Orders WHERE CustomerID = @CustomerID AND Status = 'Delivered'", con);
                completedCmd.Parameters.AddWithValue("@CustomerID", customerId);
                litCompletedOrders.Text = completedCmd.ExecuteScalar().ToString();

                // Pending orders
                SqlCommand pendingCmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Orders WHERE CustomerID = @CustomerID AND Status IN ('Processing', 'Shipped')", con);
                pendingCmd.Parameters.AddWithValue("@CustomerID", customerId);
                litPendingOrders.Text = pendingCmd.ExecuteScalar().ToString();

                // Last order date
                SqlCommand lastOrderCmd = new SqlCommand(
                    "SELECT TOP 1 OrderDate FROM Orders WHERE CustomerID = @CustomerID ORDER BY OrderDate DESC", con);
                lastOrderCmd.Parameters.AddWithValue("@CustomerID", customerId);
                object lastOrderDate = lastOrderCmd.ExecuteScalar();
                litLastOrderDate.Text = lastOrderDate != null ? Convert.ToDateTime(lastOrderDate).ToString("MMMM dd, yyyy") : "N/A";

                // Total spent
                SqlCommand totalSpentCmd = new SqlCommand(
                    "SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders WHERE CustomerID = @CustomerID AND Status = 'Delivered'", con);
                totalSpentCmd.Parameters.AddWithValue("@CustomerID", customerId);
                litTotalSpent.Text = Convert.ToDecimal(totalSpentCmd.ExecuteScalar()).ToString("0.00");
            }
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            if (Session["CustomerID"] == null)
            {
                Response.Redirect("~/User/Login.aspx");
                return;
            }

            int customerId = Convert.ToInt32(Session["CustomerID"]);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                // First verify the current password if changing password
                if (!string.IsNullOrEmpty(txtCurrentPassword.Text))
                {
                    if (string.IsNullOrEmpty(txtNewPassword.Text) || string.IsNullOrEmpty(txtConfirmPassword.Text))
                    {
                        Response.Redirect("Profile.aspx?error=Please+enter+both+new+password+and+confirmation");
                        return;
                    }

                    if (txtNewPassword.Text != txtConfirmPassword.Text)
                    {
                        Response.Redirect("Profile.aspx?error=New+passwords+do+not+match");
                        return;
                    }

                    // Verify current password
                    SqlCommand verifyCmd = new SqlCommand(
                        "SELECT PasswordHash, Salt FROM Customer WHERE CustomerID = @CustomerID", con);
                    verifyCmd.Parameters.AddWithValue("@CustomerID", customerId);

                    using (SqlDataReader reader = verifyCmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            string storedHash = reader["PasswordHash"].ToString();
                            string salt = reader["Salt"].ToString();

                            // Hash the entered current password with the stored salt
                            string enteredHash = FormsAuthentication.HashPasswordForStoringInConfigFile(txtCurrentPassword.Text + salt, "SHA1");

                            if (enteredHash != storedHash)
                            {
                                Response.Redirect("Profile.aspx?error=Current+password+is+incorrect");
                                return;
                            }
                        }
                    }
                }

                // Update profile information
                SqlCommand cmd = new SqlCommand(
                    @"UPDATE Customer 
                      SET FirstName = @FirstName, 
                          LastName = @LastName, 
                          Email = @Email, 
                          Phone = @Phone
                      WHERE CustomerID = @CustomerID", con);

                cmd.Parameters.AddWithValue("@FirstName", txtFirstName.Text.Trim());
                cmd.Parameters.AddWithValue("@LastName", txtLastName.Text.Trim());
                cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                cmd.Parameters.AddWithValue("@Phone", txtPhone.Text.Trim());
                cmd.Parameters.AddWithValue("@CustomerID", customerId);

                cmd.ExecuteNonQuery();

                // Update password if provided
                if (!string.IsNullOrEmpty(txtNewPassword.Text))
                {
                    // Generate new salt
                    string newSalt = Guid.NewGuid().ToString("N").Substring(0, 16);
                    string newHash = FormsAuthentication.HashPasswordForStoringInConfigFile(txtNewPassword.Text + newSalt, "SHA1");

                    // Update password
                    SqlCommand updatePwdCmd = new SqlCommand(
                        "UPDATE Customer SET PasswordHash = @PasswordHash, Salt = @Salt WHERE CustomerID = @CustomerID", con);
                    updatePwdCmd.Parameters.AddWithValue("@PasswordHash", newHash);
                    updatePwdCmd.Parameters.AddWithValue("@Salt", newSalt);
                    updatePwdCmd.Parameters.AddWithValue("@CustomerID", customerId);
                    updatePwdCmd.ExecuteNonQuery();
                }

                Response.Redirect("Profile.aspx?success=Profile+updated+successfully");
            }
        }
    }
}