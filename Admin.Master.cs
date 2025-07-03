using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Next_ae.Admin
{
    public partial class Admin : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadRecentOrders();
            }
        }

        private void LoadRecentOrders()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            List<OrderNotification> recentOrders = new List<OrderNotification>();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"SELECT TOP 5 o.OrderID, 
                                       c.FirstName + ' ' + c.LastName AS CustomerName, 
                                       o.TotalAmount, 
                                       o.OrderDate,
                                       o.Status
                                FROM Orders o
                                INNER JOIN Customer c ON o.CustomerID = c.CustomerID
                                ORDER BY o.OrderDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            recentOrders.Add(new OrderNotification
                            {
                                OrderID = Convert.ToInt32(reader["OrderID"]),
                                CustomerName = reader["CustomerName"].ToString(),
                                TotalAmount = Convert.ToDecimal(reader["TotalAmount"]),
                                OrderDate = Convert.ToDateTime(reader["OrderDate"]),
                                Status = reader["Status"].ToString()
                            });
                        }
                    }
                }
            }

            rptNotifications.DataSource = recentOrders;
            rptNotifications.DataBind();
            orderNotificationCount.InnerText = recentOrders.Count.ToString();
        }
    }

    public class OrderNotification
    {
        public int OrderID { get; set; }
        public string CustomerName { get; set; }
        public decimal TotalAmount { get; set; }
        public DateTime OrderDate { get; set; }
        public string Status { get; set; }
    }
}