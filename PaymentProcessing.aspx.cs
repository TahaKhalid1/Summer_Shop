using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Next_ae.User
{
    public partial class PaymentProcessing : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["orderId"] == null || Request.QueryString["paymentMethod"] == null)
                {
                    Response.Redirect("Home.aspx");
                }

                hfOrderId.Value = Request.QueryString["orderId"];
                hfPaymentMethod.Value = Request.QueryString["paymentMethod"];
            }
        }

        protected void btnCompletePayment_Click(object sender, EventArgs e)
        {
            int orderId = Convert.ToInt32(hfOrderId.Value);
            string paymentMethod = hfPaymentMethod.Value;

            // Update order and payment status
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                // Start transaction
                con.Open();
                SqlTransaction transaction = con.BeginTransaction();

                try
                {
                    // 1. Update order status
                    SqlCommand cmd = new SqlCommand("UPDATE Orders SET Status = 'Processing' WHERE OrderID = @OrderID", con, transaction);
                    cmd.Parameters.AddWithValue("@OrderID", orderId);
                    cmd.ExecuteNonQuery();

                    // 2. Update payment status if payment method is Stripe
                    if (paymentMethod == "stripe")
                    {
                        string transactionId = "stripe_" + Guid.NewGuid().ToString().Substring(0, 12);

                        cmd = new SqlCommand("UPDATE Payment SET PaymentStatus = 'Completed', PaymentDate = GETDATE() WHERE OrderID = @OrderID", con, transaction);
                        cmd.Parameters.AddWithValue("@OrderID", orderId);
                        cmd.ExecuteNonQuery();
                    }

                    // Commit transaction
                    transaction.Commit();

                    // Redirect to order confirmation
                    Response.Redirect($"OrderConfirmation.aspx?orderId={orderId}");
                }
                catch (Exception )
                {
                    transaction.Rollback();
                    // Log error
                    Response.Redirect($"PaymentError.aspx?orderId={orderId}");
                }
            }
        }
    }
}