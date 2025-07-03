using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using Newtonsoft.Json;

namespace Next_ae.User
{
    public partial class CategoryManagement : System.Web.UI.Page
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
                BindParentCategories();
                UpdateUI();
            }
        }

        protected void rblCategoryType_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateUI();
        }

        private void UpdateUI()
        {
            // Update the label text
            lblName.Text = rblCategoryType.SelectedValue == "Category" ? "Category Name" : "Sub Category Name";

            // Show/hide parent category dropdown
            parentCategoryGroup.Style["display"] = rblCategoryType.SelectedValue == "SubCategory" ? "block" : "none";

            // Refresh parent categories when switching to subcategory
            if (rblCategoryType.SelectedValue == "SubCategory")
            {
                BindParentCategories();
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
                string buttonClicked = Request.Form["__EVENTTARGET"];

                
                if (buttonClicked == btnPublish.UniqueID)
                {
                    SaveCategory(true);
                }

                Response.Write(JsonConvert.SerializeObject(new
                {
                    success = true,
                    message = "Operation completed successfully"
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

        private void BindParentCategories()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = "SELECT CategoryID, CategoryName FROM Category WHERE IsActive = 1";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    ddlParentCategory.DataSource = reader;
                    ddlParentCategory.DataTextField = "CategoryName";
                    ddlParentCategory.DataValueField = "CategoryID";
                    ddlParentCategory.DataBind();
                    ddlParentCategory.Items.Insert(0, new ListItem("-- Select Category --", "0"));
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                SaveCategory(false);
                ShowSuccessMessage("Category saved successfully!");
                ResetForm();
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error: " + ex.Message);
            }
        }

        protected void btnPublish_Click(object sender, EventArgs e)
        {
            try
            {
                SaveCategory(true);
                ShowSuccessMessage("Category published successfully!");
                ResetForm();
            }
            catch (Exception ex)
            {
                ShowErrorMessage("Error: " + ex.Message);
            }
        }

        private void SaveCategory(bool publish)
        {
            // Validate inputs
            if (string.IsNullOrWhiteSpace(txtName.Text))
            {
                throw new Exception(rblCategoryType.SelectedValue == "Category" ?
                    "Category name is required" : "Sub Category name is required");
            }

            if (rblCategoryType.SelectedValue == "SubCategory" && ddlParentCategory.SelectedValue == "0")
            {
                throw new Exception("Please select a parent category for subcategory");
            }

            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            bool isActive = publish || cbIsActive.Checked;
            string name = txtName.Text.Trim();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                con.Open();

                if (rblCategoryType.SelectedValue == "Category")
                {
                    string query = @"INSERT INTO Category (CategoryName, IsActive) 
                                    VALUES (@Name, @IsActive)";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Name", name);
                        cmd.Parameters.AddWithValue("@IsActive", isActive);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    int parentCategoryId = int.Parse(ddlParentCategory.SelectedValue);

                    string query = @"INSERT INTO SubCategory (SubCategoryName, CategoryID, IsActive) 
                                    VALUES (@Name, @CategoryID, @IsActive)";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Name", name);
                        cmd.Parameters.AddWithValue("@CategoryID", parentCategoryId);
                        cmd.Parameters.AddWithValue("@IsActive", isActive);
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            // Refresh parent categories after saving
            if (rblCategoryType.SelectedValue == "Category")
            {
                BindParentCategories();
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
            txtName.Text = "";
            cbIsActive.Checked = true;
            rblCategoryType.SelectedValue = "Category";
            ddlParentCategory.SelectedValue = "0";
            UpdateUI();
        }
    }
}