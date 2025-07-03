    using System;
    using System.Data;
    using System.Data.SqlClient;
    using System.Configuration;
    using System.IO;
    using System.Web;
    using System.Web.UI;
    using System.Web.UI.WebControls;
    using System.Linq;
    using Newtonsoft.Json;

    namespace Next_ae.User
    {
        public partial class Productlisting : System.Web.UI.Page
        {
            protected void Page_Load(object sender, EventArgs e)
            {
                if (IsAjaxRequest())
                {
                    ProcessAjaxRequest();
                    return;
                }

                if (!IsPostBack)
                {
                    if (Session["IsAdminAuthenticated"] == null || !(bool)Session["IsAdminAuthenticated"])
                    {
                        Response.Redirect("adminlogin.aspx");
                    }

                    BindCategories();

                    if (Request.QueryString["id"] != null)
                    {
                        int productId = Convert.ToInt32(Request.QueryString["id"]);
                        LoadProductForEditing(productId);
                    }
                    else
                    {
                        // This is for adding a new product
                        txtProductCode.Text = "PROD-" + DateTime.Now.ToString("yyyyMMddHHmmss");
                    }
                 }
            }

            private bool IsAjaxRequest()
            {
                return Request.Headers["X-Requested-With"] == "XMLHttpRequest"
                    || Request.Headers["Accept"]?.Contains("application/json") == true;
            }

            private void ProcessAjaxRequest()
            {
                Response.Clear();
                Response.ContentType = "application/json";

                try
                {
                    // Process the form submission
                    btnPublishProduct_Click(btnPublishProduct, EventArgs.Empty);

                    Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = true,
                        message = "Product saved successfully"
                    }));
                }
                catch (Exception ex)
                {
                    Response.Write(JsonConvert.SerializeObject(new
                    {
                        success = false,
                        message = "Error: " + ex.Message
                    }));
                }
                finally
                {
                    Response.End();
                }
            }

            private void BindCategories()
            {
                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = "SELECT CategoryID, CategoryName FROM Category WHERE IsActive = 1";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        con.Open();
                        SqlDataReader reader = cmd.ExecuteReader();
                        ddlCategory.DataSource = reader;
                        ddlCategory.DataTextField = "CategoryName";
                        ddlCategory.DataValueField = "CategoryID";
                        ddlCategory.DataBind();
                        ddlCategory.Items.Insert(0, new ListItem("-- Select Category --", "0"));
                    }
                }
            }

            protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
            {
                int categoryId;
                if (int.TryParse(ddlCategory.SelectedValue, out categoryId) && categoryId > 0)
                {
                    string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

                    using (SqlConnection con = new SqlConnection(connectionString))
                    {
                        string query = "SELECT SubCategoryID, SubCategoryName FROM SubCategory WHERE CategoryID = @CategoryID AND IsActive = 1";
                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@CategoryID", categoryId);
                            con.Open();
                            SqlDataReader reader = cmd.ExecuteReader();
                            ddlSubCategory.DataSource = reader;
                            ddlSubCategory.DataTextField = "SubCategoryName";
                            ddlSubCategory.DataValueField = "SubCategoryID";
                            ddlSubCategory.DataBind();
                            ddlSubCategory.Items.Insert(0, new ListItem("-- Select SubCategory --", "0"));
                        }
                    }
                }
                else
                {
                    ddlSubCategory.Items.Clear();
                    ddlSubCategory.Items.Insert(0, new ListItem("-- Select SubCategory --", "0"));
                }
            }

        private void LoadProductForEditing(int productId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                // Load product details
                string productQuery = @"SELECT p.ProductCode, p.ProductName, p.Description, p.ShortDescription, 
                              p.Price, p.CompareAtPrice, p.CostPerItem, p.Quantity, p.StockStatus, 
                              p.TaxClass, p.IsActive, p.Weight, p.Dimensions, p.Color, p.Size, 
                              p.Brand, p.Tags, p.SKU, p.Barcode, p.VideoUrl, 
                              p.CategoryID, p.SubCategoryID
                              FROM Product p
                              WHERE p.ProductID = @ProductID";

                using (SqlCommand cmd = new SqlCommand(productQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ProductID", productId);
                    con.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        txtProductCode.Text = reader["ProductCode"].ToString();
                        txtProductName.Text = reader["ProductName"].ToString();
                        txtDescription.Text = reader["Description"].ToString();
                        txtShortDescription.Text = reader["ShortDescription"].ToString();
                        txtPrice.Text = reader["Price"].ToString();
                        txtCompareAtPrice.Text = reader["CompareAtPrice"].ToString();
                        txtCostPerItem.Text = reader["CostPerItem"].ToString();
                        txtQuantity.Text = reader["Quantity"].ToString();
                        ddlStockStatus.SelectedValue = reader["StockStatus"].ToString();

                        if (reader["TaxClass"] != DBNull.Value)
                            ddlTaxClass.SelectedValue = reader["TaxClass"].ToString();

                        cbPublishStatus.Checked = Convert.ToBoolean(reader["IsActive"]);

                        if (reader["Weight"] != DBNull.Value)
                            txtWeight.Text = reader["Weight"].ToString();

                        if (reader["Dimensions"] != DBNull.Value)
                        {
                            string[] dimensions = reader["Dimensions"].ToString().Split('x');
                            if (dimensions.Length == 3)
                            {
                                txtLength.Text = dimensions[0];
                                txtWidth.Text = dimensions[1];
                                txtHeight.Text = dimensions[2];
                            }
                        }

                        if (reader["Color"] != DBNull.Value)
                            txtColor.Text = reader["Color"].ToString();

                        if (reader["Size"] != DBNull.Value)
                            txtSize.Text = reader["Size"].ToString();

                        if (reader["Brand"] != DBNull.Value)
                            txtBrand.Text = reader["Brand"].ToString();

                        if (reader["Tags"] != DBNull.Value)
                            txtTags.Text = reader["Tags"].ToString();

                        txtSKU.Text = reader["SKU"].ToString();

                        if (reader["Barcode"] != DBNull.Value)
                            txtBarcode.Text = reader["Barcode"].ToString();

                        if (reader["VideoUrl"] != DBNull.Value)
                            txtVideoUrl.Text = reader["VideoUrl"].ToString();

                        if (reader["CategoryID"] != DBNull.Value)
                        {
                            ddlCategory.SelectedValue = reader["CategoryID"].ToString();
                            ddlCategory_SelectedIndexChanged(ddlCategory, EventArgs.Empty);

                            if (reader["SubCategoryID"] != DBNull.Value)
                                ddlSubCategory.SelectedValue = reader["SubCategoryID"].ToString();
                        }
                    }
                    reader.Close();

                    // Load product images
                    string imageQuery = @"SELECT ImageUrl, IsDefault FROM ProductImage 
                                WHERE ProductID = @ProductID
                                ORDER BY IsDefault DESC";

                    using (SqlCommand imageCmd = new SqlCommand(imageQuery, con))
                    {
                        imageCmd.Parameters.AddWithValue("@ProductID", productId);
                        SqlDataReader imageReader = imageCmd.ExecuteReader();

                        bool firstImage = true;
                        while (imageReader.Read())
                        {
                            if (firstImage && imageReader["IsDefault"].ToString() == "True")
                            {
                                // Set main image preview
                                imgPreview.ImageUrl = imageReader["ImageUrl"].ToString();
                                imgPreview.Visible = true;
                                firstImage = false;
                            }
                            // You could also load gallery images here
                        }
                        imageReader.Close();
                    }
                }
            }
        }

        protected void btnPublishProduct_Click(object sender, EventArgs e)
        {
            try
            {
                // Validate required fields
                if (ddlCategory.SelectedValue == "0")
                    throw new Exception("Please select a category");

                if (string.IsNullOrWhiteSpace(txtProductName.Text))
                    throw new Exception("Product name is required");

                if (string.IsNullOrWhiteSpace(txtDescription.Text))
                    throw new Exception("Description is required");

                if (string.IsNullOrWhiteSpace(txtSKU.Text))
                    throw new Exception("SKU is required");

                if (!fileMainImage.HasFile && Request.QueryString["id"] == null)
                    throw new Exception("Main product image is required");

                if (string.IsNullOrWhiteSpace(txtPrice.Text) || !decimal.TryParse(txtPrice.Text, out _))
                    throw new Exception("Valid price is required");

                if (string.IsNullOrWhiteSpace(txtQuantity.Text) || !int.TryParse(txtQuantity.Text, out _))
                    throw new Exception("Valid quantity is required");

                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

                // Get form values
                string productName = txtProductName.Text.Trim();
                string description = txtDescription.Text.Trim();
                string shortDescription = txtShortDescription.Text.Trim();
                string brand = txtBrand.Text.Trim();
                string tags = txtTags.Text.Trim();
                string sku = txtSKU.Text.Trim();
                string barcode = txtBarcode.Text.Trim();
                decimal price = decimal.Parse(txtPrice.Text);
                decimal compareAtPrice = string.IsNullOrEmpty(txtCompareAtPrice.Text) ? 0 : decimal.Parse(txtCompareAtPrice.Text);
                decimal costPerItem = string.IsNullOrEmpty(txtCostPerItem.Text) ? 0 : decimal.Parse(txtCostPerItem.Text);
                int quantity = int.Parse(txtQuantity.Text);
                string stockStatus = ddlStockStatus.SelectedValue;
                string taxClass = ddlTaxClass.SelectedValue;
                bool isActive = cbPublishStatus.Checked;
                string weight = txtWeight.Text.Trim();
                string dimensions = $"{txtLength.Text.Trim()}x{txtWidth.Text.Trim()}x{txtHeight.Text.Trim()}";
                string color = txtColor.Text.Trim();
                string size = txtSize.Text.Trim();
                string videoUrl = txtVideoUrl.Text.Trim();
                int categoryID = int.Parse(ddlCategory.SelectedValue);
                int subCategoryID = ddlSubCategory.SelectedValue == "0" ? 0 : int.Parse(ddlSubCategory.SelectedValue);
                string productCode = txtProductCode.Text.Trim();

                // Check if we're editing an existing product
                bool isEditMode = Request.QueryString["id"] != null;
                int productId = isEditMode ? Convert.ToInt32(Request.QueryString["id"]) : 0;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();
                    using (SqlTransaction transaction = con.BeginTransaction())
                    {
                        try
                        {
                            if (isEditMode)
                            {
                                // Update existing product
                                string updateQuery = @"UPDATE Product SET
                                            ProductCode = @ProductCode,
                                            ProductName = @ProductName,
                                            Description = @Description,
                                            ShortDescription = @ShortDescription,
                                            Price = @Price,
                                            CompareAtPrice = @CompareAtPrice,
                                            CostPerItem = @CostPerItem,
                                            Quantity = @Quantity,
                                            StockStatus = @StockStatus,
                                            TaxClass = @TaxClass,
                                            IsActive = @IsActive,
                                            Weight = @Weight,
                                            Dimensions = @Dimensions,
                                            Color = @Color,
                                            Size = @Size,
                                            Brand = @Brand,
                                            Tags = @Tags,
                                            SKU = @SKU,
                                            Barcode = @Barcode,
                                            VideoUrl = @VideoUrl,
                                            CategoryID = @CategoryID,
                                            SubCategoryID = @SubCategoryID,
                                            CreatedAt = GETDATE()
                                            WHERE ProductID = @ProductID";

                                using (SqlCommand cmd = new SqlCommand(updateQuery, con, transaction))
                                {
                                    cmd.Parameters.AddWithValue("@ProductID", productId);
                                    cmd.Parameters.AddWithValue("@ProductCode", productCode);
                                    cmd.Parameters.AddWithValue("@ProductName", productName);
                                    cmd.Parameters.AddWithValue("@Description", description);
                                    cmd.Parameters.AddWithValue("@ShortDescription", shortDescription);
                                    cmd.Parameters.AddWithValue("@Price", price);
                                    cmd.Parameters.AddWithValue("@CompareAtPrice", compareAtPrice);
                                    cmd.Parameters.AddWithValue("@CostPerItem", costPerItem);
                                    cmd.Parameters.AddWithValue("@Quantity", quantity);
                                    cmd.Parameters.AddWithValue("@StockStatus", stockStatus);
                                    cmd.Parameters.AddWithValue("@TaxClass", string.IsNullOrEmpty(taxClass) ? (object)DBNull.Value : taxClass);
                                    cmd.Parameters.AddWithValue("@IsActive", isActive);
                                    cmd.Parameters.AddWithValue("@Weight", string.IsNullOrEmpty(weight) ? (object)DBNull.Value : decimal.Parse(weight));
                                    cmd.Parameters.AddWithValue("@Dimensions", string.IsNullOrEmpty(dimensions) ? (object)DBNull.Value : dimensions);
                                    cmd.Parameters.AddWithValue("@Color", string.IsNullOrEmpty(color) ? (object)DBNull.Value : color);
                                    cmd.Parameters.AddWithValue("@Size", string.IsNullOrEmpty(size) ? (object)DBNull.Value : size);
                                    cmd.Parameters.AddWithValue("@Brand", string.IsNullOrEmpty(brand) ? (object)DBNull.Value : brand);
                                    cmd.Parameters.AddWithValue("@Tags", string.IsNullOrEmpty(tags) ? (object)DBNull.Value : tags);
                                    cmd.Parameters.AddWithValue("@SKU", string.IsNullOrEmpty(sku) ? (object)DBNull.Value : sku);
                                    cmd.Parameters.AddWithValue("@Barcode", string.IsNullOrEmpty(barcode) ? (object)DBNull.Value : barcode);
                                    cmd.Parameters.AddWithValue("@VideoUrl", string.IsNullOrEmpty(videoUrl) ? (object)DBNull.Value : videoUrl);
                                    cmd.Parameters.AddWithValue("@CategoryID", categoryID);
                                    cmd.Parameters.AddWithValue("@SubCategoryID", subCategoryID == 0 ? (object)DBNull.Value : subCategoryID);

                                    cmd.ExecuteNonQuery();
                                }

                                // Delete existing images if new ones are uploaded
                                if (fileMainImage.HasFile || fileGalleryImages.HasFiles)
                                {
                                    string deleteImagesQuery = "DELETE FROM ProductImage WHERE ProductID = @ProductID";
                                    using (SqlCommand deleteCmd = new SqlCommand(deleteImagesQuery, con, transaction))
                                    {
                                        deleteCmd.Parameters.AddWithValue("@ProductID", productId);
                                        deleteCmd.ExecuteNonQuery();
                                    }
                                }
                            }
                            else
                            {
                                // Insert new product
                                string insertQuery = @"INSERT INTO Product (
                                            ProductCode, ProductName, Description, ShortDescription, Price, CompareAtPrice, CostPerItem, 
                                            Quantity, StockStatus, TaxClass, IsActive, Weight, Dimensions, Color, Size, 
                                            Brand, Tags, SKU, Barcode, VideoUrl, CategoryID, SubCategoryID, CreatedAt
                                        ) VALUES (
                                            @ProductCode, @ProductName, @Description, @ShortDescription, @Price, @CompareAtPrice, @CostPerItem, 
                                            @Quantity, @StockStatus, @TaxClass, @IsActive, @Weight, @Dimensions, @Color, @Size, 
                                            @Brand, @Tags, @SKU, @Barcode, @VideoUrl, @CategoryID, @SubCategoryID, GETDATE()
                                        ); SELECT SCOPE_IDENTITY();";

                                using (SqlCommand cmd = new SqlCommand(insertQuery, con, transaction))
                                {
                                    cmd.Parameters.AddWithValue("@ProductCode", productCode);
                                    cmd.Parameters.AddWithValue("@ProductName", productName);
                                    cmd.Parameters.AddWithValue("@Description", description);
                                    cmd.Parameters.AddWithValue("@ShortDescription", shortDescription);
                                    cmd.Parameters.AddWithValue("@Price", price);
                                    cmd.Parameters.AddWithValue("@CompareAtPrice", compareAtPrice);
                                    cmd.Parameters.AddWithValue("@CostPerItem", costPerItem);
                                    cmd.Parameters.AddWithValue("@Quantity", quantity);
                                    cmd.Parameters.AddWithValue("@StockStatus", stockStatus);
                                    cmd.Parameters.AddWithValue("@TaxClass", string.IsNullOrEmpty(taxClass) ? (object)DBNull.Value : taxClass);
                                    cmd.Parameters.AddWithValue("@IsActive", isActive);
                                    cmd.Parameters.AddWithValue("@Weight", string.IsNullOrEmpty(weight) ? (object)DBNull.Value : decimal.Parse(weight));
                                    cmd.Parameters.AddWithValue("@Dimensions", string.IsNullOrEmpty(dimensions) ? (object)DBNull.Value : dimensions);
                                    cmd.Parameters.AddWithValue("@Color", string.IsNullOrEmpty(color) ? (object)DBNull.Value : color);
                                    cmd.Parameters.AddWithValue("@Size", string.IsNullOrEmpty(size) ? (object)DBNull.Value : size);
                                    cmd.Parameters.AddWithValue("@Brand", string.IsNullOrEmpty(brand) ? (object)DBNull.Value : brand);
                                    cmd.Parameters.AddWithValue("@Tags", string.IsNullOrEmpty(tags) ? (object)DBNull.Value : tags);
                                    cmd.Parameters.AddWithValue("@SKU", string.IsNullOrEmpty(sku) ? (object)DBNull.Value : sku);
                                    cmd.Parameters.AddWithValue("@Barcode", string.IsNullOrEmpty(barcode) ? (object)DBNull.Value : barcode);
                                    cmd.Parameters.AddWithValue("@VideoUrl", string.IsNullOrEmpty(videoUrl) ? (object)DBNull.Value : videoUrl);
                                    cmd.Parameters.AddWithValue("@CategoryID", categoryID);
                                    cmd.Parameters.AddWithValue("@SubCategoryID", subCategoryID == 0 ? (object)DBNull.Value : subCategoryID);

                                    productId = Convert.ToInt32(cmd.ExecuteScalar());
                                }
                            }

                            // Handle main image upload
                            if (fileMainImage.HasFile)
                            {
                                SaveUploadedImage(fileMainImage.PostedFile, productId, true, con, transaction);
                            }

                            // Handle gallery images
                            if (fileGalleryImages.HasFiles)
                            {
                                foreach (HttpPostedFile file in fileGalleryImages.PostedFiles)
                                {
                                    SaveUploadedImage(file, productId, false, con, transaction);
                                }
                            }

                            transaction.Commit();

                            if (!IsAjaxRequest())
                            {
                                string message = isEditMode ? "Product updated successfully!" : "Product added successfully!";
                                ShowSuccessMessage(message);

                                if (!isEditMode)
                                {
                                    ResetForm();
                                }
                                else
                                {
                                    // Refresh the page to show updated data
                                    Response.Redirect($"Productlisting.aspx?id={productId}");
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            if (!IsAjaxRequest())
                            {
                                ShowErrorMessage("Error saving product: " + ex.Message);
                            }
                            throw;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                if (!IsAjaxRequest())
                {
                    ShowErrorMessage("Error: " + ex.Message);
                }
                else
                {
                    throw;
                }
            }
        }

        //protected void btnPublishProduct_Click(object sender, EventArgs e)
        //    {
        //        try
        //        {
        //            // Validate required fields
        //            if (ddlCategory.SelectedValue == "0")
        //                throw new Exception("Please select a category");

        //            if (string.IsNullOrWhiteSpace(txtProductName.Text))
        //                throw new Exception("Product name is required");

        //            if (string.IsNullOrWhiteSpace(txtDescription.Text))
        //                throw new Exception("Description is required");

        //            if (string.IsNullOrWhiteSpace(txtSKU.Text))
        //                throw new Exception("SKU is required");

        //            if (!fileMainImage.HasFile)
        //                throw new Exception("Main product image is required");

        //            if (string.IsNullOrWhiteSpace(txtPrice.Text) || !decimal.TryParse(txtPrice.Text, out _))
        //                throw new Exception("Valid price is required");

        //            if (string.IsNullOrWhiteSpace(txtQuantity.Text) || !int.TryParse(txtQuantity.Text, out _))
        //                throw new Exception("Valid quantity is required");





        //            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

        //            // Get form values

        //            string productName = txtProductName.Text.Trim();
        //            string description = txtDescription.Text.Trim();
        //            string shortDescription = txtShortDescription.Text.Trim();
        //            string brand = txtBrand.Text.Trim();
        //            string tags = txtTags.Text.Trim();
        //            string sku = txtSKU.Text.Trim();
        //            string barcode = txtBarcode.Text.Trim();
        //            decimal price = decimal.Parse(txtPrice.Text);
        //            decimal compareAtPrice = string.IsNullOrEmpty(txtCompareAtPrice.Text) ? 0 : decimal.Parse(txtCompareAtPrice.Text);
        //            decimal costPerItem = string.IsNullOrEmpty(txtCostPerItem.Text) ? 0 : decimal.Parse(txtCostPerItem.Text);
        //            int quantity = int.Parse(txtQuantity.Text);
        //            string stockStatus = ddlStockStatus.SelectedValue;
        //            string taxClass = ddlTaxClass.SelectedValue;
        //            bool isActive = cbPublishStatus.Checked;
        //            string weight = txtWeight.Text.Trim();
        //            string dimensions = $"{txtLength.Text.Trim()}x{txtWidth.Text.Trim()}x{txtHeight.Text.Trim()}";
        //            string color = txtColor.Text.Trim();
        //            string size = txtSize.Text.Trim();
        //            string videoUrl = txtVideoUrl.Text.Trim();
        //            int categoryID = int.Parse(ddlCategory.SelectedValue);
        //            int subCategoryID = ddlSubCategory.SelectedValue == "0" ? 0 : int.Parse(ddlSubCategory.SelectedValue);
        //            string productCode = txtProductCode.Text.Trim();


        //            // Insert product into database
        //            int newProductID = 0;

        //            using (SqlConnection con = new SqlConnection(connectionString))
        //            {
        //                con.Open();
        //                using (SqlTransaction transaction = con.BeginTransaction())
        //                {
        //                    try
        //                    {
        //                        string query = @"INSERT INTO Product (
        //                            ProductCode, ProductName, Description, ShortDescription, Price, CompareAtPrice, CostPerItem, 
        //                            Quantity, StockStatus, TaxClass, IsActive, Weight, Dimensions, Color, Size, 
        //                            Brand, Tags, SKU, Barcode, VideoUrl, CategoryID, SubCategoryID,  CreatedAt
        //                        ) VALUES (
        //                            @ProductCode, @ProductName, @Description, @ShortDescription, @Price, @CompareAtPrice, @CostPerItem, 
        //                            @Quantity, @StockStatus, @TaxClass, @IsActive, @Weight, @Dimensions, @Color, @Size, 
        //                            @Brand, @Tags, @SKU, @Barcode, @VideoUrl, @CategoryID, @SubCategoryID,  GETDATE()
        //                        ); SELECT SCOPE_IDENTITY();";

        //                        using (SqlCommand cmd = new SqlCommand(query, con, transaction))
        //                        {
        //                            cmd.Parameters.AddWithValue("@ProductCode", productCode);
        //                            cmd.Parameters.AddWithValue("@ProductName", productName);
        //                            cmd.Parameters.AddWithValue("@Description", description);
        //                            cmd.Parameters.AddWithValue("@ShortDescription", shortDescription);
        //                            cmd.Parameters.AddWithValue("@Price", price);
        //                            cmd.Parameters.AddWithValue("@CompareAtPrice", compareAtPrice);
        //                            cmd.Parameters.AddWithValue("@CostPerItem", costPerItem);
        //                            cmd.Parameters.AddWithValue("@Quantity", quantity);
        //                            cmd.Parameters.AddWithValue("@StockStatus", stockStatus);
        //                            cmd.Parameters.AddWithValue("@TaxClass", string.IsNullOrEmpty(taxClass) ? (object)DBNull.Value : taxClass);
        //                            cmd.Parameters.AddWithValue("@IsActive", isActive);
        //                            cmd.Parameters.AddWithValue("@Weight", string.IsNullOrEmpty(weight) ? (object)DBNull.Value : decimal.Parse(weight));
        //                            cmd.Parameters.AddWithValue("@Dimensions", string.IsNullOrEmpty(dimensions) ? (object)DBNull.Value : dimensions);
        //                            cmd.Parameters.AddWithValue("@Color", string.IsNullOrEmpty(color) ? (object)DBNull.Value : color);
        //                            cmd.Parameters.AddWithValue("@Size", string.IsNullOrEmpty(size) ? (object)DBNull.Value : size);
        //                            cmd.Parameters.AddWithValue("@Brand", string.IsNullOrEmpty(brand) ? (object)DBNull.Value : brand);
        //                            cmd.Parameters.AddWithValue("@Tags", string.IsNullOrEmpty(tags) ? (object)DBNull.Value : tags);
        //                            cmd.Parameters.AddWithValue("@SKU", string.IsNullOrEmpty(sku) ? (object)DBNull.Value : sku);
        //                            cmd.Parameters.AddWithValue("@Barcode", string.IsNullOrEmpty(barcode) ? (object)DBNull.Value : barcode);
        //                            cmd.Parameters.AddWithValue("@VideoUrl", string.IsNullOrEmpty(videoUrl) ? (object)DBNull.Value : videoUrl);
        //                            cmd.Parameters.AddWithValue("@CategoryID", categoryID);
        //                            cmd.Parameters.AddWithValue("@SubCategoryID", subCategoryID == 0 ? (object)DBNull.Value : subCategoryID);


        //                            newProductID = Convert.ToInt32(cmd.ExecuteScalar());
        //                        }

        //                        // Handle main image upload
        //                        if (fileMainImage.HasFile)
        //                        {
        //                            SaveUploadedImage(fileMainImage.PostedFile, newProductID, true, con, transaction);
        //                        }

        //                        // Handle gallery images
        //                        if (fileGalleryImages.HasFiles)
        //                        {
        //                            foreach (HttpPostedFile file in fileGalleryImages.PostedFiles)
        //                            {
        //                                SaveUploadedImage(file, newProductID, false, con, transaction);
        //                            }
        //                        }

        //                        transaction.Commit();

        //                        if (!IsAjaxRequest())
        //                        {
        //                            ShowSuccessMessage("Product added successfully!");
        //                            ResetForm();
        //                        }
        //                    }
        //                    catch (Exception ex)
        //                    {
        //                        transaction.Rollback();
        //                        if (!IsAjaxRequest())
        //                        {
        //                            ShowErrorMessage("Error saving product: " + ex.Message);
        //                        }
        //                        throw;
        //                    }
        //                }
        //            }
        //        }
        //        catch (Exception ex)
        //        {
        //            if (!IsAjaxRequest())
        //            {
        //                ShowErrorMessage("Error: " + ex.Message);
        //            }
        //            else
        //            {
        //                throw;
        //            }
        //        }
        //    }

        private void SaveUploadedImage(HttpPostedFile file, int productID, bool isDefault, SqlConnection con, SqlTransaction transaction)
            {
                if (file.ContentLength > 0)
                {
                    string fileExtension = Path.GetExtension(file.FileName).ToLower();
                    string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };

                    if (!allowedExtensions.Contains(fileExtension))
                        throw new Exception("Only JPG, JPEG, PNG, and GIF images are allowed");

                    if (file.ContentLength > 10 * 1024 * 1024)
                        throw new Exception("Maximum file size allowed is 10MB");

                    string fileName = $"{productID}_{Guid.NewGuid()}{fileExtension}";
                    string uploadPath = Server.MapPath($"~/ProductImages/{fileName}");

                    Directory.CreateDirectory(Server.MapPath("~/ProductImages/"));
                    file.SaveAs(uploadPath);

                    string query = @"INSERT INTO ProductImage (ProductID, ImageUrl,ImageGallery, IsDefault)
                                    VALUES (@ProductID, @ImageUrl,@ImageGallery, @IsDefault)";

                    using (SqlCommand cmd = new SqlCommand(query, con, transaction))
                    {
                        cmd.Parameters.AddWithValue("@ProductID", productID);
                        cmd.Parameters.AddWithValue("@ImageUrl", $"/ProductImages/{fileName}");
                        cmd.Parameters.AddWithValue("@ImageGallery", $"/ProductImages/{fileName}");
                        cmd.Parameters.AddWithValue("@IsDefault", isDefault);
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            private void ShowSuccessMessage(string message)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showSuccess",
                    $"showSuccessMessage('{message.Replace("'", "\\'")}');", true);
            }

            private void ShowErrorMessage(string message)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    $"showErrorMessage('{message.Replace("'", "\\'")}');", true);
            }

            private void ResetForm()
            {
                // Reset all form fields
                txtProductName.Text = "";
                txtDescription.Text = "";
                txtShortDescription.Text = "";
                txtBrand.Text = "";
                txtTags.Text = "";
                txtSKU.Text = "";
                txtBarcode.Text = "";
                txtPrice.Text = "";
                txtCompareAtPrice.Text = "";
                txtCostPerItem.Text = "";
                txtQuantity.Text = "1";
                txtWeight.Text = "";
                txtLength.Text = "";
                txtWidth.Text = "";
                txtHeight.Text = "";
                txtColor.Text = "";
                txtSize.Text = "";
                txtVideoUrl.Text = "";
                cbPublishStatus.Checked = true;

                // Reset file upload displays
                ScriptManager.RegisterStartupScript(this, GetType(), "resetFileUploads",
                    "document.getElementById('mainImageFileName').textContent = 'No file selected'; " +
                    "document.getElementById('galleryImagesFileNames').textContent = 'No files selected';", true);

                // Reset to first step
                ScriptManager.RegisterStartupScript(this, GetType(), "resetSteps",
                    "currentStep = 1; updateProgress();", true);

                // Generate new product ID
                txtProductCode.Text = "PROD-" + DateTime.Now.ToString("yyyyMMddHHmmss");

                // Rebind categories
                BindCategories();
            }
        }
    }