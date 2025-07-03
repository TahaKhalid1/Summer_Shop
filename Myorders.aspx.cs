using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Next_ae.User
{
    public partial class MyOrders : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
        public int CurrentPage { get; set; } = 1;
        public int PageSize { get; set; } = 5;
        public int TotalOrders { get; set; }
        public int TotalPages { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["CustomerId"] == null)
                {
                    Response.Redirect($"~/User/Login.aspx?ReturnUrl={Server.UrlEncode(Request.Url.PathAndQuery)}");
                    return;
                }

                // Check for page number in query string
                if (!string.IsNullOrEmpty(Request.QueryString["page"]))
                {
                    int.TryParse(Request.QueryString["page"], out int page);
                    if (page > 0) CurrentPage = page;
                }

                LoadOrders();
            }
        }

        private void LoadOrders()
        {
            int userId = Convert.ToInt32(Session["CustomerId"]);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                // Get total count of orders for pagination
                SqlCommand countCmd = new SqlCommand(
                    "SELECT COUNT(*) FROM Orders WHERE CustomerID = @CustomerID", con);
                countCmd.Parameters.AddWithValue("@CustomerID", userId);
                TotalOrders = Convert.ToInt32(countCmd.ExecuteScalar());
                TotalPages = (int)Math.Ceiling((double)TotalOrders / PageSize);

                // Get orders with pagination
                SqlCommand cmd = new SqlCommand(
                    @"SELECT o.OrderID, o.OrderDate, o.TotalAmount, o.Status 
                      FROM Orders o 
                      WHERE o.CustomerID = @CustomerID
                      ORDER BY o.OrderDate DESC
                      OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY", con);

                cmd.Parameters.AddWithValue("@CustomerID", userId);
                cmd.Parameters.AddWithValue("@Offset", (CurrentPage - 1) * PageSize);
                cmd.Parameters.AddWithValue("@PageSize", PageSize);

                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                sda.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptOrders.DataSource = dt;
                    rptOrders.DataBind();
                    pnlEmptyOrders.Visible = false;
                    SetupPagination();
                }
                else
                {
                    pnlOrders.Visible = false;
                    pnlEmptyOrders.Visible = true;
                }
            }
        }

        protected void rptOrders_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                int orderId = Convert.ToInt32(row["OrderID"]);

                Repeater rptOrderItems = (Repeater)e.Item.FindControl("rptOrderItems");
                if (rptOrderItems != null)
                {
                    using (SqlConnection con = new SqlConnection(connectionString))
                    {
                        con.Open();
                        SqlCommand cmd = new SqlCommand(
                            @"SELECT ProductName, ProductImageUrl, Quantity, UnitPrice 
                              FROM OrderDetails 
                              WHERE OrderID = @OrderID", con);
                        cmd.Parameters.AddWithValue("@OrderID", orderId);

                        SqlDataAdapter sda = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        rptOrderItems.DataSource = dt;
                        rptOrderItems.DataBind();
                    }
                }

                // Set up cancel button click event
                LinkButton btnCancel = (LinkButton)e.Item.FindControl("btnCancelOrder");
                if (btnCancel != null)
                {
                    btnCancel.OnClientClick = $"confirmCancel({orderId}); return false;";
                }
            }
        }

        public string GetStatusClass(string status)
        {
            switch (status.ToLower())
            {
                case "processing":
                    return "processing";
                case "shipped":
                    return "shipped";
                case "delivered":
                    return "delivered";
                case "cancelled":
                    return "cancelled";
                default:
                    return "processing";
            }
        }

        [WebMethod]
        public static CancelOrderResponse CancelOrder(int orderId)
        {
            try
            {
                var context = HttpContext.Current;
                if (context.Session["CustomerId"] == null)
                {
                    return new CancelOrderResponse
                    {
                        success = false,
                        message = "not_logged_in",
                        redirectUrl = "Login.aspx?ReturnUrl=MyOrders.aspx"
                    };
                }

                int userId = Convert.ToInt32(context.Session["CustomerId"]);
                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    // Verify the order belongs to the user
                    SqlCommand verifyCmd = new SqlCommand(
                        "SELECT COUNT(1) FROM Orders WHERE OrderID = @OrderID AND CustomerID = @CustomerID", con);
                    verifyCmd.Parameters.AddWithValue("@OrderID", orderId);
                    verifyCmd.Parameters.AddWithValue("@CustomerID", userId);

                    if (Convert.ToInt32(verifyCmd.ExecuteScalar()) == 0)
                    {
                        return new CancelOrderResponse
                        {
                            success = false,
                            message = "Order not found or doesn't belong to you"
                        };
                    }

                    // Check if order can be cancelled (only processing orders can be cancelled)
                    SqlCommand statusCmd = new SqlCommand(
                        "SELECT Status FROM Orders WHERE OrderID = @OrderID", con);
                    statusCmd.Parameters.AddWithValue("@OrderID", orderId);
                    string currentStatus = statusCmd.ExecuteScalar().ToString();

                    if (currentStatus.ToLower() != "processing")
                    {
                        return new CancelOrderResponse
                        {
                            success = false,
                            message = "Only processing orders can be cancelled"
                        };
                    }

                    // Update order status
                    SqlCommand updateCmd = new SqlCommand(
                        "UPDATE Orders SET Status = 'Cancelled' WHERE OrderID = @OrderID", con);
                    updateCmd.Parameters.AddWithValue("@OrderID", orderId);
                    updateCmd.ExecuteNonQuery();

                    return new CancelOrderResponse
                    {
                        success = true,
                        message = "Order cancelled successfully"
                    };
                }
            }
            catch (Exception ex)
            {
                return new CancelOrderResponse
                {
                    success = false,
                    message = "Error cancelling order: " + ex.Message
                };
            }
        }

        public class CancelOrderResponse
        {
            public bool success { get; set; }
            public string message { get; set; }
            public string redirectUrl { get; set; }
        }

        protected void btnReorder_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            int orderId = Convert.ToInt32(btn.CommandArgument);

            // Get all items from the order and add them to cart
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                // Get customer's active cart or create new one
                int cartId = GetOrCreateCart(con);

                // Get order items
                SqlCommand cmd = new SqlCommand(
                    @"SELECT ProductID, Quantity, UnitPrice 
                      FROM OrderDetails 
                      WHERE OrderID = @OrderID", con);
                cmd.Parameters.AddWithValue("@OrderID", orderId);

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int productId = Convert.ToInt32(reader["ProductID"]);
                        int quantity = Convert.ToInt32(reader["Quantity"]);
                        decimal price = Convert.ToDecimal(reader["UnitPrice"]);

                        // Check if product already exists in cart
                        SqlCommand checkCmd = new SqlCommand(
                            @"SELECT CartItemID, Quantity FROM CartItems 
                              WHERE CartID = @CartID AND ProductID = @ProductID", con);
                        checkCmd.Parameters.AddWithValue("@CartID", cartId);
                        checkCmd.Parameters.AddWithValue("@ProductID", productId);

                        using (SqlDataReader checkReader = checkCmd.ExecuteReader())
                        {
                            if (checkReader.Read())
                            {
                                // Update existing cart item
                                int existingQuantity = Convert.ToInt32(checkReader["Quantity"]);
                                int newQuantity = existingQuantity + quantity;
                                int cartItemId = Convert.ToInt32(checkReader["CartItemID"]);

                                SqlCommand updateCmd = new SqlCommand(
                                    @"UPDATE CartItems SET Quantity = @Quantity 
                                      WHERE CartItemID = @CartItemID", con);
                                updateCmd.Parameters.AddWithValue("@Quantity", newQuantity);
                                updateCmd.Parameters.AddWithValue("@CartItemID", cartItemId);
                                updateCmd.ExecuteNonQuery();
                            }
                            else
                            {
                                // Add new cart item
                                SqlCommand insertCmd = new SqlCommand(
                                    @"INSERT INTO CartItems 
                                      (CartID, ProductID, Quantity, AddedAt, Price) 
                                      VALUES 
                                      (@CartID, @ProductID, @Quantity, @AddedAt, @Price)", con);
                                insertCmd.Parameters.AddWithValue("@CartID", cartId);
                                insertCmd.Parameters.AddWithValue("@ProductID", productId);
                                insertCmd.Parameters.AddWithValue("@Quantity", quantity);
                                insertCmd.Parameters.AddWithValue("@AddedAt", DateTime.Now);
                                insertCmd.Parameters.AddWithValue("@Price", price);
                                insertCmd.ExecuteNonQuery();
                            }
                        }
                    }
                }
            }

            Response.Redirect("~/User/Cart.aspx");
        }

        private int GetOrCreateCart(SqlConnection con)
        {
            int userId = Convert.ToInt32(Session["CustomerId"]);

            // Check for existing active cart
            SqlCommand cmd = new SqlCommand(
                "SELECT CartID FROM Cart WHERE CustomerID = @CustomerID AND IsActive = 1", con);
            cmd.Parameters.AddWithValue("@CustomerID", userId);

            object result = cmd.ExecuteScalar();
            if (result != null)
            {
                return Convert.ToInt32(result);
            }

            // Create new cart
            SqlCommand insertCmd = new SqlCommand(
                "INSERT INTO Cart (CustomerID, IsActive) VALUES (@CustomerID, 1); SELECT SCOPE_IDENTITY();", con);
            insertCmd.Parameters.AddWithValue("@CustomerID", userId);
            return Convert.ToInt32(insertCmd.ExecuteScalar());
        }

        protected void btnCancelOrder_Click(object sender, EventArgs e)
        {
            // This is just a placeholder - the actual cancellation is handled via AJAX
        }

        protected void lnkPrevious_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1)
            {
                CurrentPage--;
                LoadOrders();
            }
        }

        protected void lnkNext_Click(object sender, EventArgs e)
        {
            if (CurrentPage < TotalPages)
            {
                CurrentPage++;
                LoadOrders();
            }
        }

        protected void lnkPage_Click(object sender, EventArgs e)
        {
            LinkButton lnk = (LinkButton)sender;
            CurrentPage = Convert.ToInt32(lnk.CommandArgument);
            LoadOrders();
        }

        private void SetupPagination()
        {
            if (TotalPages <= 1)
            {
                paginationContainer.Visible = false;
                return;
            }

            // Create list of page numbers to display
            List<int> pages = new List<int>();
            int startPage = Math.Max(1, CurrentPage - 2);
            int endPage = Math.Min(TotalPages, CurrentPage + 2);

            for (int i = startPage; i <= endPage; i++)
            {
                pages.Add(i);
            }

            rptPagination.DataSource = pages.Select(p => new { PageNumber = p });
            rptPagination.DataBind();

            // Disable previous/next buttons when appropriate
            lnkPrevious.Enabled = CurrentPage > 1;
            lnkNext.Enabled = CurrentPage < TotalPages;
        }
    }
}