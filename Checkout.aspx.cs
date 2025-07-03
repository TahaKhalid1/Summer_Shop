

















using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Next_ae.User
{
    public partial class Checkout : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

        public class PlaceOrderResponse
        {
            public bool success { get; set; }
            public string message { get; set; }
            public string redirectUrl { get; set; }
        }

        public class OrderData
        {
            public string email { get; set; }
            public string paymentMethod { get; set; }
            public ShippingAddress newShippingAddress { get; set; }
            public bool sameAsBilling { get; set; }
            public BillingAddress newBillingAddress { get; set; }
            public string subtotal { get; set; }
            public string shipping { get; set; }
            public string total { get; set; }
        }

        public class ShippingAddress
        {
            public string fullName { get; set; }
            public string address1 { get; set; }
            public string address2 { get; set; }
            public string city { get; set; }
            public string state { get; set; }
            public string postalCode { get; set; }
            public string country { get; set; }
            public string phone { get; set; }
        }

        public class BillingAddress
        {
            public string fullName { get; set; }
            public string address1 { get; set; }
            public string address2 { get; set; }
            public string city { get; set; }
            public string state { get; set; }
            public string postalCode { get; set; }
            public string country { get; set; }
            public string phone { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["CustomerId"] == null)
                {
                    Session["ReturnUrl"] = "~/User/Checkout.aspx";
                    Response.Redirect($"~/User/Login.aspx?ReturnUrl={Server.UrlEncode(Request.Url.PathAndQuery)}");
                    return;
                }

                LoadOrderSummary();
                LoadCustomerInfo();
            }
        }

        [WebMethod]
        public static PlaceOrderResponse PlaceOrder(OrderData orderData)
        {
            try
            {
                var context = HttpContext.Current;
                if (context.Session["CustomerId"] == null)
                {
                    return new PlaceOrderResponse
                    {
                        success = false,
                        message = "not_logged_in",
                        redirectUrl = "Login.aspx?ReturnUrl=Checkout.aspx"
                    };
                }

                decimal subtotal = 0, shipping = 0, total = 0;

                if (orderData.subtotal.StartsWith("Rs."))
                    orderData.subtotal = orderData.subtotal.Replace("Rs.", "").Trim();

                if (orderData.shipping.StartsWith("Rs."))
                    orderData.shipping = orderData.shipping.Replace("Rs.", "").Trim();

                if (orderData.total.StartsWith("Rs."))
                    orderData.total = orderData.total.Replace("Rs.", "").Trim();

                if (!decimal.TryParse(orderData.subtotal, NumberStyles.Number, CultureInfo.InvariantCulture, out subtotal))
                    subtotal = 0;

                if (!decimal.TryParse(orderData.shipping, NumberStyles.Number, CultureInfo.InvariantCulture, out shipping))
                    shipping = 0;

                if (!decimal.TryParse(orderData.total, NumberStyles.Number, CultureInfo.InvariantCulture, out total))
                    total = subtotal + shipping;

                // Validate shipping address
                if (orderData.newShippingAddress == null)
                {
                    return new PlaceOrderResponse
                    {
                        success = false,
                        message = "Shipping address is required"
                    };
                }

                // Validate billing address if different from shipping
                if (!orderData.sameAsBilling && orderData.newBillingAddress == null)
                {
                    return new PlaceOrderResponse
                    {
                        success = false,
                        message = "Billing address is required"
                    };
                }

                int userId = Convert.ToInt32(context.Session["CustomerId"]);
                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

                int orderId = CreateOrder(orderData, userId, connectionString);

                if (orderId > 0)
                {
                    context.Session["LastOrderId"] = orderId;

                    return new PlaceOrderResponse
                    {
                        success = true,
                        redirectUrl = "OrderConfirmation.aspx"
                    };
                }

                return new PlaceOrderResponse
                {
                    success = false,
                    message = "Failed to create order"
                };
            }
            catch (Exception ex)
            {
                return new PlaceOrderResponse
                {
                    success = false,
                    message = "Error: " + ex.Message
                };
            }
        }

        private static int CreateOrder(OrderData orderData, int userId, string connectionString)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                using (SqlTransaction transaction = con.BeginTransaction(IsolationLevel.Serializable))
                {
                    try
                    {
                        // 1. Create shipping address first
                        int shippingId = SaveNewAddress(con, transaction, orderData.newShippingAddress, userId, true);
                        if (shippingId == 0)
                            throw new Exception("Failed to create shipping address");

                        // 2. Create billing address (either new or same as shipping)
                        int billingId;
                        if (orderData.sameAsBilling)
                        {
                            // Create a copy in billing address table
                            billingId = CopyAddressToBilling(con, transaction, shippingId, userId);
                            if (billingId == 0)
                                throw new Exception("Failed to create billing address copy");
                        }
                        else
                        {
                            // Create separate billing address
                            billingId = SaveNewAddress(con, transaction, orderData.newBillingAddress, userId, false);
                            if (billingId == 0)
                                throw new Exception("Failed to create billing address");
                        }

                        // Verify both addresses exist before proceeding
                        if (!AddressExists(con, transaction, shippingId, true) ||
                            !AddressExists(con, transaction, billingId, false))
                        {
                            throw new Exception("Address verification failed");
                        }

                        // Parse amounts
                        decimal subtotal = 0, shipping = 0, total = 0;

                        if (!decimal.TryParse(orderData.subtotal, NumberStyles.Currency, CultureInfo.InvariantCulture, out subtotal))
                            subtotal = 0;

                        if (!decimal.TryParse(orderData.shipping, NumberStyles.Currency, CultureInfo.InvariantCulture, out shipping))
                            shipping = 0;

                        if (!decimal.TryParse(orderData.total, NumberStyles.Currency, CultureInfo.InvariantCulture, out total))
                            total = subtotal + shipping;

                        // Create order record
                        int orderId = CreateOrderRecord(con, transaction, userId, billingId, shippingId, total, "Processing");
                        if (orderId <= 0)
                            throw new Exception("Failed to create order record");

                        // Add order items
                        if (AddOrderItems(con, transaction, orderId, userId) == 0)
                            throw new Exception("No items added to order");

                        // Clear cart
                        ClearCart(con, transaction, userId);

                        transaction.Commit();
                        return orderId;
                    }
                    catch (Exception ex)
                    {
                        transaction.Rollback();
                        throw new Exception("Error creating order: " + ex.Message);
                    }
                }
            }
        }

        private static int CopyAddressToBilling(SqlConnection con, SqlTransaction transaction, int shippingId, int userId)
        {
            // Get shipping address details first
            var shippingAddr = GetAddressDetails(con, transaction, shippingId, true);
            if (shippingAddr == null) return 0;

            // Insert into billing address table
            SqlCommand cmd = new SqlCommand(@"
        INSERT INTO BillingAddress 
        (CustomerID, FullName, AddressLine1, AddressLine2, City, 
         State, PostalCode, Country, Phone, IsDefault) 
        VALUES 
        (@CustomerID, @FullName, @AddressLine1, @AddressLine2, @City, 
         @State, @PostalCode, @Country, @Phone, 0);
        SELECT SCOPE_IDENTITY();",
                con, transaction);

            cmd.Parameters.AddWithValue("@CustomerID", userId);
            cmd.Parameters.AddWithValue("@FullName", shippingAddr.FullName);
            cmd.Parameters.AddWithValue("@AddressLine1", shippingAddr.AddressLine1);
            cmd.Parameters.AddWithValue("@AddressLine2", shippingAddr.AddressLine2 ?? "");
            cmd.Parameters.AddWithValue("@City", shippingAddr.City);
            cmd.Parameters.AddWithValue("@State", shippingAddr.State);
            cmd.Parameters.AddWithValue("@PostalCode", shippingAddr.PostalCode);
            cmd.Parameters.AddWithValue("@Country", shippingAddr.Country);
            cmd.Parameters.AddWithValue("@Phone", shippingAddr.Phone);

            return Convert.ToInt32(cmd.ExecuteScalar());
        }


        private static AddressDetails GetAddressDetails(SqlConnection con, SqlTransaction transaction, int addressId, bool isShipping)
        {
            string table = isShipping ? "ShippingAddress" : "BillingAddress";
            string idColumn = isShipping ? "ShippingID" : "BillingID";

            SqlCommand cmd = new SqlCommand($@"
        SELECT FullName, AddressLine1, AddressLine2, City, 
               State, PostalCode, Country, Phone 
        FROM {table} 
        WHERE {idColumn} = @AddressId",
                con, transaction);
            cmd.Parameters.AddWithValue("@AddressId", addressId);

            using (SqlDataReader reader = cmd.ExecuteReader())
            {
                if (reader.Read())
                {
                    return new AddressDetails
                    {
                        FullName = reader["FullName"].ToString(),
                        AddressLine1 = reader["AddressLine1"].ToString(),
                        AddressLine2 = reader["AddressLine2"].ToString(),
                        City = reader["City"].ToString(),
                        State = reader["State"].ToString(),
                        PostalCode = reader["PostalCode"].ToString(),
                        Country = reader["Country"].ToString(),
                        Phone = reader["Phone"].ToString()
                    };
                }
            }
            return null;
        }

        private static bool AddressExists(SqlConnection con, SqlTransaction transaction, int addressId, bool isShipping)
        {
            string tableName = isShipping ? "ShippingAddress" : "BillingAddress";
            string idColumn = isShipping ? "ShippingID" : "BillingID";

            SqlCommand cmd = new SqlCommand(
                $"SELECT COUNT(1) FROM {tableName} WHERE {idColumn} = @AddressId",
                con, transaction);
            cmd.Parameters.AddWithValue("@AddressId", addressId);

            return Convert.ToInt32(cmd.ExecuteScalar()) > 0;
        }

        private class AddressDetails
        {
            public string FullName { get; set; }
            public string AddressLine1 { get; set; }
            public string AddressLine2 { get; set; }
            public string City { get; set; }
            public string State { get; set; }
            public string PostalCode { get; set; }
            public string Country { get; set; }
            public string Phone { get; set; }
        }

        private static int SaveNewAddress(SqlConnection con, SqlTransaction transaction,
                                        object address, int userId, bool isShipping)
        {
            string tableName = isShipping ? "ShippingAddress" : "BillingAddress";
            dynamic addr = address;

            SqlCommand cmd = new SqlCommand($@"
                INSERT INTO {tableName} 
                (CustomerID, FullName, AddressLine1, AddressLine2, City, 
                 State, PostalCode, Country, Phone, IsDefault) 
                VALUES 
                (@CustomerID, @FullName, @AddressLine1, @AddressLine2, @City, 
                 @State, @PostalCode, @Country, @Phone, 0);
                SELECT SCOPE_IDENTITY();",
                con, transaction);

            cmd.Parameters.AddWithValue("@CustomerID", userId);
            cmd.Parameters.AddWithValue("@FullName", addr.fullName ?? "");
            cmd.Parameters.AddWithValue("@AddressLine1", addr.address1 ?? "");
            cmd.Parameters.AddWithValue("@AddressLine2", addr.address2 ?? "");
            cmd.Parameters.AddWithValue("@City", addr.city ?? "");
            cmd.Parameters.AddWithValue("@State", addr.state ?? "");
            cmd.Parameters.AddWithValue("@PostalCode", addr.postalCode ?? "");
            cmd.Parameters.AddWithValue("@Country", addr.country ?? "");
            cmd.Parameters.AddWithValue("@Phone", addr.phone ?? "");

            return Convert.ToInt32(cmd.ExecuteScalar());
        }

        private static int CreateOrderRecord(SqlConnection con, SqlTransaction transaction,
                                          int userId, int billingId, int shippingId,
                                          decimal total, string status)
        {
            SqlCommand cmd = new SqlCommand(@"INSERT INTO Orders 
                (CustomerID, BillingID, ShippingID, OrderDate, TotalAmount, Status) 
                VALUES (@CustomerID, @BillingID, @ShippingID, @OrderDate, @TotalAmount, @Status);
                SELECT SCOPE_IDENTITY();", con, transaction);

            cmd.Parameters.AddWithValue("@CustomerID", userId);
            cmd.Parameters.AddWithValue("@BillingID", billingId);
            cmd.Parameters.AddWithValue("@ShippingID", shippingId);
            cmd.Parameters.AddWithValue("@OrderDate", DateTime.Now);
            cmd.Parameters.AddWithValue("@TotalAmount", total);
            cmd.Parameters.AddWithValue("@Status", status);

            object result = cmd.ExecuteScalar();
            return result == null || result == DBNull.Value ? 0 : Convert.ToInt32(result);
        }

        private static int AddOrderItems(SqlConnection con, SqlTransaction transaction, int orderId, int userId)
        {
            SqlCommand cmd = new SqlCommand(@"INSERT INTO OrderDetails 
                (OrderID, ProductID, ProductName, ProductImageUrl, Quantity, UnitPrice) 
                SELECT @OrderID, ci.ProductID, p.ProductName, 
                (SELECT TOP 1 ImageUrl FROM ProductImage WHERE ProductID = p.ProductID), 
                ci.Quantity, ci.Price 
                FROM CartItems ci 
                INNER JOIN Product p ON ci.ProductID = p.ProductID 
                INNER JOIN Cart c ON ci.CartID = c.CartID 
                WHERE c.CustomerID = @CustomerID AND c.IsActive = 1", con, transaction);

            cmd.Parameters.AddWithValue("@OrderID", orderId);
            cmd.Parameters.AddWithValue("@CustomerID", userId);

            return cmd.ExecuteNonQuery();
        }

        private static void ClearCart(SqlConnection con, SqlTransaction transaction, int userId)
        {
            SqlCommand cmd = new SqlCommand(
                "UPDATE Cart SET IsActive = 0 WHERE CustomerID = @CustomerID AND IsActive = 1",
                con, transaction);
            cmd.Parameters.AddWithValue("@CustomerID", userId);
            cmd.ExecuteNonQuery();
        }

        private void LoadOrderSummary()
        {
            int userId = Convert.ToInt32(Session["CustomerId"]);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                SqlCommand cmd = new SqlCommand(@"SELECT ci.CartItemID, p.ProductName, 
                    (SELECT TOP 1 ImageUrl FROM ProductImage WHERE ProductID = p.ProductID) AS ProductImage, 
                    ci.Price, ci.Quantity, (ci.Price * ci.Quantity) AS TotalPrice 
                    FROM CartItems ci 
                    INNER JOIN Product p ON ci.ProductID = p.ProductID 
                    INNER JOIN Cart c ON ci.CartID = c.CartID 
                    WHERE c.CustomerID = @CustomerID AND c.IsActive = 1", con);
                cmd.Parameters.AddWithValue("@CustomerID", userId);

                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                sda.Fill(dt);

                rptOrderItems.DataSource = dt;
                rptOrderItems.DataBind();

                decimal subtotal = dt.AsEnumerable().Sum(row => Convert.ToDecimal(row["TotalPrice"]));
                decimal shipping = subtotal > 100 ? 0 : 15;
                decimal total = subtotal + shipping;

                hfSubtotal.Value = subtotal.ToString(CultureInfo.InvariantCulture);
                hfShipping.Value = shipping.ToString(CultureInfo.InvariantCulture);
                hfTotal.Value = total.ToString(CultureInfo.InvariantCulture);

                ltSubtotal.Text = "Rs. " + subtotal.ToString("0.00");
                ltShipping.Text = "Rs. " + shipping.ToString("0.00");
                ltTotal.Text = "Rs. " + total.ToString("0.00");
            }
        }

        private void LoadCustomerInfo()
        {
            if (Session["Email"] != null)
            {
                txtEmail.Text = Session["Email"].ToString();
            }
        }

        protected void cbSameAsShipping_CheckedChanged(object sender, EventArgs e)
        {
            pnlBillingAddress.Visible = !cbSameAsShipping.Checked;
        }
    }
}