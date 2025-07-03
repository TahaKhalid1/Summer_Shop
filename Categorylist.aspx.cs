using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Web.UI;

namespace Next_ae.User
{
    public partial class CategoryList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["IsAdminAuthenticated"] == null || !(bool)Session["IsAdminAuthenticated"])
                {
                    Response.Redirect("adminlogin.aspx");
                }
                BindCategories();
            }
        }

        private void BindCategories()
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
                string searchTerm = txtSearch.Text.Trim();

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = @"
                        SELECT 
                            c.CategoryID,
                            c.CategoryName AS Name,
                            'Category' AS Type,
                            CASE WHEN c.IsActive = 1 THEN 'Active' ELSE 'Inactive' END AS Status,
                            NULL AS ParentCategoryName,
                            0 AS IsSubCategory
                        FROM Category c
                        WHERE (@SearchTerm = '' OR c.CategoryName LIKE '%' + @SearchTerm + '%')
                        
                        UNION ALL
                        
                        SELECT 
                            s.SubCategoryID AS CategoryID,
                            s.SubCategoryName AS Name,
                            'Sub Category' AS Type,
                            CASE WHEN s.IsActive = 1 THEN 'Active' ELSE 'Inactive' END AS Status,
                            c.CategoryName AS ParentCategoryName,
                            1 AS IsSubCategory
                        FROM SubCategory s
                        INNER JOIN Category c ON s.CategoryID = c.CategoryID
                        WHERE (@SearchTerm = '' OR s.SubCategoryName LIKE '%' + @SearchTerm + '%' OR c.CategoryName LIKE '%' + @SearchTerm + '%')
                        
                        ORDER BY IsSubCategory, Name";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@SearchTerm", searchTerm);

                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        gvCategories.DataSource = dt;
                        gvCategories.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    $"Swal.fire('Error!', 'Error loading categories: {ex.Message.Replace("'", "\\'")}', 'error');", true);
            }
        }

        protected void gvCategories_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "DeleteCategory")
            {
                try
                {
                    string[] args = e.CommandArgument.ToString().Split('|');
                    int categoryId = Convert.ToInt32(args[0]);
                    string categoryType = args[1];

                    DeleteCategory(categoryId, categoryType);
                    BindCategories();

                    ScriptManager.RegisterStartupScript(this, GetType(), "showSuccess",
                        "Swal.fire('Success!', 'Category deleted successfully', 'success');", true);
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                        $"Swal.fire('Error!', 'Error deleting category: {ex.Message.Replace("'", "\\'")}', 'error');", true);
                }
            }
        }

        protected void gvCategories_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                // Get the category type from the data
                DataRowView rowView = (DataRowView)e.Row.DataItem;
                string categoryType = rowView["IsSubCategory"].ToString() == "1" ? "sub" : "main";

                // Set the value in the hidden field
                HiddenField hdnType = (HiddenField)e.Row.FindControl("hdnCategoryType");
                if (hdnType != null)
                {
                    hdnType.Value = categoryType;
                }
            }
        }

        [System.Web.Services.WebMethod]
        public static string DeleteCategory(int categoryId, string categoryType)
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
                            if (categoryType == "sub")
                            {
                                // First update products that reference this subcategory to NULL
                                string updateProductsQuery = "UPDATE Product SET SubCategoryID = NULL WHERE SubCategoryID = @CategoryID";
                                using (SqlCommand updateCmd = new SqlCommand(updateProductsQuery, con, transaction))
                                {
                                    updateCmd.Parameters.AddWithValue("@CategoryID", categoryId);
                                    updateCmd.ExecuteNonQuery();
                                }

                                // Then delete the subcategory
                                string deleteQuery = "DELETE FROM SubCategory WHERE SubCategoryID = @CategoryID";
                                using (SqlCommand cmd = new SqlCommand(deleteQuery, con, transaction))
                                {
                                    cmd.Parameters.AddWithValue("@CategoryID", categoryId);
                                    cmd.ExecuteNonQuery();
                                }
                            }
                            else
                            {
                                // First update products that reference this category to NULL
                                string updateProductsQuery = "UPDATE Product SET CategoryID = NULL, SubCategoryID = NULL WHERE CategoryID = @CategoryID";
                                using (SqlCommand updateCmd = new SqlCommand(updateProductsQuery, con, transaction))
                                {
                                    updateCmd.Parameters.AddWithValue("@CategoryID", categoryId);
                                    updateCmd.ExecuteNonQuery();
                                }

                                // Then delete related subcategories
                                string deleteSubQuery = "DELETE FROM SubCategory WHERE CategoryID = @CategoryID";
                                using (SqlCommand subCmd = new SqlCommand(deleteSubQuery, con, transaction))
                                {
                                    subCmd.Parameters.AddWithValue("@CategoryID", categoryId);
                                    subCmd.ExecuteNonQuery();
                                }

                                // Finally delete the category
                                string deleteQuery = "DELETE FROM Category WHERE CategoryID = @CategoryID";
                                using (SqlCommand cmd = new SqlCommand(deleteQuery, con, transaction))
                                {
                                    cmd.Parameters.AddWithValue("@CategoryID", categoryId);
                                    cmd.ExecuteNonQuery();
                                }
                            }

                            transaction.Commit();
                            return "success";
                        }
                        catch (Exception ex)
                        {
                            transaction.Rollback();
                            throw new Exception("Error deleting category: " + ex.Message);
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
            BindCategories();
        }
    }
}