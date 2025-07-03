using System;
using System.Data.SqlClient;
using System.Configuration;

namespace Next_ae.Admin
{
    public static class AdminActivityLogger
    {
        public static void LogActivity(int adminId, string activityType, string entityType, int? entityId = null, string description = null)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["NextAeConnection"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                string query = @"INSERT INTO AdminActivities 
                               (AdminID, ActivityType, EntityType, EntityID, Description)
                               VALUES (@AdminID, @ActivityType, @EntityType, @EntityID, @Description)";

                SqlCommand cmd = new SqlCommand(query, con);
                cmd.Parameters.AddWithValue("@AdminID", adminId);
                cmd.Parameters.AddWithValue("@ActivityType", activityType);
                cmd.Parameters.AddWithValue("@EntityType", entityType);
                cmd.Parameters.AddWithValue("@EntityID", entityId ?? (object)DBNull.Value);
                cmd.Parameters.AddWithValue("@Description", description ?? (object)DBNull.Value);

                con.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }
}