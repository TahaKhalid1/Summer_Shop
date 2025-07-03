//












using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Linq;
using System.Web.UI.WebControls;

namespace Next_ae.Admin
{
    public partial class Dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["IsAdminAuthenticated"] == null || !(bool)Session["IsAdminAuthenticated"])
                {
                    Response.Redirect("adminlogin.aspx");
                }
                LoadDashboardStats();
                LoadRecentOrders();
                LoadTopProducts();
                LoadRecentVisitors();
                //LoadAdminActivities();
                LoadSalesChartsData();
                LoadVisitorChartData();
            }
        }


        protected string GetStatusBadgeClass(string status)
        {
            switch (status.ToLower())
            {
                case "pending":
                    return "bg-warning";
                case "processing":
                    return "bg-info";
                case "completed":
                    return "bg-success";
                case "cancelled":
                    return "bg-danger";
                case "shipped":
                    return "bg-primary";
                default:
                    return "bg-secondary";
            }
        }

        private void LoadDashboardStats()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                // Total Revenue
                string revenueQuery = @"SELECT ISNULL(SUM(TotalAmount), 0) 
                                     FROM Orders 
                                     WHERE OrderDate >= DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)
                                       AND OrderDate < DATEADD(month, DATEDIFF(month, 0, GETDATE()) + 1, 0)";
                SqlCommand cmd = new SqlCommand(revenueQuery, con);
                con.Open();
                decimal totalRevenue = (decimal)cmd.ExecuteScalar();
                lblTotalRevenue.Text = FormatRupees(totalRevenue);
                con.Close();

                // New Customers (last 30 days)
                string newCustomersQuery = "SELECT COUNT(*) FROM Customer WHERE CreatedAt >= DATEADD(day, -30, GETDATE())";
                cmd = new SqlCommand(newCustomersQuery, con);
                con.Open();
                int newCustomers = (int)cmd.ExecuteScalar();
                lblNewCustomers.Text = newCustomers.ToString();
                con.Close();

                // New Orders (last 30 days)
                string newOrdersQuery = "SELECT COUNT(*) FROM Orders WHERE OrderDate >= DATEADD(day, -30, GETDATE())";
                cmd = new SqlCommand(newOrdersQuery, con);
                con.Open();
                int newOrders = (int)cmd.ExecuteScalar();
                lblNewOrders.Text = newOrders.ToString();
                con.Close();

                // Total Products
                string totalProductsQuery = "SELECT COUNT(*) FROM Product WHERE IsActive = 1";
                cmd = new SqlCommand(totalProductsQuery, con);
                con.Open();
                int totalProducts = (int)cmd.ExecuteScalar();
                lblTotalProducts.Text = totalProducts.ToString();
                con.Close();
            }
        }


        //private void LoadAdminActivities()
        //{
        //    string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
        //    string query = @"SELECT TOP 10 a.ActivityID, ad.Username, a.ActivityType, a.EntityType, 
        //                   a.EntityID, a.Description, a.ActivityDate
        //                   FROM AdminActivities a
        //                   INNER JOIN Admin ad ON a.AdminID = ad.AdminID
        //                   ORDER BY a.ActivityDate DESC";

        //    using (SqlConnection con = new SqlConnection(connectionString))
        //    {
        //        SqlCommand cmd = new SqlCommand(query, con);
        //        SqlDataAdapter da = new SqlDataAdapter(cmd);
        //        DataTable dt = new DataTable();
        //        da.Fill(dt);

        //        rptAdminActivities.DataSource = dt;
        //        rptAdminActivities.DataBind();
        //    }
        //}


        protected string GetActivityIcon(string activityType, string entityType)
        {
            switch (activityType.ToLower())
            {
                case "add":
                    return "plus-circle";
                case "edit":
                    return "edit";
                case "delete":
                    return "trash-2";
                case "complete":
                    return "check-circle";
                case "cancel":
                    return "x-circle";
                case "deliver":
                    return "truck";
                default:
                    return "activity";
            }
        }

        protected string GetActivityColor(string activityType)
        {
            switch (activityType.ToLower())
            {
                case "add":
                    return "success";
                case "edit":
                    return "info";
                case "delete":
                    return "danger";
                case "complete":
                    return "success";
                case "cancel":
                    return "warning";
                case "deliver":
                    return "primary";
                default:
                    return "secondary";
            }
        }

        protected string FormatRupees(decimal amount)
        {
            return "Rs. " + amount.ToString("N2");
        }


        protected string FormatActivityDescription(object description, object entityType, object entityId)
        {
            if (description != null && !string.IsNullOrEmpty(description.ToString()))
                return description.ToString();

            return $"{entityType} #{entityId}";
        }

        protected string FormatVisitorTime(DateTime visitTime)
        {
            TimeSpan timeSinceVisit = DateTime.Now - visitTime;

            if (timeSinceVisit.TotalMinutes < 1)
                return "Just now";
            if (timeSinceVisit.TotalMinutes < 60)
                return $"{(int)timeSinceVisit.TotalMinutes} mins ago";
            if (timeSinceVisit.TotalHours < 24)
                return $"{(int)timeSinceVisit.TotalHours} hours ago";

            return $"{(int)timeSinceVisit.TotalDays} days ago";
        }

        protected string GetProductImageUrl(object imageUrl)
        {
            if (imageUrl == null || string.IsNullOrEmpty(imageUrl.ToString()))
                return "../assets/img/default-product.png";

            return imageUrl.ToString();
        }

        private void LoadVisitorChartData()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            string query = @"SELECT 
                            CAST(VisitTime AS DATE) AS VisitDay, 
                            COUNT(*) AS VisitCount
                            FROM VisitorLogs
                            WHERE VisitTime >= DATEADD(day, -7, GETDATE())
                            GROUP BY CAST(VisitTime AS DATE)
                            ORDER BY VisitDay";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand(query, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                // Convert to JSON for JavaScript chart
                var chartData = dt.AsEnumerable()
                    .Select(row => new
                    {
                        Day = ((DateTime)row["VisitDay"]).ToString("ddd"),
                        Count = row["VisitCount"]
                    }).ToList();

                hdnVisitorData.Value = Newtonsoft.Json.JsonConvert.SerializeObject(chartData);
            }
        }
        private void LoadRecentVisitors()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            string query = @"SELECT TOP 5 IPAddress, PageVisited, VisitTime 
                            FROM VisitorLogs 
                            ORDER BY VisitTime DESC";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand(query, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptRecentVisitors.DataSource = dt;
                rptRecentVisitors.DataBind();
            }
        }

        private void LoadRecentOrders()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            string query = @"SELECT TOP 5 o.OrderID, c.FirstName + ' ' + c.LastName AS CustomerName, 
                           o.OrderDate, o.TotalAmount, o.Status
                           FROM Orders o
                           INNER JOIN Customer c ON o.CustomerID = c.CustomerID
                           ORDER BY o.OrderDate DESC";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand(query, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptRecentOrders.DataSource = dt;
                rptRecentOrders.DataBind();
            }
        }

        private void LoadTopProducts()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            string query = @"SELECT TOP 5 p.ProductID, p.ProductName, pi.ImageUrl, cat.CategoryName, 
                   SUM(od.Quantity) AS TotalSold, 
                   SUM(od.Quantity * od.UnitPrice) AS TotalRevenue
                   FROM OrderDetails od
                   INNER JOIN Product p ON od.ProductID = p.ProductID
                   INNER JOIN Category cat ON p.CategoryID = cat.CategoryID
                   INNER JOIN ProductImage pi ON p.ProductID = pi.ProductID AND pi.IsDefault = 1
                   GROUP BY p.ProductID, p.ProductName, pi.ImageUrl, cat.CategoryName
                   ORDER BY TotalSold DESC";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand(query, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptTopProducts.DataSource = dt;
                rptTopProducts.DataBind();
            }
        }

        private void LoadSalesChartsData()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            // Last 7 days sales data for chart
            string salesQuery = @"SELECT CAST(OrderDate AS DATE) AS OrderDay, 
                                SUM(TotalAmount) AS DailySales
                                FROM Orders
                                WHERE OrderDate >= DATEADD(day, -7, GETDATE())
                                GROUP BY CAST(OrderDate AS DATE)
                                ORDER BY OrderDay";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand(salesQuery, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                // Convert to JSON for JavaScript chart
                var chartData = dt.AsEnumerable()
                    .Select(row => new
                    {
                        Day = ((DateTime)row["OrderDay"]).ToString("ddd"),
                        Sales = row["DailySales"]
                    }).ToList();

                hdnSalesData.Value = Newtonsoft.Json.JsonConvert.SerializeObject(chartData);
            }

            // Sales by category
            string categoryQuery = @"SELECT c.CategoryName, SUM(od.Quantity * od.UnitPrice) AS CategorySales
                                   FROM OrderDetails od
                                   INNER JOIN Product p ON od.ProductID = p.ProductID
                                   INNER JOIN Category c ON p.CategoryID = c.CategoryID
                                   GROUP BY c.CategoryName";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand(categoryQuery, con);
                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                hdnCategoryData.Value = Newtonsoft.Json.JsonConvert.SerializeObject(dt);
            }
        }
    }
}