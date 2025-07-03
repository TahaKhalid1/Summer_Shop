using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Next_ae.User
{
    public partial class OrderConfirmation : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["CustomerId"] == null)
                {
                    Response.Redirect("Login.aspx");
                    return;
                }

                if (Session["LastOrderId"] == null)
                {
                    Response.Redirect("Products.aspx");
                    return;
                }

                int orderId = Convert.ToInt32(Session["LastOrderId"]);
                LoadOrderDetails(orderId);

                // Clear the session after use
                Session.Remove("LastOrderId");
            }
        }

        private void LoadOrderDetails(int orderId)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                // Get order details
                SqlCommand cmd = new SqlCommand(@"SELECT 
            o.OrderID, 
            o.OrderDate, 
            o.TotalAmount, 
            o.Status,
            CASE 
                WHEN p.PaymentMethod IS NOT NULL THEN p.PaymentMethod
                ELSE 'Cash on Delivery'
            END AS PaymentMethod,
            sa.FullName AS ShippingName,
            sa.AddressLine1 AS ShippingAddress1,
            sa.AddressLine2 AS ShippingAddress2,
            sa.City AS ShippingCity,
            sa.State AS ShippingState,
            sa.PostalCode AS ShippingPostalCode,
            sa.Country AS ShippingCountry,
            u.Email
            FROM Orders o 
            LEFT JOIN Payment p ON o.OrderID = p.OrderID
            INNER JOIN ShippingAddress sa ON o.ShippingID = sa.ShippingID 
            INNER JOIN Customer u ON o.CustomerID = u.CustomerID 
            WHERE o.OrderID = @OrderID", con);
                cmd.Parameters.AddWithValue("@OrderID", orderId);

                con.Open();
                SqlDataReader reader = cmd.ExecuteReader();

                if (reader.Read())
                {
                    ltOrderNumber.Text = "#" + reader["OrderID"].ToString();
                    ltOrderDate.Text = Convert.ToDateTime(reader["OrderDate"]).ToString("MMMM dd, yyyy");
                    ltPaymentMethod.Text = reader["PaymentMethod"].ToString();
                    ltOrderTotal.Text = "Rs. " + Convert.ToDecimal(reader["TotalAmount"]).ToString("0.00");
                    ltEmail.Text = reader["Email"].ToString();

                    // Calculate estimated delivery date (3-5 business days) in C# instead of SQL
                    DateTime orderDate = Convert.ToDateTime(reader["OrderDate"]);
                    Random rnd = new Random();
                    int deliveryDays = 3 + rnd.Next(0, 3); // Random number between 3-5
                    ltDeliveryDate.Text = orderDate.AddDays(deliveryDays).ToString("MMMM dd, yyyy");
                }
                reader.Close();
            }
        }
    }
}