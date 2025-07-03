








using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.UI.WebControls;
using System.Web.UI;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Next_ae.User
{
    public partial class Cart : System.Web.UI.Page
    {
        public class CartResponse
        {
            public bool Success { get; set; }
            public string Message { get; set; }
            public string RedirectUrl { get; set; }
            public int CartCount { get; set; }
            public string Subtotal { get; set; }
            public string Shipping { get; set; }
            public string Total { get; set; }
        }

        public class CartUpdate
        {
            public int CartItemID { get; set; }
            public int Quantity { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCart();
            }
        }

        private void LoadCart()
        {
            if (Session["CustomerID"] == null)
            {
                Response.Redirect($"~/User/Login.aspx?ReturnUrl={Server.UrlEncode(Request.Url.PathAndQuery)}");
                return;
            }

            int customerId = Convert.ToInt32(Session["CustomerID"]);
            DataTable cartItems = GetCartItems(customerId);

            if (cartItems.Rows.Count > 0)
            {
                emptyCartMessage.Visible = false;
                cartTable.Visible = true;

                rptCartItems.DataSource = cartItems;
                rptCartItems.DataBind();
            }
            else
            {
                emptyCartMessage.Visible = true;
                cartTable.Visible = false;
            }
        }

        private DataTable GetCartItems(int customerId)
        {
            DataTable dt = new DataTable();
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"SELECT ci.CartItemID, p.ProductID, p.ProductName, ci.Price, ci.Quantity, 
                                ci.Size, ci.Color, (ci.Price * ci.Quantity) AS TotalPrice,
                                COALESCE((SELECT TOP 1 ImageUrl FROM ProductImage WHERE ProductID = p.ProductID AND IsDefault = 1), 'default-product.jpg') AS ImageUrl
                                FROM CartItems ci
                                INNER JOIN Product p ON ci.ProductID = p.ProductID
                                INNER JOIN Cart c ON ci.CartID = c.CartID
                                WHERE c.CustomerID = @CustomerID AND c.IsActive = 1";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@CustomerID", customerId);

                con.Open();
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                da.Fill(dt);
            }

            return dt;
        }

        protected void rptCartItems_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                Image imgProduct = (Image)e.Item.FindControl("imgProduct");
                HiddenField hfImageUrl = (HiddenField)e.Item.FindControl("hfImageUrl");

                if (imgProduct != null && hfImageUrl != null)
                {
                    string imagePath = hfImageUrl.Value;

                    if (string.IsNullOrEmpty(imagePath))
                    {
                        imagePath = "default-product.jpg";
                    }

                    if (imagePath.StartsWith("/ProductImages/"))
                    {
                        imgProduct.ImageUrl = imagePath;
                    }
                    else if (Uri.IsWellFormedUriString(imagePath, UriKind.Absolute))
                    {
                        imgProduct.ImageUrl = imagePath;
                    }
                    else
                    {
                        imgProduct.ImageUrl = ResolveUrl("~/images/default-product.jpg");
                    }

                    imgProduct.Attributes["onerror"] = "this.src='" + ResolveUrl("~/images/default-product.jpg") + "'";
                }
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static CartResponse RemoveItem(int cartItemId)
        {
            try
            {
                if (HttpContext.Current.Session["CustomerID"] == null)
                {
                    return new CartResponse
                    {
                        Success = false,
                        Message = "not_logged_in",
                        RedirectUrl = "Login.aspx?ReturnUrl=Cart.aspx"
                    };
                }

                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    SqlCommand cmd = new SqlCommand("DELETE FROM CartItems WHERE CartItemID = @CartItemID", con);
                    cmd.Parameters.AddWithValue("@CartItemID", cartItemId);
                    con.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        int customerId = Convert.ToInt32(HttpContext.Current.Session["CustomerID"]);
                        return new CartResponse
                        {
                            Success = true,
                            Message = "Item removed from cart successfully!",
                            CartCount = GetCartCount(customerId),
                            Subtotal = "Rs. " + GetCartSubtotal(customerId).ToString("0.00"),
                            Shipping = "Rs. " + CalculateShipping(GetCartSubtotal(customerId)).ToString("0.00"),
                            Total = "Rs. " + (GetCartSubtotal(customerId) + CalculateShipping(GetCartSubtotal(customerId))).ToString("0.00")
                        };
                    }
                    else
                    {
                        return new CartResponse
                        {
                            Success = false,
                            Message = "Item not found in cart"
                        };
                    }
                }
            }
            catch (Exception ex)
            {
                return new CartResponse
                {
                    Success = false,
                    Message = "Error: " + ex.Message
                };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static CartResponse UpdateCart(List<CartUpdate> updates)
        {
            try
            {
                if (HttpContext.Current.Session["CustomerID"] == null)
                {
                    return new CartResponse
                    {
                        Success = false,
                        Message = "not_logged_in",
                        RedirectUrl = "Login.aspx?ReturnUrl=Cart.aspx"
                    };
                }

                if (updates == null || updates.Count == 0)
                {
                    return new CartResponse
                    {
                        Success = false,
                        Message = "No items to update"
                    };
                }

                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
                int customerId = Convert.ToInt32(HttpContext.Current.Session["CustomerID"]);

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    foreach (var update in updates)
                    {
                        SqlCommand cmd = new SqlCommand(
                            "UPDATE CartItems SET Quantity = @Quantity WHERE CartItemID = @CartItemID", con);
                        cmd.Parameters.AddWithValue("@Quantity", update.Quantity);
                        cmd.Parameters.AddWithValue("@CartItemID", update.CartItemID);
                        cmd.ExecuteNonQuery();
                    }

                    return new CartResponse
                    {
                        Success = true,
                        Message = "Cart updated successfully!",
                        CartCount = GetCartCount(customerId),
                        Subtotal = GetCartSubtotal(customerId).ToString("C"),
                        Shipping = CalculateShipping(GetCartSubtotal(customerId)).ToString("C"),
                        Total = (GetCartSubtotal(customerId) + CalculateShipping(GetCartSubtotal(customerId))).ToString("C")
                    };
                }
            }
            catch (Exception ex)
            {
                return new CartResponse
                {
                    Success = false,
                    Message = "Error: " + ex.Message
                };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static CartResponse ProceedToCheckout()
        {
            try
            {
                if (HttpContext.Current.Session["CustomerID"] == null)
                {
                    return new CartResponse
                    {
                        Success = false,
                        Message = "not_logged_in",
                        RedirectUrl = "Login.aspx?ReturnUrl=Cart.aspx"
                    };
                }

                int customerId = Convert.ToInt32(HttpContext.Current.Session["CustomerID"]);

                // Check if cart is empty
                if (GetCartCount(customerId) == 0)
                {
                    return new CartResponse
                    {
                        Success = false,
                        Message = "cart_empty"
                    };
                }

                return new CartResponse
                {
                    Success = true,
                    Message = "Proceeding to checkout"
                };
            }
            catch (Exception ex)
            {
                return new CartResponse
                {
                    Success = false,
                    Message = "Error: " + ex.Message
                };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static CartResponse GetCartSummary()
        {
            try
            {
                if (HttpContext.Current.Session["CustomerID"] == null)
                {
                    return new CartResponse
                    {
                        Success = false,
                        Message = "not_logged_in"
                    };
                }

                int customerId = Convert.ToInt32(HttpContext.Current.Session["CustomerID"]);
                decimal subtotal = GetCartSubtotal(customerId);
                decimal shipping = CalculateShipping(subtotal);
                decimal total = subtotal + shipping;

                return new CartResponse
                {
                    Success = true,
                    Subtotal = "Rs. " + subtotal.ToString("0.00"),
                    Shipping = "Rs. " + shipping.ToString("0.00"),
                    Total = "Rs. " + total.ToString("0.00")
                };
            }
            catch (Exception ex)
            {
                return new CartResponse
                {
                    Success = false,
                    Message = "Error: " + ex.Message
                };
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static int GetCartCount()
        {
            if (HttpContext.Current.Session["CustomerID"] == null)
            {
                return 0;
            }

            int customerId = Convert.ToInt32(HttpContext.Current.Session["CustomerID"]);
            return GetCartCount(customerId);
        }

        private static int GetCartCount(int customerId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"SELECT SUM(ci.Quantity) 
                                FROM CartItems ci
                                INNER JOIN Cart c ON ci.CartID = c.CartID
                                WHERE c.CustomerID = @CustomerID AND c.IsActive = 1";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@CustomerID", customerId);
                con.Open();

                object result = cmd.ExecuteScalar();
                return result != DBNull.Value ? Convert.ToInt32(result) : 0;
            }
        }

        private static decimal GetCartSubtotal(int customerId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"SELECT SUM(ci.Price * ci.Quantity)
                                FROM CartItems ci
                                INNER JOIN Cart c ON ci.CartID = c.CartID
                                WHERE c.CustomerID = @CustomerID AND c.IsActive = 1";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@CustomerID", customerId);
                con.Open();

                object result = cmd.ExecuteScalar();
                return result != DBNull.Value ? Convert.ToDecimal(result) : 0;
            }
        }

        private static decimal CalculateShipping(decimal subtotal)
        {
            return subtotal > 50 ? 0 : 5.99m;
        }
    }
}