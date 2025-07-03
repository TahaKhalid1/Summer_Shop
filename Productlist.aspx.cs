using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Web.UI;
using System.Web;

namespace Next_ae.User
{
    public partial class ProductList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["IsAdminAuthenticated"] == null || !(bool)Session["IsAdminAuthenticated"])
                {
                    Response.Redirect("adminlogin.aspx");
                }
                BindProducts();
            }
        }

        protected string GetProductImageUrl(string productId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            string defaultImage = "/ProductImages/default-product.png";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT TOP 1 ImageUrl FROM ProductImage WHERE ProductID = @ProductID AND IsDefault = 1";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@ProductID", productId);
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    return result != null ? result.ToString() : defaultImage;
                }
            }
        }

        private void BindProducts()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            string searchTerm = txtSearch.Text.Trim();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"SELECT p.ProductID, p.ProductName, c.CategoryName, 
                                p.Price, 
                                CASE 
                                    WHEN p.IsActive = 1 THEN 'Active'
                                    WHEN p.IsActive = 0 THEN 'Inactive'
                                    ELSE 'Draft'
                                END AS Status,
                                p.Quantity AS Inventory,
                                p.CreatedAt AS PublishedDate
                                FROM Product p
                                LEFT JOIN Category c ON p.CategoryID = c.CategoryID
                                WHERE (@SearchTerm = '' OR 
                                      p.ProductName LIKE '%' + @SearchTerm + '%' OR
                                      c.CategoryName LIKE '%' + @SearchTerm + '%')
                                ORDER BY p.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SearchTerm", searchTerm);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvProducts.DataSource = dt;
                    gvProducts.DataBind();
                }
            }
        }

        protected void gvProducts_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Set default image if none exists
                Image imgProduct = (Image)e.Row.FindControl("imgProduct");
                if (imgProduct != null && string.IsNullOrEmpty(imgProduct.ImageUrl))
                {
                    imgProduct.ImageUrl = "/ProductImages/default-product.png";
                }
            }
        }

        protected void gvProducts_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteProduct")
            {
                int productId = Convert.ToInt32(e.CommandArgument);
                DeleteProduct(productId);
            }
        }

        [System.Web.Services.WebMethod]
        public static string DeleteProduct(int productId)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    con.Open();
                    using (SqlTransaction transaction = con.BeginTransaction())
                    {
                        try
                        {
                            // First delete related images from database and filesystem
                            string getImagesQuery = "SELECT ImageUrl FROM ProductImage WHERE ProductID = @ProductID";
                            DataTable dtImages = new DataTable();
                            using (SqlCommand getCmd = new SqlCommand(getImagesQuery, con, transaction))
                            {
                                getCmd.Parameters.AddWithValue("@ProductID", productId);
                                SqlDataAdapter da = new SqlDataAdapter(getCmd);
                                da.Fill(dtImages);
                            }

                            // Delete image files
                            foreach (DataRow row in dtImages.Rows)
                            {
                                string imagePath = HttpContext.Current.Server.MapPath(row["ImageUrl"].ToString());
                                if (System.IO.File.Exists(imagePath))
                                {
                                    System.IO.File.Delete(imagePath);
                                }
                            }

                            // Delete from ProductImage table
                            string deleteImagesQuery = "DELETE FROM ProductImage WHERE ProductID = @ProductID";
                            using (SqlCommand imgCmd = new SqlCommand(deleteImagesQuery, con, transaction))
                            {
                                imgCmd.Parameters.AddWithValue("@ProductID", productId);
                                imgCmd.ExecuteNonQuery();
                            }

                            // Then delete the product
                            string deleteProductQuery = "DELETE FROM Product WHERE ProductID = @ProductID";
                            using (SqlCommand cmd = new SqlCommand(deleteProductQuery, con, transaction))
                            {
                                cmd.Parameters.AddWithValue("@ProductID", productId);
                                cmd.ExecuteNonQuery();
                            }

                            transaction.Commit();
                            return "success";
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            throw new Exception("Error deleting product: " + ex.Message);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            BindProducts();
        }
    }
}