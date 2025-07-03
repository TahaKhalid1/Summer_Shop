using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;

namespace Next_ae
{
    public class Global : System.Web.HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
        }

        // In Global.asax
        protected void Application_BeginRequest(object sender, EventArgs e)
        {
            if (!Request.Path.StartsWith("/Admin/") && !Request.Path.Contains(".axd"))
            {
                string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;
                string ipAddress = Request.UserHostAddress;
                string pageVisited = Request.Url.AbsolutePath;
                string userAgent = Request.UserAgent;
                string referrer = Request.UrlReferrer != null ? Request.UrlReferrer.AbsoluteUri : null;

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    string query = @"INSERT INTO VisitorLogs 
                           (IPAddress, PageVisited, UserAgent, Referrer)
                           VALUES (@IPAddress, @PageVisited, @UserAgent, @Referrer)";

                    SqlCommand cmd = new SqlCommand(query, con);
                    cmd.Parameters.AddWithValue("@IPAddress", ipAddress);
                    cmd.Parameters.AddWithValue("@PageVisited", pageVisited);
                    cmd.Parameters.AddWithValue("@UserAgent", userAgent ?? (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("@Referrer", referrer ?? (object)DBNull.Value);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }
    }
}