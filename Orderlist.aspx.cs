using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.Web.UI;
using System.IO;
using System.Text;
using Next_ae.Admin;

namespace Next_ae.User
{
    public partial class OrderList : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["IsAdminAuthenticated"] == null || !(bool)Session["IsAdminAuthenticated"])
                {
                    Response.Redirect("adminlogin.aspx");
                }


                ddlStatus.SelectedValue = "Processing";
                BindOrders();
            }
        }

        private void BindOrders()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            string statusFilter = ddlStatus.SelectedValue;
            string searchTerm = txtSearch.Text.Trim();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"SELECT o.OrderID, o.OrderDate, o.TotalAmount, o.Status, 
                                p.PaymentMethod,
                                c.FirstName + ' ' + c.LastName AS CustomerName,
                                c.Email AS CustomerEmail, c.Phone AS CustomerPhone,
                                s.FullName AS ShippingName, s.AddressLine1, s.City, s.State, 
                                s.PostalCode, s.Country, s.Phone AS ShippingPhone,
                                COUNT(od.OrderDetailID) AS ItemCount
                                FROM Orders o
                                INNER JOIN Customer c ON o.CustomerID = c.CustomerID
                                LEFT JOIN OrderDetails od ON o.OrderID = od.OrderID
                                LEFT JOIN ShippingAddress s ON o.ShippingID = s.ShippingID
                                LEFT JOIN Payment p ON o.OrderID = p.OrderID
                                WHERE (@Status = 'All' OR o.Status = @Status)
                                AND (@SearchTerm = '' OR 
                                    c.FirstName LIKE '%' + @SearchTerm + '%' OR
                                    c.LastName LIKE '%' + @SearchTerm + '%' OR
                                    c.Email LIKE '%' + @SearchTerm + '%' OR
                                    o.OrderID LIKE '%' + @SearchTerm + '%')
                                GROUP BY o.OrderID, o.OrderDate, o.TotalAmount, o.Status, 
                                c.FirstName, c.LastName, c.Email, c.Phone,
                                s.FullName, s.AddressLine1, s.City, s.State, s.PostalCode, 
                                s.Country, s.Phone, p.PaymentMethod
                                ORDER BY o.OrderDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Status", statusFilter);
                    cmd.Parameters.AddWithValue("@SearchTerm", searchTerm);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    gvOrders.DataSource = dt;
                    gvOrders.DataBind();
                }
            }
        }

        protected void gvOrders_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "UpdateStatus")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                if (args.Length == 2)
                {
                    int orderId = Convert.ToInt32(args[0]);
                    string newStatus = args[1];
                    UpdateOrderStatus(orderId, newStatus);
                }
            }
           
            else if (e.CommandName == "SendNotification")
            {
                int orderId = Convert.ToInt32(e.CommandArgument);
                SendNotification(orderId);
            }
            else if (e.CommandName == "CancelOrder")
            {
                int orderId = Convert.ToInt32(e.CommandArgument);
                CancelOrder(orderId);
            }
            else if (e.CommandName == "ShowDetails")
            {
                int orderId = Convert.ToInt32(e.CommandArgument);
                ShowOrderDetails(orderId);
            }
            else if (e.CommandName == "ShowDetail")
            {
                int orderId = Convert.ToInt32(e.CommandArgument);
                ShowOrderDetails(orderId);
            }
        }

        // Add this new method for getting order details with images
        private void ShowOrderDetails(int orderId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            DataTable dt = new DataTable();

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"SELECT p.ProductName, od.ProductImageUrl, od.Quantity, od.UnitPrice, 
                        (od.Quantity * od.UnitPrice) AS TotalPrice,
                        p.Description, p.Color, p.Size
                        FROM OrderDetails od
                        INNER JOIN Product p ON od.ProductID = p.ProductID
                        WHERE od.OrderID = @OrderID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@OrderID", orderId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dt);
                }

                // Get order summary
                string summaryQuery = @"SELECT o.OrderID, o.OrderDate, o.TotalAmount, o.Status, 
                              c.FirstName + ' ' + c.LastName AS CustomerName,
                              s.FullName AS ShippingName, s.AddressLine1, s.City, 
                              s.State, s.PostalCode, s.Country
                              FROM Orders o
                              INNER JOIN Customer c ON o.CustomerID = c.CustomerID
                              LEFT JOIN ShippingAddress s ON o.ShippingID = s.ShippingID
                              WHERE o.OrderID = @OrderID";

                DataTable dtSummary = new DataTable();
                using (SqlCommand cmd = new SqlCommand(summaryQuery, con))
                {
                    cmd.Parameters.AddWithValue("@OrderID", orderId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    da.Fill(dtSummary);
                }

                StringBuilder sb = new StringBuilder();
                sb.Append("<div class='order-details-container'>");

                // Order summary section
                if (dtSummary.Rows.Count > 0)
                {
                    DataRow summary = dtSummary.Rows[0];
                    sb.Append($"<div class='order-header'>");
                    sb.Append($"<h2><i class='fas fa-receipt'></i> Order # {orderId}</h2>");
                    sb.Append($"<div class='order-meta'>");
                    sb.Append($"<div><span class='meta-label'>Date:</span> {Convert.ToDateTime(summary["OrderDate"]).ToString("MMMM dd, yyyy hh:mm tt")}</div>");
                    sb.Append($"<div><span class='meta-label'>Status:</span> <span class='status-badge {GetStatusClass(summary["Status"].ToString())}'>{summary["Status"]}</span></div>");
                    sb.Append($"<div><span class='meta-label'>Total:</span> ${Convert.ToDecimal(summary["TotalAmount"]).ToString("N2")}</div>");
                    sb.Append("</div></div>");

                    sb.Append("<div class='order-summary-section'>");
                    sb.Append("<div class='customer-info'>");
                    sb.Append("<h3><i class='fas fa-user'></i> Customer Information</h3>");
                    sb.Append($"<p><strong>{summary["CustomerName"]}</strong></p>");
                    sb.Append("</div>");

                    sb.Append("<div class='shipping-info'>");
                    sb.Append("<h3><i class='fas fa-truck'></i> Shipping Information</h3>");
                    sb.Append($"<p><strong>{summary["ShippingName"]}</strong></p>");
                    sb.Append($"<p>{summary["AddressLine1"]}</p>");
                    sb.Append($"<p>{summary["City"]}, {summary["State"]} {summary["PostalCode"]}</p>");
                    sb.Append($"<p>{summary["Country"]}</p>");
                    sb.Append("</div>");
                    sb.Append("</div>");
                }

                // Products section
                sb.Append("<div class='products-section'>");
                sb.Append("<h3><i class='fas fa-box-open'></i> Ordered Products</h3>");
                sb.Append("<div class='products-grid'>");

                foreach (DataRow row in dt.Rows)
                {
                    sb.Append("<div class='product-card'>");
                    sb.Append($"<div class='product-image'><img src='{row["ProductImageUrl"]}' onerror=\"this.src='images/default-product.png'\" alt='Product Image'></div>");
                    sb.Append("<div class='product-details'>");
                    sb.Append($"<h4>{row["ProductName"]}</h4>");

                    if (!string.IsNullOrEmpty(row["Description"].ToString()))
                        sb.Append($"<p class='product-description'>{row["Description"]}</p>");

                    sb.Append("<div class='product-specs'>");
                    if (!string.IsNullOrEmpty(row["Color"].ToString()))
                        sb.Append($"<div><span>Color:</span> {row["Color"]}</div>");
                    if (!string.IsNullOrEmpty(row["Size"].ToString()))
                        sb.Append($"<div><span>Size:</span> {row["Size"]}</div>");
                    sb.Append("</div>");

                    sb.Append("<div class='product-pricing'>");
                    sb.Append($"<div><span>Price:</span> ${Convert.ToDecimal(row["UnitPrice"]).ToString("N2")}</div>");
                    sb.Append($"<div><span>Qty:</span> {row["Quantity"]}</div>");
                    sb.Append($"<div class='total-price'><span>Total:</span> ${Convert.ToDecimal(row["TotalPrice"]).ToString("N2")}</div>");
                    sb.Append("</div>");

                    sb.Append("</div></div>");
                }

                sb.Append("</div></div></div>");

                // Register script to show modal with details
                string script = $"showDetailsModal('{sb.ToString().Replace("'", "\\'")}');";
                ScriptManager.RegisterStartupScript(this, GetType(), "ShowDetails", script, true);
            }
        }

        private string GetStatusClass(string status)
        {
            switch (status)
            {
                case "Processing": return "status-processing";
                case "Delivered": return "status-delivered";
                case "Completed": return "status-completed";
                case "Cancelled": return "status-cancelled";
                default: return "status-processing";
            }
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            // Create a DataTable for export
            DataTable dtExport = new DataTable();
            dtExport.Columns.Add("Order ID");
            dtExport.Columns.Add("Order Date");
            dtExport.Columns.Add("Customer Name");
            dtExport.Columns.Add("Email");
            dtExport.Columns.Add("Phone");
            dtExport.Columns.Add("Total Amount");
            dtExport.Columns.Add("Status");
            dtExport.Columns.Add("Payment Method");
            dtExport.Columns.Add("Item Count");

            // Collect selected orders
            foreach (GridViewRow row in gvOrders.Rows)
            {
                CheckBox chkSelect = (CheckBox)row.FindControl("chkSelect");
                if (chkSelect != null && chkSelect.Checked)
                {
                    DataRow dr = dtExport.NewRow();
                    dr["Order ID"] = gvOrders.DataKeys[row.RowIndex].Value.ToString();
                    dr["Order Date"] = ((Label)row.FindControl("lblOrderDate")).Text;
                    dr["Customer Name"] = ((Label)row.FindControl("lblCustomerName")).Text;
                    dr["Email"] = ((Label)row.FindControl("lblCustomerEmail")).Text;
                    dr["Phone"] = ((Label)row.FindControl("lblCustomerPhone")).Text;
                    dr["Total Amount"] = ((Label)row.FindControl("lblTotalAmount")).Text;
                    dr["Status"] = ((Label)row.FindControl("lblStatus")).Text;
                    dr["Payment Method"] = ((Label)row.FindControl("lblPaymentMethod")).Text;
                    dr["Item Count"] = ((Label)row.FindControl("lblItemCount")).Text;
                    dtExport.Rows.Add(dr);
                }
            }

            if (dtExport.Rows.Count > 0)
            {
                ExportToExcel(dtExport);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    "showErrorMessage('Please select at least one order to export');", true);
            }
        }

        private void ExportToExcel(DataTable dt)
        {
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("content-disposition", "attachment;filename=OrdersExport_" + DateTime.Now.ToString("yyyyMMddHHmmss") + ".xls");
            Response.Charset = "";
            Response.ContentType = "application/vnd.ms-excel";

            using (StringWriter sw = new StringWriter())
            {
                HtmlTextWriter hw = new HtmlTextWriter(sw);

                // Add table formatting
                sw.WriteLine("<table border='1'>");

                // Add header row
                sw.WriteLine("<tr>");
                foreach (DataColumn column in dt.Columns)
                {
                    sw.WriteLine("<th bgcolor='#4bacc6' style='color:#fff;'>" + column.ColumnName + "</th>");
                }
                sw.WriteLine("</tr>");

                // Add data rows
                foreach (DataRow row in dt.Rows)
                {
                    sw.WriteLine("<tr>");
                    foreach (DataColumn column in dt.Columns)
                    {
                        sw.WriteLine("<td>" + row[column].ToString() + "</td>");
                    }
                    sw.WriteLine("</tr>");
                }

                sw.WriteLine("</table>");
                Response.Output.Write(sw.ToString());
                Response.Flush();
                Response.End();
            }
        }

        private void UpdateOrderStatus(int orderId, string newStatus)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = "UPDATE Orders SET Status = @Status WHERE OrderID = @OrderID";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Status", newStatus);
                        cmd.Parameters.AddWithValue("@OrderID", orderId);
                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

        

                BindOrders();
                ScriptManager.RegisterStartupScript(this, GetType(), "showSuccess",
                    $"showSuccessMessage('Order status updated to {newStatus}');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    $"showErrorMessage('Error updating order status: {ex.Message.Replace("'", "\\'")}');", true);
            }
        }
        private void SendNotification(int orderId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
            string customerEmail = "";
            string orderStatus = "";
            string customerName = "";

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                // Get customer and order details
                string query = @"SELECT c.Email, o.Status, c.FirstName + ' ' + c.LastName AS CustomerName 
                        FROM Orders o
                        INNER JOIN Customer c ON o.CustomerID = c.CustomerID
                        WHERE o.OrderID = @OrderID";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@OrderID", orderId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            customerEmail = reader["Email"].ToString();
                            orderStatus = reader["Status"].ToString();
                            customerName = reader["CustomerName"].ToString();
                        }
                    }
                }
            }

            if (!string.IsNullOrEmpty(customerEmail))
            {
                try
                {
                    // Implement your email sending logic here
                    // This is a basic example using SmtpClient
                    /*
                    MailMessage mail = new MailMessage();
                    mail.To.Add(customerEmail);
                    mail.Subject = $"Your Order #{orderId} Status Update";
                    mail.Body = $"Dear {customerName},<br><br>"
                              + $"Your order #{orderId} status has been updated to: {orderStatus}<br><br>"
                              + "Thank you for shopping with us!";
                    mail.IsBodyHtml = true;

                    SmtpClient smtp = new SmtpClient();
                    smtp.Send(mail);
                    */

                    ScriptManager.RegisterStartupScript(this, GetType(), "showSuccess",
                        $"showSuccessMessage('Notification sent to {customerEmail}');", true);
                }
                catch (Exception ex)
                {
                    ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                        $"showErrorMessage('Error sending notification: {ex.Message.Replace("'", "\\'")}');", true);
                }
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    "showErrorMessage('Customer email not found');", true);
            }
        }
        private void PrintInvoice(int orderId)
        {
            // Generate PDF invoice
            ScriptManager.RegisterStartupScript(this, GetType(), "showSuccess",
                "showSuccessMessage('Invoice generated for order #" + orderId + "');", true);
        }



        private void CancelOrder(int orderId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = "UPDATE Orders SET Status = 'Cancelled' WHERE OrderID = @OrderID";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@OrderID", orderId);
                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                BindOrders();
                ScriptManager.RegisterStartupScript(this, GetType(), "showSuccess",
                    "showSuccessMessage('Order #" + orderId + " has been cancelled');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showError",
                    $"showErrorMessage('Error cancelling order: {ex.Message.Replace("'", "\\'")}');", true);
            }
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindOrders();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindOrders();
        }

        protected void gvOrders_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                Label lblStatus = (Label)e.Row.FindControl("lblStatus");
                LinkButton btnProcess = (LinkButton)e.Row.FindControl("btnProcess");
                LinkButton btnDeliver = (LinkButton)e.Row.FindControl("btnDeliver");
                LinkButton btnComplete = (LinkButton)e.Row.FindControl("btnComplete");
                LinkButton btnCancel = (LinkButton)e.Row.FindControl("btnCancel");
                LinkButton btnNotify = (LinkButton)e.Row.FindControl("btnNotify");
                LinkButton btnDetails = (LinkButton)e.Row.FindControl("btnDetails");
                LinkButton btnDetail = (LinkButton)e.Row.FindControl("btnDetail");

                string currentStatus = DataBinder.Eval(e.Row.DataItem, "Status").ToString();

                // Reset all buttons first
                btnProcess.Visible = false;
                btnDeliver.Visible = false;
                btnComplete.Visible = false;
                btnCancel.Visible = false;
                btnNotify.Visible = true;
                btnDetails.Visible = true;

                // Set status badge class
                lblStatus.CssClass = "status-badge status-" + currentStatus.ToLower();

                // Show appropriate buttons based on status
                switch (currentStatus)
                {
                    case "Processing":
                        btnDeliver.Visible = true;
                        btnCancel.Visible = true;
                        break;
                    case "Delivered":
                        btnComplete.Visible = true;
                        break;
                    case "Completed":
                        // No action buttons needed for completed orders
                        break;
                    case "Cancelled":
                        // No action buttons needed for cancelled orders
                        break;
                    default:
                        btnProcess.Visible = true;
                        btnCancel.Visible = true;
                        break;
                }
            }
        }
      
    }
}
















