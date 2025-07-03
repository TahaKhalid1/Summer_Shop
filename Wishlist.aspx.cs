using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Next_ae.User
{
    public partial class Wishlist : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["CustomerID"] == null)
                {
                    Response.Redirect($"~/User/Login.aspx?ReturnUrl={Server.UrlEncode(Request.Url.PathAndQuery)}");
                    return;
                }

                LoadWishlist();
            }
        }

        private void LoadWishlist()
        {
            int customerId = Convert.ToInt32(Session["CustomerID"]);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                SqlCommand cmd = new SqlCommand(
                    @"SELECT w.WishlistID, w.CreatedAt AS AddedDate, p.ProductID, p.ProductName, p.Price, 
                             COALESCE(pi.ImageUrl, 'default-product.jpg') AS ImageUrl
                      FROM Wishlist w
                      INNER JOIN Product p ON w.ProductID = p.ProductID
                      LEFT JOIN ProductImage pi ON p.ProductID = pi.ProductID AND pi.IsDefault = 1
                      WHERE w.CustomerID = @CustomerID
                      ORDER BY w.CreatedAt DESC", con);

                cmd.Parameters.AddWithValue("@CustomerID", customerId);

                SqlDataAdapter sda = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                sda.Fill(dt);

                if (dt.Rows.Count > 0)
                {
                    rptWishlist.DataSource = dt;
                    rptWishlist.DataBind();
                    pnlEmptyWishlist.Visible = false;
                }
                else
                {
                    pnlEmptyWishlist.Visible = true;
                }
            }
        }

        protected void rptWishlist_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                Image imgProduct = (Image)e.Item.FindControl("imgProduct");
                string imageUrl = DataBinder.Eval(e.Item.DataItem, "ImageUrl").ToString();

                if (!imageUrl.StartsWith("http") && !imageUrl.StartsWith("/"))
                {
                    imgProduct.ImageUrl = ResolveUrl("~/ProductImages/" + imageUrl);
                }
                else
                {
                    imgProduct.ImageUrl = imageUrl;
                }
                imgProduct.Attributes["onerror"] = "this.src='" + ResolveUrl("~/images/default-product.jpg") + "'";
            }
        }

        protected void btnRemove_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string[] args = btn.CommandArgument.Split('|');
            int wishlistId = Convert.ToInt32(args[0]);
            int productId = Convert.ToInt32(args[1]);

            if (Session["CustomerID"] == null)
            {
                Response.Redirect("~/User/Login.aspx");
                return;
            }

            int customerId = Convert.ToInt32(Session["CustomerID"]);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                // Verify the wishlist item belongs to the customer
                SqlCommand verifyCmd = new SqlCommand(
                    "SELECT COUNT(1) FROM Wishlist WHERE WishlistID = @WishlistID AND CustomerID = @CustomerID", con);
                verifyCmd.Parameters.AddWithValue("@WishlistID", wishlistId);
                verifyCmd.Parameters.AddWithValue("@CustomerID", customerId);

                if (Convert.ToInt32(verifyCmd.ExecuteScalar()) == 0)
                {
                    // Show error message
                    ScriptManager.RegisterStartupScript(this, GetType(), "showalert",
                        "swal('Error', 'This item does not belong to your wishlist', 'error');", true);
                    return;
                }

                // Remove from wishlist
                SqlCommand deleteCmd = new SqlCommand(
                    "DELETE FROM Wishlist WHERE WishlistID = @WishlistID", con);
                deleteCmd.Parameters.AddWithValue("@WishlistID", wishlistId);
                deleteCmd.ExecuteNonQuery();

                // Refresh the wishlist
                LoadWishlist();

                // Show success message
                ScriptManager.RegisterStartupScript(this, GetType(), "showalert",
                    "swal('Success', 'Item removed from wishlist', 'success');", true);
            }
        }

        protected void btnAddToCart_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            int productId = Convert.ToInt32(btn.CommandArgument);

            if (Session["CustomerID"] == null)
            {
                Response.Redirect("~/User/Login.aspx");
                return;
            }

            int customerId = Convert.ToInt32(Session["CustomerID"]);

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                // Get or create cart
                int cartId = GetOrCreateCart(con, customerId);

                // Check if product exists in cart
                bool existsInCart = false;
                int cartItemId = 0;
                int quantity = 0;

                SqlCommand checkCmd = new SqlCommand(
                    "SELECT CartItemID, Quantity FROM CartItems WHERE CartID = @CartID AND ProductID = @ProductID", con);
                checkCmd.Parameters.AddWithValue("@CartID", cartId);
                checkCmd.Parameters.AddWithValue("@ProductID", productId);

                using (SqlDataReader reader = checkCmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        existsInCart = true;
                        cartItemId = reader.GetInt32(0);
                        quantity = reader.GetInt32(1);
                    }
                }

                // Get product price
                decimal price = 0;
                SqlCommand priceCmd = new SqlCommand("SELECT Price FROM Product WHERE ProductID = @ProductID", con);
                priceCmd.Parameters.AddWithValue("@ProductID", productId);
                price = Convert.ToDecimal(priceCmd.ExecuteScalar());

                if (existsInCart)
                {
                    // Update quantity
                    SqlCommand updateCmd = new SqlCommand(
                        "UPDATE CartItems SET Quantity = Quantity + 1 WHERE CartItemID = @CartItemID", con);
                    updateCmd.Parameters.AddWithValue("@CartItemID", cartItemId);
                    updateCmd.ExecuteNonQuery();
                }
                else
                {
                    // Add new item
                    SqlCommand insertCmd = new SqlCommand(
                        @"INSERT INTO CartItems (CartID, ProductID, Quantity, Price, AddedAt) 
                          VALUES (@CartID, @ProductID, 1, @Price, GETDATE())", con);
                    insertCmd.Parameters.AddWithValue("@CartID", cartId);
                    insertCmd.Parameters.AddWithValue("@ProductID", productId);
                    insertCmd.Parameters.AddWithValue("@Price", price);
                    insertCmd.ExecuteNonQuery();
                }

                // Remove from wishlist after adding to cart
                SqlCommand removeCmd = new SqlCommand(
                    "DELETE FROM Wishlist WHERE CustomerID = @CustomerID AND ProductID = @ProductID", con);
                removeCmd.Parameters.AddWithValue("@CustomerID", customerId);
                removeCmd.Parameters.AddWithValue("@ProductID", productId);
                removeCmd.ExecuteNonQuery();

                // Refresh the wishlist
                LoadWishlist();

                // Show success message
                ScriptManager.RegisterStartupScript(this, GetType(), "showalert",
                    "swal('Success', 'Item added to cart and removed from wishlist', 'success').then(function() { window.location.href = 'Cart.aspx'; });", true);
            }
        }

        private int GetOrCreateCart(SqlConnection con, int customerId)
        {
            SqlCommand cmd = new SqlCommand(
                "SELECT CartID FROM Cart WHERE CustomerID = @CustomerID AND IsActive = 1", con);
            cmd.Parameters.AddWithValue("@CustomerID", customerId);

            object result = cmd.ExecuteScalar();
            if (result != null)
            {
                return Convert.ToInt32(result);
            }

            SqlCommand insertCmd = new SqlCommand(
                "INSERT INTO Cart (CustomerID, IsActive) VALUES (@CustomerID, 1); SELECT SCOPE_IDENTITY();", con);
            insertCmd.Parameters.AddWithValue("@CustomerID", customerId);
            return Convert.ToInt32(insertCmd.ExecuteScalar());
        }
    }
}