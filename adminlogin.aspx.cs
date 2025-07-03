using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;
using System.Security.Cryptography;
using System.Text;
using System.Web.Configuration;
using System.Web;
using System.Web.Script.Services;
using System.Web.Script.Serialization;
using System.Web.Security;
using System.Linq;
using System.Diagnostics;

namespace Next_ae.Admin
{
    public partial class adminlogin : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirect to dashboard if already logged in
            if (Session["IsAdminAuthenticated"] != null && (bool)Session["IsAdminAuthenticated"])
            {
                Response.Redirect("Dashboard.aspx");
            }

        }


            //[WebMethod(EnableSession = true)]
            //[ScriptMethod(ResponseFormat = ResponseFormat.Json)]
            //public static string LoginAdmin(string username, string password, bool remember)
            //{
            //    try
            //    {
            //        string connectionString = WebConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            //        using (SqlConnection conn = new SqlConnection(connectionString))
            //        {
            //            conn.Open();

            //            string query = @"SELECT AdminID, Username, PasswordHash, Role 
            //                  FROM Admin 
            //                  WHERE Username = @Username AND IsActive = 1";

            //            using (SqlCommand cmd = new SqlCommand(query, conn))
            //            {
            //                cmd.Parameters.AddWithValue("@Username", username);

            //                using (SqlDataReader reader = cmd.ExecuteReader())
            //                {
            //                    if (reader.Read())
            //                    {
            //                        string storedHash = reader["PasswordHash"].ToString();

            //                        // Compute simple hash for comparison
            //                        byte[] computedHashBytes;
            //                        using (SHA1 sha1 = SHA1.Create())
            //                        {
            //                            computedHashBytes = sha1.ComputeHash(
            //                                Encoding.UTF8.GetBytes(password));
            //                        }
            //                        string computedHash = BitConverter.ToString(computedHashBytes)
            //                            .Replace("-", "");

            //                        if (storedHash.Equals(computedHash, StringComparison.OrdinalIgnoreCase))
            //                        {
            //                            // Create authentication ticket
            //                            FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(
            //                                1,
            //                                username,
            //                                DateTime.Now,
            //                                DateTime.Now.AddMinutes(30),
            //                                remember,
            //                                reader["Role"].ToString(),
            //                                FormsAuthentication.FormsCookiePath);

            //                            string encryptedTicket = FormsAuthentication.Encrypt(ticket);
            //                            HttpCookie authCookie = new HttpCookie(
            //                                FormsAuthentication.FormsCookieName,
            //                                encryptedTicket);
            //                            HttpContext.Current.Response.Cookies.Add(authCookie);

            //                            // Set session variables
            //                            HttpContext.Current.Session["AdminID"] = reader["AdminID"];
            //                            HttpContext.Current.Session["AdminUsername"] = username;
            //                            HttpContext.Current.Session["AdminRole"] = reader["Role"];

            //                            return "{\"Success\":true,\"RedirectUrl\":\"Dashboard.aspx\"}";
            //                        }
            //                        else
            //                        {
            //                            return "{\"Success\":false,\"Message\":\"Invalid credentials\"}";
            //                        }
            //                    }
            //                    else
            //                    {
            //                        return "{\"Success\":false,\"Message\":\"Account not found\"}";
            //                    }
            //                }
            //            }
            //        }
            //    }
            //    catch (Exception ex)
            //    {
            //        // Simple error handling without file logging
            //        return "{\"Success\":false,\"Message\":\"Login failed. Please try again.\"}";
            //    }
            //}

        [WebMethod(EnableSession = true)]
        public static string LoginAdmin(string username, string password, bool remember)
        {
            if (username == "Admin" && password == "Admin@2000")
            {
                HttpContext.Current.Session["AdminID"] = 1;
                HttpContext.Current.Session["AdminUsername"] = "admin";
                HttpContext.Current.Session["IsAdminAuthenticated"] = true;
                return "{\"Success\":true,\"RedirectUrl\":\"Dashboard.aspx\"}";
            }
            return "{\"Success\":false,\"Message\":\"Invalid credentials\"}";
        }

        private static string GenerateSalt()
        {
            byte[] saltBytes = new byte[16];
            using (var rng = System.Security.Cryptography.RandomNumberGenerator.Create())
            {
                rng.GetBytes(saltBytes);
            }
            return Convert.ToBase64String(saltBytes);
        }

        private static string HashPassword(string password, string salt)
        {
            using (var pbkdf2 = new System.Security.Cryptography.Rfc2898DeriveBytes(
                password,
                System.Text.Encoding.UTF8.GetBytes(salt),
                10000,
                System.Security.Cryptography.HashAlgorithmName.SHA256))
            {
                byte[] hash = pbkdf2.GetBytes(32);
                return Convert.ToBase64String(hash);
            }
        }
        public class LoginResult
        {
            public bool Success { get; set; }
            public string RedirectUrl { get; set; }
            public string Message { get; set; }
        }

       
        private static bool CompareByteArrays(byte[] a1, byte[] a2)
        {
            if (a1.Length != a2.Length) return false;

            for (int i = 0; i < a1.Length; i++)
            {
                if (a1[i] != a2[i]) return false;
            }

            return true;
        }
    }
}