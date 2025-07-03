using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.Security;
using System.Web.UI.WebControls;
using Next_ae.Models;

namespace Next_ae.User
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (User.Identity.IsAuthenticated)
                {
                    Response.Redirect("Home.aspx");
                }

                // Get return URL from query string
                string returnUrl = Request.QueryString["ReturnUrl"];

                // If no ReturnUrl in query string, try to get it from FormsAuthentication
                if (string.IsNullOrEmpty(returnUrl))
                {
                    returnUrl = FormsAuthentication.GetRedirectUrl("", false);
                }

                // If still no return URL, use the referrer (but only if it's from our site)
                if (string.IsNullOrEmpty(returnUrl) && Request.UrlReferrer != null &&
                    Request.UrlReferrer.Host == Request.Url.Host)
                {
                    returnUrl = Request.UrlReferrer.PathAndQuery;
                }

                // Special case for Shop page
                if (Request.UrlReferrer != null &&
                    Request.UrlReferrer.AbsolutePath.ToLower().Contains("shop.aspx"))
                {
                    returnUrl = "Shop.aspx";
                }

                // Store in session
                if (!string.IsNullOrEmpty(returnUrl))
                {
                    Session["ReturnUrl"] = returnUrl;
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    string email = txtLoginEmail.Text.Trim();
                    string password = txtLoginPassword.Text;

                    if (AuthenticateUser(email, password))
                    {
                        Customer customer = GetCustomerByEmail(email);

                        if (customer != null && customer.IsActive)
                        {
                            // Create authentication ticket
                            FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(
                                1,
                                email,
                                DateTime.Now,
                                DateTime.Now.AddMinutes(30),
                                false,
                                customer.CustomerID.ToString()
                            );

                            string encryptedTicket = FormsAuthentication.Encrypt(ticket);
                            HttpCookie authCookie = new HttpCookie(FormsAuthentication.FormsCookieName, encryptedTicket);
                            Response.Cookies.Add(authCookie);

                            // Store customer details in session
                            Session["CustomerID"] = customer.CustomerID;
                            Session["CustomerName"] = $"{customer.FirstName} {customer.LastName}";
                            Session["Email"] = customer.Email;

                            // Check for active cart/session
                            if (this.Master is UserMaster masterPage)
                            {
                                masterPage.UpdateLoginStatus();
                            }
                            CheckActiveCart(customer.CustomerID);

                            // Redirect to appropriate page
                            string returnUrl = Request.QueryString["ReturnUrl"];

                            // If no ReturnUrl, default to Home.aspx
                            if (string.IsNullOrEmpty(returnUrl))
                            {
                                returnUrl = "Home.aspx";
                            }

                            // Security check - ensure URL is local
                            if (IsLocalUrl(returnUrl))
                            {
                                Response.Redirect(returnUrl);
                            }
                            else
                            {
                                Response.Redirect("Home.aspx");
                            }
                        }
                        else
                        {
                            lblLoginError.Text = "Your account is not active. Please contact support.";
                            lblLoginError.Visible = true;
                        }
                    }
                    else
                    {
                        lblLoginError.Text = "Invalid email or password. Please try again.";
                        lblLoginError.Visible = true;
                    }
                
                }
                catch (Exception ex)
                {
                    lblLoginError.Text = "An error occurred during login. Please try again.";
                    lblLoginError.Visible = true;

#if DEBUG
                    lblLoginError.Text += $" Error: {ex.Message}";
#endif
                }
            }
        }
        private bool IsLocalUrl(string url)
        {
            if (string.IsNullOrEmpty(url))
            {
                return false;
            }

            // Check for relative URLs
            if (url.StartsWith("/") && !url.StartsWith("//") && !url.StartsWith("/\\"))
            {
                return true;
            }

            // Check for absolute URLs that match your domain
            try
            {
                Uri absoluteUri;
                if (Uri.TryCreate(url, UriKind.Absolute, out absoluteUri))
                {
                    return string.Equals(Request.Url.Host, absoluteUri.Host,
                                      StringComparison.OrdinalIgnoreCase);
                }
            }
            catch
            {
                // If URL parsing fails, assume it's not local
            }

            return false;
        }
        protected void btnSignUp_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    string firstName = txtFirstName.Text.Trim();
                    string lastName = txtLastName.Text.Trim();
                    string email = txtEmail.Text.Trim();
                    string password = txtPassword.Text;
                    string phone = txtPhone.Text.Trim();
                    

                 

                    if (!IsEmailAvailable(email))
                    {
                        lblSignUpError.Text = "This email is already registered. Please use a different email.";
                        lblSignUpError.Visible = true;
                        return;
                    }

                    int newCustomerId = RegisterCustomer(firstName, lastName, email, password, phone);
                    if (newCustomerId > 0)
                    {
                        Customer customer = GetCustomerById(newCustomerId);
                        if (customer != null)
                        {
                            // Create authentication ticket
                            FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(
                                1,
                                email,
                                DateTime.Now,
                                DateTime.Now.AddMinutes(30),
                                false,
                                customer.CustomerID.ToString()
                            );

                            string encryptedTicket = FormsAuthentication.Encrypt(ticket);
                            HttpCookie authCookie = new HttpCookie(FormsAuthentication.FormsCookieName, encryptedTicket);
                            Response.Cookies.Add(authCookie);

                            // Store customer details in session
                            Session["CustomerID"] = customer.CustomerID;
                            Session["CustomerName"] = $"{customer.FirstName} {customer.LastName}";
                            Session["Email"] = customer.Email;

                            Response.Redirect("Home.aspx");
                        }
                        else
                        {
                            lblSignUpError.Text = "Registration successful but failed to retrieve your account. Please try logging in.";
                            lblSignUpError.Visible = true;
                        }
                    }
                    else
                    {
                        lblSignUpError.Text = "Registration failed. Please try again.";
                        lblSignUpError.Visible = true;
                    }
                }
                catch (Exception ex)
                {
                    lblSignUpError.Text = "An error occurred during registration. Please try again.";
                    lblSignUpError.Visible = true;

#if DEBUG
                    lblSignUpError.Text += $" Error: {ex.Message}";
#endif
                }
            }
        }

        private bool AuthenticateUser(string email, string password)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT PasswordHash, Salt FROM Customer WHERE Email = @Email AND IsActive = 1";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Email", email);

                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        string storedHash = reader["PasswordHash"].ToString();
                        string salt = reader["Salt"].ToString();
                        string computedHash = HashPassword(password, salt);
                        return storedHash == computedHash;
                    }
                }
                return false;
            }
        }

        private Customer GetCustomerByEmail(string email)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"SELECT CustomerID, FirstName, LastName, Email, Phone, IsActive 
                                FROM Customer 
                                WHERE Email = @Email";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Email", email);

                con.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    return new Customer
                    {
                        CustomerID = Convert.ToInt32(reader["CustomerID"]),
                        FirstName = reader["FirstName"].ToString(),
                        LastName = reader["LastName"].ToString(),
                        Email = reader["Email"].ToString(),
                        Phone = reader["Phone"].ToString(),
                        IsActive = Convert.ToBoolean(reader["IsActive"])
                    };
                }
                return null;
            }
        }

        private Customer GetCustomerById(int customerId)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"SELECT CustomerID, FirstName, LastName, Email, Phone, IsActive 
                                FROM Customer 
                                WHERE CustomerID = @CustomerID";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@CustomerID", customerId);

                con.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    return new Customer
                    {
                        CustomerID = Convert.ToInt32(reader["CustomerID"]),
                        FirstName = reader["FirstName"].ToString(),
                        LastName = reader["LastName"].ToString(),
                        Email = reader["Email"].ToString(),
                        Phone = reader["Phone"].ToString(),
                        IsActive = Convert.ToBoolean(reader["IsActive"])
                    };
                }
                return null;
            }
        }

        private bool IsEmailAvailable(string email)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT COUNT(*) FROM Customer WHERE Email = @Email";
                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@Email", email);

                con.Open();
                int count = (int)cmd.ExecuteScalar();

                return count == 0;
            }
        }

        private int RegisterCustomer(string firstName, string lastName, string email, string password, string phone)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            string salt = GenerateSalt();
            string passwordHash = HashPassword(password, salt);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();
                SqlTransaction transaction = con.BeginTransaction();

                try
                {
                    string query = @"INSERT INTO Customer 
                                    (FirstName, LastName, Email, PasswordHash, Salt, Phone,  IsActive, CreatedAt)
                                    VALUES 
                                    (@FirstName, @LastName, @Email, @PasswordHash, @Salt, @Phone,   1, @CreatedAt);
                                    SELECT SCOPE_IDENTITY();";

                    SqlCommand cmd = new SqlCommand(query, con, transaction);
                    cmd.Parameters.AddWithValue("@FirstName", firstName);
                    cmd.Parameters.AddWithValue("@LastName", lastName);
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@PasswordHash", passwordHash);
                    cmd.Parameters.AddWithValue("@Salt", salt);
                    cmd.Parameters.AddWithValue("@Phone", phone);
                    
                    cmd.Parameters.AddWithValue("@CreatedAt", DateTime.Now);

                    int customerId = Convert.ToInt32(cmd.ExecuteScalar());
                    transaction.Commit();

                    return customerId;
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }
        }

        private string GenerateSalt()
        {
            // Generate a random salt
            byte[] saltBytes = new byte[16];
            using (var rng = System.Security.Cryptography.RandomNumberGenerator.Create())
            {
                rng.GetBytes(saltBytes);
            }
            return Convert.ToBase64String(saltBytes);
        }

        private string HashPassword(string password, string salt)
        {
            // Use PBKDF2 for password hashing
            using (var pbkdf2 = new System.Security.Cryptography.Rfc2898DeriveBytes(
                password,
                System.Text.Encoding.UTF8.GetBytes(salt),
                10000,
                System.Security.Cryptography.HashAlgorithmName.SHA256))
            {
                byte[] hash = pbkdf2.GetBytes(32); // 32 bytes = 256 bits
                return Convert.ToBase64String(hash);
            }
        }

        private void CheckActiveCart(int customerId)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string sessionQuery = @"SELECT TOP 1 SessionID, CartID 
                                      FROM CheckoutSession 
                                      WHERE CustomerID = @CustomerID AND Status = 'Active' 
                                      ORDER BY CreatedAt DESC";

                SqlCommand sessionCmd = new SqlCommand(sessionQuery, con);
                sessionCmd.Parameters.AddWithValue("@CustomerID", customerId);

                con.Open();
                SqlDataReader sessionReader = sessionCmd.ExecuteReader();

                if (sessionReader.Read())
                {
                    Session["CurrentSessionID"] = sessionReader["SessionID"].ToString();
                    Session["CurrentCartID"] = sessionReader["CartID"].ToString();
                }
            }
        }
    }
}