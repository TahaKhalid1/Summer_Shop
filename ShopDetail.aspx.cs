














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
using System.Web.UI;
using System.Diagnostics;

namespace Next_ae.User
{
    public partial class ShopDetail : System.Web.UI.Page
    {
        public class AddToCartResponse
        {
            public bool Success { get; set; }
            public string Message { get; set; }
            public string RedirectUrl { get; set; }
            public int CartCount { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["id"] != null)
                {
                    int productId;
                    if (int.TryParse(Request.QueryString["id"], out productId))
                    {
                        hdnProductId.Value = productId.ToString();
                        LoadProductDetails(productId);
                        LoadRelatedProducts(productId);
                        LoadProductReviews(productId);
                    }
                    else
                    {
                        Response.Redirect("Shop.aspx");
                    }
                }
                else
                {

                    Response.Redirect("Shop.aspx");
                }
            }
            else
            {
                btnSubmitReview.Enabled = true;
                btnSubmitReview.Text = "Submit";
            }
        }

        private void LoadProductDetails(int productId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                // Get product details
                string productQuery = @"SELECT p.ProductName, p.Price, p.ShortDescription, p.Description, 
                      p.Size, p.Color, p.Weight, p.Dimensions, p.SKU, 
                      p.CategoryID, c.CategoryName, p.SubCategoryID, sc.SubCategoryName, 
                      p.Gender, p.Tags
                      FROM Product p
                      LEFT JOIN Category c ON p.CategoryID = c.CategoryID
                      LEFT JOIN SubCategory sc ON p.SubCategoryID = sc.SubCategoryID
                      WHERE p.ProductID = @ProductID AND p.IsActive = 1";

                using (SqlCommand cmd = new SqlCommand(productQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ProductID", productId);
                    con.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // Set product information
                            ltProductName.Text = reader["ProductName"].ToString();
                            ltPrice.Text = "Rs. " + Convert.ToDecimal(reader["Price"]).ToString("0.00");
                            ltShortDescription.Text = reader["ShortDescription"].ToString();
                            ltDescription.Text = reader["Description"].ToString();
                            ltWeight.Text = reader["Weight"] != DBNull.Value ? reader["Weight"].ToString() + " kg" : "N/A";
                            ltDimensions.Text = reader["Dimensions"] != DBNull.Value ? reader["Dimensions"].ToString() : "N/A";
                            ltSKU.Text = reader["SKU"] != DBNull.Value ? reader["SKU"].ToString() : "N/A";

                            // Set categories
                            string categories = "";
                            if (reader["CategoryName"] != DBNull.Value)
                            {
                                categories += reader["CategoryName"].ToString();
                            }
                            if (reader["SubCategoryName"] != DBNull.Value)
                            {
                                if (!string.IsNullOrEmpty(categories))
                                    categories += ", ";
                                categories += reader["SubCategoryName"].ToString();
                            }

                            ltCategories.Text = categories;

                            // Set available sizes and colors
                            string sizes = reader["Size"] != DBNull.Value ? reader["Size"].ToString() : "";
                            string colors = reader["Color"] != DBNull.Value ? reader["Color"].ToString() : "";

                            ltAvailableSizes.Text = sizes;
                            ltAvailableColors.Text = colors;

                            // Populate size dropdown
                            ddlSizes.Items.Clear();
                            ddlSizes.Items.Add(new ListItem("Choose an option", ""));
                            if (!string.IsNullOrEmpty(sizes))
                            {
                                string[] sizeArray = sizes.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                                foreach (string size in sizeArray)
                                {
                                    ddlSizes.Items.Add(new ListItem(size.Trim(), size.Trim()));
                                }
                            }

                            // Populate color dropdown
                            ddlColors.Items.Clear();
                            ddlColors.Items.Add(new ListItem("Choose an option", ""));
                            if (!string.IsNullOrEmpty(colors))
                            {
                                string[] colorArray = colors.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                                foreach (string color in colorArray)
                                {
                                    ddlColors.Items.Add(new ListItem(color.Trim(), color.Trim()));
                                }
                            }
                        }
                        else
                        {
                            // Product not found
                            Response.Redirect("Shop.aspx");
                        }
                    }
                }

                // Get product images
                string imagesQuery = @"SELECT pi.ImageUrl, 
                      p.ProductName + ' image ' + CAST(ROW_NUMBER() OVER (ORDER BY pi.ImageID) AS nvarchar) AS AltText 
                      FROM ProductImage pi
                      INNER JOIN Product p ON pi.ProductID = p.ProductID
                      WHERE pi.ProductID = @ProductID 
                      ORDER BY CASE WHEN pi.IsDefault = 1 THEN 0 ELSE 1 END, pi.ImageID";

                using (SqlCommand cmd = new SqlCommand(imagesQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ProductID", productId);
                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    sda.Fill(dt);

                    rptProductImages.DataSource = dt;
                    rptProductImages.DataBind();
                }

                // Get product reviews
                string reviewsQuery = @"SELECT r.Rating, r.Comment AS ReviewText, r.ReviewDate AS CreatedDate, 
                      ISNULL(c.FirstName + ' ' + c.LastName, 'Anonymous') AS CustomerName,
                      'avatar-01.jpg' AS AvatarUrl
                      FROM Review r
                      LEFT JOIN Customer c ON r.CustomerID = c.CustomerID
                      WHERE r.ProductID = @ProductID 
                      ORDER BY r.ReviewDate DESC";

                using (SqlCommand cmd = new SqlCommand(reviewsQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ProductID", productId);
                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    sda.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptReviews.DataSource = dt;
                        rptReviews.DataBind();
                        lblNoReviews.Visible = false;
                    }
                    else
                    {
                        rptReviews.DataSource = null;
                        rptReviews.DataBind();
                        lblNoReviews.Visible = true;
                    }
                }
            }
        }

        private void LoadRelatedProducts(int productId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                // Get related products (same category or similar tags)
                string query = @"SELECT TOP 8 p.ProductID, p.ProductName, p.Price, 
                               COALESCE(pi.ImageUrl, 'default-product.jpg') AS ImageUrl
                               FROM Product p
                               LEFT JOIN ProductImage pi ON p.ProductID = pi.ProductID AND pi.IsDefault = 1
                               WHERE p.ProductID != @ProductID AND p.IsActive = 1
                               AND (p.CategoryID IN (SELECT CategoryID FROM Product WHERE ProductID = @ProductID)
                                    OR EXISTS (
                                        SELECT 1 FROM STRING_SPLIT((SELECT Tags FROM Product WHERE ProductID = @ProductID), ',') AS t1
                                        CROSS APPLY STRING_SPLIT(p.Tags, ',') AS t2
                                        WHERE t1.value = t2.value
                                    ))
                               ORDER BY NEWID()";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@ProductID", productId);
                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    sda.Fill(dt);

                    rptRelatedProducts.DataSource = dt;
                    rptRelatedProducts.DataBind();
                }
            }
        }



        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static AddToCartResponse AddToCart(int productId, int quantity, string size, string color)
        {
            try
            {
                var context = HttpContext.Current;
                if (context.Session["CustomerID"] == null)
                {
                    // Include the current product page URL in the redirect
                    string currentUrl = context.Request.UrlReferrer?.AbsoluteUri ?? "ShopDetail.aspx?id=" + productId;
                    return new AddToCartResponse
                    {
                        Success = false,
                        Message = "not_logged_in",
                        RedirectUrl = "Login.aspx?ReturnUrl=" + HttpUtility.UrlEncode(currentUrl)
                    };
                }

                int customerId = Convert.ToInt32(HttpContext.Current.Session["CustomerID"]);
                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();

                    // Get or create cart
                    int cartId;
                    using (SqlCommand cmd = new SqlCommand("SELECT CartID FROM Cart WHERE CustomerID = @CustomerID AND IsActive = 1", con))
                    {
                        cmd.Parameters.AddWithValue("@CustomerID", customerId);
                        object result = cmd.ExecuteScalar();
                        cartId = result == null ?
                            Convert.ToInt32(new SqlCommand("INSERT INTO Cart (CustomerID) VALUES (@CustomerID); SELECT SCOPE_IDENTITY();", con)
                            {
                                Parameters = { new SqlParameter("@CustomerID", customerId) }
                            }.ExecuteScalar()) :
                            Convert.ToInt32(result);
                    }

                    // Check if item exists in cart
                    bool exists = false;
                    int existingId = 0;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT CartItemID FROM CartItems WHERE CartID = @CartID AND ProductID = @ProductID AND " +
                        "ISNULL(Size,'') = ISNULL(@Size,'') AND ISNULL(Color,'') = ISNULL(@Color,'')", con))
                    {
                        cmd.Parameters.AddWithValue("@CartID", cartId);
                        cmd.Parameters.AddWithValue("@ProductID", productId);
                        cmd.Parameters.AddWithValue("@Size", string.IsNullOrEmpty(size) ? (object)DBNull.Value : size);
                        cmd.Parameters.AddWithValue("@Color", string.IsNullOrEmpty(color) ? (object)DBNull.Value : color);

                        object result = cmd.ExecuteScalar();
                        exists = result != null;
                        if (exists) existingId = Convert.ToInt32(result);
                    }

                    // Get product price
                    decimal price = Convert.ToDecimal(
                        new SqlCommand("SELECT Price FROM Product WHERE ProductID = @ProductID", con)
                        {
                            Parameters = { new SqlParameter("@ProductID", productId) }
                        }.ExecuteScalar());

                    if (exists)
                    {
                        new SqlCommand(
                            "UPDATE CartItems SET Quantity = Quantity + @Quantity WHERE CartItemID = @CartItemID", con)
                        {
                            Parameters = {
                            new SqlParameter("@Quantity", quantity),
                            new SqlParameter("@CartItemID", existingId)
                        }
                        }.ExecuteNonQuery();
                    }
                    else
                    {
                        new SqlCommand(
                            "INSERT INTO CartItems (CartID, ProductID, Quantity, Price, Size, Color, AddedAt) " +
                            "VALUES (@CartID, @ProductID, @Quantity, @Price, @Size, @Color, GETDATE())", con)
                        {
                            Parameters = {
                            new SqlParameter("@CartID", cartId),
                            new SqlParameter("@ProductID", productId),
                            new SqlParameter("@Quantity", quantity),
                            new SqlParameter("@Price", price),
                            new SqlParameter("@Size", string.IsNullOrEmpty(size) ? (object)DBNull.Value : size),
                            new SqlParameter("@Color", string.IsNullOrEmpty(color) ? (object)DBNull.Value : color)
                        }
                        }.ExecuteNonQuery();
                    }

                    return new AddToCartResponse
                    {
                        Success = true,
                        Message = "Product added to cart!",
                        CartCount = GetCartCount(customerId)
                    };
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("AddToCart error: " + ex.ToString());
                return new AddToCartResponse
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

        // Add these at class level
        protected static bool lastReviewSubmitSuccess = false;
        protected static string lastReviewSubmitError = "";

        protected void btnSubmitReview_Click(object sender, EventArgs e)
        {
            try
            {
                Debug.WriteLine("Starting review submission...");

                if (!Page.IsValid)
                {
                    Debug.WriteLine("Page validation failed");
                    return;
                }

                int productId = int.Parse(hdnProductId.Value);
                Debug.WriteLine($"Product ID: {productId}");

                int rating = int.Parse(hdnRating.Value);
                Debug.WriteLine($"Rating: {rating}");

                string comment = txtReview.Text.Trim();
                Debug.WriteLine($"Comment length: {comment.Length}");

                string name = txtName.Text.Trim();
                Debug.WriteLine($"Name: {name}");

                string email = txtEmail.Text.Trim();
                Debug.WriteLine($"Email: {email}");

                // Allow guest reviews (CustomerID can be null)
                int? customerId = Session["CustomerID"] != null ?
                    Convert.ToInt32(Session["CustomerID"]) :
                    (int?)null;

                Debug.WriteLine($"Customer ID: {(customerId.HasValue ? customerId.Value.ToString() : "null")}");

                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
                Debug.WriteLine($"Connection string: {connectionString}");

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = @"INSERT INTO Review 
                       (CustomerID, ProductID, Rating, Comment, ReviewDate, Name, Email) 
                       VALUES 
                       (@CustomerID, @ProductID, @Rating, @Comment, GETDATE(), @Name, @Email)";

                    Debug.WriteLine($"SQL Query: {query}");

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        // Handle nullable CustomerID
                        if (customerId.HasValue)
                        {
                            cmd.Parameters.AddWithValue("@CustomerID", customerId.Value);
                            Debug.WriteLine("Added CustomerID parameter");
                        }
                        else
                        {
                            cmd.Parameters.AddWithValue("@CustomerID", DBNull.Value);
                            Debug.WriteLine("Added NULL CustomerID parameter");
                        }

                        cmd.Parameters.AddWithValue("@ProductID", productId);
                        Debug.WriteLine("Added ProductID parameter");

                        cmd.Parameters.AddWithValue("@Rating", rating);
                        Debug.WriteLine("Added Rating parameter");

                        cmd.Parameters.AddWithValue("@Comment", comment);
                        Debug.WriteLine("Added Comment parameter");

                        cmd.Parameters.AddWithValue("@Name", name);
                        Debug.WriteLine("Added Name parameter");

                        cmd.Parameters.AddWithValue("@Email", email);
                        Debug.WriteLine("Added Email parameter");

                        con.Open();
                        Debug.WriteLine("Database connection opened");

                        int rowsAffected = cmd.ExecuteNonQuery();
                        Debug.WriteLine($"Rows affected: {rowsAffected}");

                        if (rowsAffected > 0)
                        {
                            Debug.WriteLine("Review submitted successfully");
                            // Clear form and show success
                            txtReview.Text = "";
                            txtName.Text = "";
                            txtEmail.Text = "";
                            hdnRating.Value = "0";

                            // Reset star rating display
                            ScriptManager.RegisterStartupScript(this, GetType(), "resetStars",
                                "$('.star-rating i').removeClass('fas').addClass('far').css('color', '#d1d1d1');", true);

                            // Show success message
                            ScriptManager.RegisterStartupScript(this, GetType(), "showSuccess",
                                "swal('Success', 'Your review has been submitted!', 'success');", true);

                            // Reload reviews
                            LoadProductReviews(productId);
                        }
                        else
                        {
                            Debug.WriteLine("No rows affected - review not submitted");
                            ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                                "swal('Error', 'Failed to submit review. No database changes made.', 'error');", true);
                        }
                    }
                }
            }
            catch (SqlException sqlEx)
            {
                // Log SQL-specific errors
                string errorDetails = $"SQL Error submitting review:\n" +
                                     $"Error Number: {sqlEx.Number}\n" +
                                     $"Procedure: {sqlEx.Procedure}\n" +
                                     $"Line Number: {sqlEx.LineNumber}\n" +
                                     $"Message: {sqlEx.Message}\n" +
                                     $"Stack Trace: {sqlEx.StackTrace}";

                Debug.WriteLine(errorDetails);

                // Show detailed error message to developers but user-friendly message to users
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    $"swal('Database Error', 'An error occurred while saving your review. Please try again.', 'error');\n" +
                    $"console.error('SQL Error: {HttpUtility.JavaScriptStringEncode(errorDetails)}');", true);
            }
            catch (Exception ex)
            {
                // Log the full error details
                string errorDetails = $"Full error details:\n" +
                                     $"Message: {ex.Message}\n" +
                                     $"Stack Trace: {ex.StackTrace}";

                if (ex.InnerException != null)
                {
                    errorDetails += $"\nInner Exception:\n" +
                                    $"Message: {ex.InnerException.Message}\n" +
                                    $"Stack Trace: {ex.InnerException.StackTrace}";
                }

                Debug.WriteLine(errorDetails);

                // Show detailed error in console but user-friendly message
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    $"swal('Error', 'An error occurred while submitting your review. Please try again.', 'error');\n" +
                    $"console.error('Error: {HttpUtility.JavaScriptStringEncode(errorDetails)}');", true);
            }
            finally
            {
                btnSubmitReview.Enabled = true;
                btnSubmitReview.Text = "Submit";
                Debug.WriteLine("Review submission process completed");
            }
        }

        private void LoadProductReviews(int productId)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string reviewsQuery = @"SELECT r.Rating, r.Comment AS ReviewText, r.ReviewDate AS CreatedDate, 
                  ISNULL(c.FirstName + ' ' + c.LastName, 'Anonymous') AS CustomerName,
                  'avatar-01.jpg' AS AvatarUrl
                  FROM Review r
                  LEFT JOIN Customer c ON r.CustomerID = c.CustomerID
                  WHERE r.ProductID = @ProductID 
                  ORDER BY r.ReviewDate DESC";

                    using (SqlCommand cmd = new SqlCommand(reviewsQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@ProductID", productId);
                        SqlDataAdapter sda = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable(); 
                        sda.Fill(dt);

                        rptReviews.DataSource = dt;
                        rptReviews.DataBind();
                        lblNoReviews.Visible = dt.Rows.Count == 0;
                    }
                }

                // Update the reviews panel
                upReviews.Update();
            }
            catch (Exception ex)
            {
                Debug.WriteLine("Error loading reviews: " + ex.ToString());
            }
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

        public string GetStarRating(object ratingObj)
        {
            if (ratingObj == null || ratingObj == DBNull.Value)
                return string.Empty;

            int rating = Convert.ToInt32(ratingObj);
            string stars = string.Empty;

            for (int i = 0; i < rating; i++)
            {
                stars += "<i class='zmdi zmdi-star'></i>";
            }

            for (int i = rating; i < 5; i++)
            {
                stars += "<i class='zmdi zmdi-star-outline'></i>";
            }

            return stars;
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
    }
}










