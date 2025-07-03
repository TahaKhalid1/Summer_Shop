using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Services;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Next_ae.User
{
    public partial class Home : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindNewArrivals();
            }
        }

        private void BindNewArrivals()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                // Get products added in the last 7 days
                string query = @"SELECT TOP 4 p.ProductID, p.ProductName, p.Price, p.Gender, 
                               COALESCE(pi.ImageUrl, 'default-product.jpg') AS ImageUrl
                               FROM Product p
                               LEFT JOIN ProductImage pi ON p.ProductID = pi.ProductID AND pi.IsDefault = 1
                               WHERE p.IsActive = 1 
                               AND p.CreatedAt >= DATEADD(day, -7, GETDATE())
                               ORDER BY p.CreatedAt DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    try
                    {
                        con.Open();
                        SqlDataAdapter sda = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptNewArrivals.DataSource = dt;
                            rptNewArrivals.DataBind();
                        }
                    }
                    catch (Exception ex)
                    {
                        // Handle error - you might want to add error logging here
                    }
                }
            }
        }

        protected void rptNewArrivals_ItemDataBound(object sender, RepeaterItemEventArgs e)
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


        public class ProductQuickView
        {
            public int Id { get; set; }
            public string Name { get; set; }
            public decimal Price { get; set; }
            public string ShortDescription { get; set; }
            public List<ProductImage> Images { get; set; }
            public List<ProductOption> Sizes { get; set; }
            public List<ProductOption> Colors { get; set; }
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
    }
}