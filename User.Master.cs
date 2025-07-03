using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Text;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using System.IO;
using System.Diagnostics;
using System.Linq;
using System.Web.UI.HtmlControls;

namespace Next_ae.User
{
    public partial class UserMaster : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                UpdateLoginStatus();
                LoadCartItems(); // Add this line

            }
        }

        

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            // Your logout logic
            Session.Clear();
            Session.Abandon();
            UpdateLoginStatus();
         
            Response.Redirect("~/User/Home.aspx");
        }

        public void UpdateLoginStatus()
        {
            if (Session["CustomerName"] != null)
            {
                pnlLoggedIn.Visible = true;
                pnlLoggedOut.Visible = false;
                lblLoginStatus.Text = Session["CustomerName"].ToString();

                // Display full name but keep username in session
                if (Session["FirstName"] != null)
                {
                    lblLoginStatus.Text = Session["FirstName"].ToString();
                }
                
            }
            else
            {
                pnlLoggedIn.Visible = false;
                pnlLoggedOut.Visible = true;
                lblLoginStatus.Text = "Login";
            }
        }




        [System.Web.Services.WebMethod]
        public void RefreshCart()
        {
            LoadCartItems();
        }




        private void LoadCartItems()
        {
            // Initialize cart count to 0
            int itemCount = 0;
            cartCountBadge.InnerText = "0";
            mobileCartCountBadge.InnerText = "0";

            // Show login message if user is not logged in
            if (Session["CustomerID"] == null)
            {
                pnlNotLoggedIn.Visible = true;  // Show "Please login" message
                pnlEmptyCart.Visible = false;   // Hide empty cart message
                cartContent.InnerHtml = "";
                return;
            }

            // User is logged in, so hide login message
            pnlNotLoggedIn.Visible = false;

            int customerId = Convert.ToInt32(Session["CustomerID"]);
            DataTable cartItems = GetCartItemsFromDB(customerId);

            // Update cart count badge
            itemCount = cartItems.AsEnumerable().Sum(row => Convert.ToInt32(row["Quantity"]));
            cartCountBadge.InnerText = itemCount.ToString();
            mobileCartCountBadge.InnerText = itemCount.ToString();

            // If cart is empty, show empty cart message
            if (cartItems.Rows.Count == 0)
            {
                pnlEmptyCart.Visible = true;    // Show "Your cart is empty" message
                cartContent.InnerHtml = "";

                // Update the empty cart message for logged-in users
                var emptyCartMessage = cartContent.Parent.FindControl("pnlEmptyCart") as Panel;
                if (emptyCartMessage != null)
                {
                    var message = emptyCartMessage.FindControl("emptyMessage") as HtmlGenericControl;
                    var button = emptyCartMessage.FindControl("btnContinueShopping") as HtmlAnchor;

                    if (message != null) message.InnerText = "Your cart is empty";
                    if (button != null)
                    {
                        button.HRef = "Shop.aspx";
                        button.InnerText = "Continue Shopping";
                    }
                }
                return;
            }

            // If we get here, user has items in cart
            pnlEmptyCart.Visible = false;

            // Rest of your cart item rendering code...
            StringBuilder sb = new StringBuilder();
            decimal subtotal = 0;

            sb.Append("<ul class='header-cart-wrapitem w-full'>");
            foreach (DataRow row in cartItems.Rows)
            {
                decimal price = Convert.ToDecimal(row["Price"]);
                int quantity = Convert.ToInt32(row["Quantity"]);
                decimal total = price * quantity;
                subtotal += total;

                string imageUrl = row["ImageUrl"] != DBNull.Value ?
                    row["ImageUrl"].ToString() :
                    "default-product.jpg";

                if (!imageUrl.StartsWith("http") && !imageUrl.StartsWith("/"))
                {
                    imageUrl = "images/" + imageUrl;
                }

                string fullImageUrl = ResolveUrl("~/" + imageUrl.TrimStart('/'));

                sb.Append($@"
            <li class='header-cart-item flex-w flex-t m-b-12'>
                <div class='header-cart-item-img'>
                    <img src='{fullImageUrl}' alt='IMG' onerror=""this.src='{ResolveUrl("~/images/default-product.jpg")}'"">
                </div>
                <div class='header-cart-item-txt p-t-8'>
                    <a href='ProductDetail.aspx?id={row["ProductID"]}' class='header-cart-item-name m-b-18 hov-cl1 trans-04'>
                        {HttpUtility.HtmlEncode(row["ProductName"].ToString())}
                    </a>
                    <span class='header-cart-item-info'>
                        {quantity} x {price.ToString("C")}
                    </span>
                </div>
            </li>");
            }
            sb.Append("</ul>");

            sb.Append($@"
        <div class='w-full'>
            <div class='header-cart-total w-full p-tb-40'>
                Subtotal: {subtotal.ToString("C")}
            </div>
            <div class='header-cart-buttons flex-w w-full'>
                <a href='Cart.aspx' class='flex-c-m stext-101 cl0 size-107 bg3 bor2 hov-btn3 p-lr-15 trans-04 m-r-8 m-b-10'>
                    View Cart
                </a>
                <a href='Checkout.aspx' class='flex-c-m stext-101 cl0 size-107 bg3 bor2 hov-btn3 p-lr-15 trans-04 m-b-10'>
                    Check Out
                </a>
            </div>
        </div>");

            cartContent.InnerHtml = sb.ToString();
        }
        protected string GetProductImageUrl(string productId)
        {
            string defaultImage = "~/ProductImages/default-product.png";

            if (string.IsNullOrEmpty(productId))
                return ResolveUrl(defaultImage);

            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = @"SELECT TOP 1 
                           CASE 
                               WHEN LEFT(ImageUrl, 1) = '/' THEN ImageUrl
                               ELSE '~/ProductImages/' + ImageUrl
                           END AS ImageUrl
                           FROM ProductImage 
                           WHERE ProductID = @ProductID AND IsDefault = 1";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@ProductID", productId);
                        con.Open();
                        object result = cmd.ExecuteScalar();

                        if (result != null && !string.IsNullOrEmpty(result.ToString()))
                        {
                            string imagePath = result.ToString();
                            // Ensure proper URL resolution
                            return imagePath.StartsWith("http") ? imagePath : ResolveUrl(imagePath);
                        }
                    }
                }
            }
            catch
            {
                // Log error if needed
            }

            return ResolveUrl(defaultImage);
        }
        private static DataTable GetCartItemsFromDB(int customerId)
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

                    // Check if it's a relative path starting with /ProductImages/
                    if (imagePath.StartsWith("/ProductImages/"))
                    {
                        // Option 1: Use as-is (if ProductImages is a virtual directory)
                        imgProduct.ImageUrl = imagePath;

                        // OR Option 2: Map to your preferred structure
                        // imgProduct.ImageUrl = ResolveUrl("~/Images/Products/" + Path.GetFileName(imagePath));
                    }
                    else if (Uri.IsWellFormedUriString(imagePath, UriKind.Absolute))
                    {
                        imgProduct.ImageUrl = imagePath;
                    }
                    else
                    {
                        // Fallback to default image
                        imgProduct.ImageUrl = ResolveUrl("~/images/default-product.jpg");
                    }

                    // Add error handling as needed
                    imgProduct.Attributes["onerror"] = "this.src='" + ResolveUrl("~/images/default-product.jpg") + "'";
                }
            }
        }



    }
}