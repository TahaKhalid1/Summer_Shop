


















using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.UI.WebControls;
using System.Web;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Next_ae.User
{
    public partial class Shop : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Get category and subcategory from query string
                int? categoryId = null;
                int? subcategoryId = null;

                if (!string.IsNullOrEmpty(Request.QueryString["CategoryId"]))
                {
                    categoryId = int.Parse(Request.QueryString["CategoryId"]);
                }
                else if (!string.IsNullOrEmpty(Request.QueryString["catId"]))
                {
                    categoryId = int.Parse(Request.QueryString["catId"]);
                }

                if (!string.IsNullOrEmpty(Request.QueryString["SubcategoryId"]))
                {
                    subcategoryId = int.Parse(Request.QueryString["SubcategoryId"]);
                }
                else if (!string.IsNullOrEmpty(Request.QueryString["subcatId"]))
                {
                    subcategoryId = int.Parse(Request.QueryString["subcatId"]);
                }

                BindProducts(categoryId, subcategoryId);
                UpdatePageTitle(categoryId, subcategoryId);
                UpdateFilterInfo(categoryId, subcategoryId);
                LoadCartItems();
            }
        }




        private void LoadCartItems()
        {
            if (Session["CustomerID"] == null)
            {
                pnlEmptyCart.Visible = true;
                cartContent.InnerHtml = "";
                return;
            }

            int customerId = Convert.ToInt32(Session["CustomerID"]);
            DataTable cartItems = GetCartItemsFromDB(customerId);

            if (cartItems.Rows.Count == 0)
            {
                pnlEmptyCart.Visible = true;
                cartContent.InnerHtml = "";
                return;
            }

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

                // Fix the image path based on your database storage
                if (!imageUrl.StartsWith("http") && !imageUrl.StartsWith("/"))
                {
                    // If it's just a filename, prepend the images path
                    imageUrl = "images/" + imageUrl;
                }

                // Resolve the full URL
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
                    {quantity} x Rs.{price.ToString("0.00")}
                </span>
            </div>
        </li>");
            }
            sb.Append("</ul>");

            sb.Append($@"
    <div class='w-full'>
        <div class='header-cart-total w-full p-tb-40'>
            Subtotal: Rs.{subtotal.ToString("0.00")}
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
            pnlEmptyCart.Visible = false;
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

        private void BindProducts(int? categoryId = null, int? subcategoryId = null)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                // Modified query to properly join with Category and SubCategory tables
                string query = @"SELECT p.ProductID, p.ProductName, p.Price, p.Gender, 
                            c.CategoryName, sc.SubCategoryName,
                            COALESCE(pi.ImageUrl, 'default-product.jpg') AS ImageUrl
                            FROM Product p
                            LEFT JOIN ProductImage pi ON p.ProductID = pi.ProductID AND pi.IsDefault = 1
                            LEFT JOIN SubCategory sc ON p.SubCategoryID = sc.SubCategoryID
                            LEFT JOIN Category c ON sc.CategoryID = c.CategoryID
                            WHERE p.IsActive = 1";

                // Add filters based on parameters
                if (categoryId.HasValue)
                {
                    query += " AND c.CategoryID = @CategoryID";
                }

                if (subcategoryId.HasValue)
                {
                    query += " AND sc.SubCategoryID = @SubCategoryID";
                }

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    if (categoryId.HasValue)
                    {
                        cmd.Parameters.AddWithValue("@CategoryID", categoryId.Value);
                    }

                    if (subcategoryId.HasValue)
                    {
                        cmd.Parameters.AddWithValue("@SubCategoryID", subcategoryId.Value);
                    }

                    try
                    {
                        con.Open();
                        SqlDataAdapter sda = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptProducts.DataSource = dt;
                            rptProducts.DataBind();
                            lblMessage.Visible = false;
                        }
                        else
                        {
                            lblMessage.Text = "No products available in this category yet.";
                            lblMessage.Visible = true;
                        }
                    }
                    catch (Exception ex)
                    {
                        lblMessage.Text = "Error loading products: " + ex.Message;
                        lblMessage.Visible = true;
                    }
                }
            }
        }

        private void UpdatePageTitle(int? categoryId, int? subcategoryId)
        {
            if (categoryId.HasValue)
            {
                string categoryName = GetCategoryName(categoryId.Value);
                Page.Title = categoryName + " Products";

                if (subcategoryId.HasValue)
                {
                    string subcategoryName = GetSubcategoryName(subcategoryId.Value);
                    Page.Title += " - " + subcategoryName;
                }
            }
            else
            {
                Page.Title = "All Products";
            }
        }

        private string GetCategoryName(int categoryId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT CategoryName FROM Category WHERE CategoryID = @CategoryID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@CategoryID", categoryId);
                    con.Open();
                    return cmd.ExecuteScalar()?.ToString() ?? string.Empty;
                }
            }
        }

        private string GetSubcategoryName(int subcategoryId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT SubCategoryName FROM SubCategory WHERE SubCategoryID = @SubCategoryID";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SubCategoryID", subcategoryId);
                    con.Open();
                    return cmd.ExecuteScalar()?.ToString() ?? string.Empty;
                }
            }
        }

        private void UpdateFilterInfo(int? categoryId, int? subcategoryId)
        {
            if (categoryId.HasValue || subcategoryId.HasValue)
            {
                string filterText = "Showing: ";
                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    if (categoryId.HasValue)
                    {
                        // Get category name
                        string categoryQuery = "SELECT CategoryName FROM Category WHERE CategoryID = @CategoryID";
                        using (SqlCommand cmd = new SqlCommand(categoryQuery, con))
                        {
                            cmd.Parameters.AddWithValue("@CategoryID", categoryId.Value);
                            filterText += cmd.ExecuteScalar()?.ToString();
                        }
                    }

                    if (subcategoryId.HasValue)
                    {
                        // Get subcategory name
                        string subcategoryQuery = "SELECT SubCategoryName FROM SubCategory WHERE SubCategoryID = @SubCategoryID";
                        using (SqlCommand cmd = new SqlCommand(subcategoryQuery, con))
                        {
                            cmd.Parameters.AddWithValue("@SubCategoryID", subcategoryId.Value);
                            filterText += categoryId.HasValue ? " > " + cmd.ExecuteScalar()?.ToString()
                                                             : cmd.ExecuteScalar()?.ToString();
                        }
                    }
                }

                lblFilterInfo.Text = filterText;
                lblFilterInfo.Visible = true;
            }
            else
            {
                lblFilterInfo.Text = "Showing all products";
                lblFilterInfo.Visible = true;
            }
        }



        protected void rptProducts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                Image imgProduct = (Image)e.Item.FindControl("imgProduct");

                string imageUrl = row["ImageUrl"] != DBNull.Value ?
                    row["ImageUrl"].ToString() :
                    "~/images/default-product.jpg";

                imgProduct.ImageUrl = ResolveUrl(imageUrl);
                imgProduct.AlternateText = row["ProductName"].ToString();
            }
        }

        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static ProductQuickView GetProductQuickView(int productId)
        {
            var product = new ProductQuickView();

            using (var con = new SqlConnection(ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString))
            {
                // Get product details
                var productQuery = @"SELECT ProductName, Price, ShortDescription, Size, Color 
                                           FROM Product WHERE ProductID = @ProductID";

                using (var cmd = new SqlCommand(productQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ProductID", productId);
                    con.Open();

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            product.Id = productId;
                            product.Name = reader.GetString(0);
                            product.Price = reader.GetDecimal(1);
                            product.ShortDescription = reader.IsDBNull(2) ? string.Empty : reader.GetString(2);

                            // Get sizes from comma-separated string
                            var sizeString = reader.IsDBNull(3) ? "" : reader.GetString(3);
                            product.Sizes = sizeString.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                                .Select(s => new ProductOption { Name = s.Trim() })
                                .ToList();

                            // Get colors from comma-separated string
                            var colorString = reader.IsDBNull(4) ? "" : reader.GetString(4);
                            product.Colors = colorString.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                                .Select(c => new ProductOption { Name = c.Trim() })
                                .ToList();
                        }
                    }
                }

                // Get product images
                product.Images = new List<ProductImage>();
                var imagesQuery = @"SELECT ImageUrl, IsDefault FROM ProductImage 
                                           WHERE ProductID = @ProductID ORDER BY ImageID";

                using (var cmd = new SqlCommand(imagesQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ProductID", productId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            product.Images.Add(new ProductImage
                            {
                                Url = reader.GetString(0),
                                ThumbUrl = reader.GetString(0)
                            });
                        }
                    }
                }
            }

            return product;
        }





        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AddToCartResponse AddToCart(int productId, int quantity, string size, string color)
        {
            try
            {
                if (HttpContext.Current.Session["CustomerID"] == null)
                {
                    return new AddToCartResponse
                    {
                        Success = false,
                        Message = "not_logged_in",
                        RedirectUrl = "Login.aspx?ReturnUrl=Shop.aspx"
                    };
                }

                int customerId = Convert.ToInt32(HttpContext.Current.Session["CustomerID"]);
                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    // Get or create cart
                    int cartId;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT CartID FROM Cart WHERE CustomerID = @CustomerID AND IsActive = 1", con))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerId);
                        object result = cmd.ExecuteScalar();

                        if (result == null)
                        {
                            cmd.CommandText = "INSERT INTO Cart (CustomerID) VALUES (@CustomerID); SELECT SCOPE_IDENTITY();";
                            cartId = Convert.ToInt32(cmd.ExecuteScalar());
                        }
                        else
                        {
                            cartId = Convert.ToInt32(result);
                        }
                    }

                    // Check if product with same size/color already in cart
                    bool exists = false;
                    int existingQuantity = 0;
                    int existingCartItemId = 0;

                    // Modified query to properly handle NULL comparisons
                    string checkQuery = @"
                        SELECT CartItemID, Quantity FROM CartItems 
                        WHERE CartID = @CartID 
                        AND ProductID = @ProductID 
                        AND ISNULL(Size, '') = ISNULL(@Size, '') 
                        AND ISNULL(Color, '') = ISNULL(@Color, '')";

                    using (SqlCommand cmd = new SqlCommand(checkQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@CartID", cartId);
                        cmd.Parameters.AddWithValue("@ProductID", productId);
                        cmd.Parameters.AddWithValue("@Size", string.IsNullOrEmpty(size) ? (object)DBNull.Value : size);
                        cmd.Parameters.AddWithValue("@Color", string.IsNullOrEmpty(color) ? (object)DBNull.Value : color);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                exists = true;
                                existingCartItemId = reader.GetInt32(0);
                                existingQuantity = reader.GetInt32(1);
                            }
                        }
                    }

                    // Get product price
                    decimal price;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT Price FROM Product WHERE ProductID = @ProductID", con))
                    {
                        cmd.Parameters.AddWithValue("@ProductID", productId);
                        price = Convert.ToDecimal(cmd.ExecuteScalar());
                    }

                    if (exists)
                    {
                        // Update existing item
                        using (SqlCommand cmd = new SqlCommand(
                            @"UPDATE CartItems 
                              SET Quantity = Quantity + @Quantity 
                              WHERE CartItemID = @CartItemID", con))
                        {
                            cmd.Parameters.AddWithValue("@CartItemID", existingCartItemId);
                            cmd.Parameters.AddWithValue("@Quantity", quantity);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        // Add new item
                        using (SqlCommand cmd = new SqlCommand(
                            @"INSERT INTO CartItems (CartID, ProductID, Quantity, Price, Size, Color, AddedAt) 
                              VALUES (@CartID, @ProductID, @Quantity, @Price, @Size, @Color, GETDATE())", con))
                        {
                            cmd.Parameters.AddWithValue("@CartID", cartId);
                            cmd.Parameters.AddWithValue("@ProductID", productId);
                            cmd.Parameters.AddWithValue("@Quantity", quantity);
                            cmd.Parameters.AddWithValue("@Price", price);
                            cmd.Parameters.AddWithValue("@Size", string.IsNullOrEmpty(size) ? (object)DBNull.Value : size);
                            cmd.Parameters.AddWithValue("@Color", string.IsNullOrEmpty(color) ? (object)DBNull.Value : color);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    return new AddToCartResponse
                    {
                        Success = true,
                        Message = "Product added to cart successfully!",
                        CartCount = GetCartCount(customerId)
                    };
                }
            }
            catch (Exception ex)
            {
                return new AddToCartResponse
                {
                    Success = false,
                    Message = "Error adding product to cart: " + ex.Message
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
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AddToCartResponse AddToWishlist(int productId = 0)
        {
            try
            {
                if (productId <= 0)
                {
                    return new AddToCartResponse
                    {
                        Success = false,
                        Message = "Invalid product ID"
                    };
                }
               

                if (HttpContext.Current.Session["CustomerID"] == null)
                {
                    return new AddToCartResponse
                    {
                        Success = false,
                        Message = "not_logged_in",
                        RedirectUrl = "Login.aspx?ReturnUrl=Shop.aspx"
                    };
                }

                int customerId = Convert.ToInt32(HttpContext.Current.Session["CustomerID"]);
                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    // Debug: Check if product exists
                    bool productExists = false;
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Product WHERE ProductID = @ProductID", con))
                    {
                        cmd.Parameters.AddWithValue("@ProductID", productId);
                        productExists = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                    }

                    if (!productExists)
                    {
                        return new AddToCartResponse
                        {
                            Success = false,
                            Message = "Product does not exist"
                        };
                    }

                    // Check if product already exists in wishlist
                    bool existsInWishlist = false;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Wishlist WHERE CustomerID = @CustomerID AND ProductID = @ProductID", con))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerId);
                        cmd.Parameters.AddWithValue("@ProductID", productId);
                        existsInWishlist = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                    }

                    if (existsInWishlist)
                    {
                        return new AddToCartResponse
                        {
                            Success = false,
                            Message = "This product is already in your wishlist!"
                        };
                    }

                    // Add to wishlist
                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO Wishlist (CustomerID, ProductID, CreatedAt) VALUES (@CustomerID, @ProductID, GETDATE())", con))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerId);
                        cmd.Parameters.AddWithValue("@ProductID", productId);
                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected == 0)
                        {
                            return new AddToCartResponse
                            {
                                Success = false,
                                Message = "Failed to add to wishlist - no rows affected"
                            };
                        }
                    }

                    return new AddToCartResponse
                    {
                        Success = true,
                        Message = "Product added to wishlist successfully!"
                    };
                }
            }
            catch (Exception ex)
            {
                // Log the full error details
                string errorDetails = $"Error adding to wishlist: {ex.Message}";
                if (ex.InnerException != null)
                {
                    errorDetails += $" | Inner Exception: {ex.InnerException.Message}";
                }

                return new AddToCartResponse
                {
                    Success = false,
                    Message = errorDetails
                };
            }
        }


        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static List<ProductSearchResult> SearchProducts(string searchTerm)
        {
            List<ProductSearchResult> results = new List<ProductSearchResult>();

            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"SELECT p.ProductID, p.ProductName, p.Price, p.Gender, 
                        COALESCE(pi.ImageUrl, 'default-product.jpg') AS ImageUrl
                        FROM Product p
                        LEFT JOIN ProductImage pi ON p.ProductID = pi.ProductID AND pi.IsDefault = 1
                        WHERE p.IsActive = 1 
                        AND (p.ProductName LIKE '%' + @SearchTerm + '%' 
                             OR p.ShortDescription LIKE '%' + @SearchTerm + '%'
                             OR p.Description LIKE '%' + @SearchTerm + '%')";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SearchTerm", searchTerm);
                    con.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            results.Add(new ProductSearchResult
                            {
                                ProductID = reader.GetInt32(0),
                                ProductName = reader.GetString(1),
                                Price = reader.GetDecimal(2),
                                Gender = reader.IsDBNull(3) ? null : reader.GetString(3),
                                ImageUrl = reader.GetString(4)
                            });
                        }
                    }
                }
            }

            return results;
        }
    }

    public class ProductSearchResult
    {
        public int ProductID { get; set; }
        public string ProductName { get; set; }
        public decimal Price { get; set; }
        public string Gender { get; set; }
        public string ImageUrl { get; set; }
    }


    public class ProductQuickView
    {
        public int Id { get; set; }
        public string Name { get; set; }
        
        public string ShortDescription { get; set; }
        public List<ProductImage> Images { get; set; }
        public List<ProductOption> Sizes { get; set; }
        public List<ProductOption> Colors { get; set; }


        public decimal Price { get; set; }
        public string FormattedPrice => "Rs. " + Price.ToString("0.00");
    }

    public class ProductImage
    {
        public string Url { get; set; }
        public string ThumbUrl { get; set; }
    }

    public class ProductOption
    {
        public string Name { get; set; }
    }

    public class AddToCartResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public int CartCount { get; set; }
        public string RedirectUrl { get; set; }
    }
}