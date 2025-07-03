<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/User/User.Master" AutoEventWireup="true" 
    CodeBehind="Profile.aspx.cs" Inherits="Next_ae.User.Profile" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .profile-container {
            padding: 50px 0;
            background-color: #f8f9fa;
            min-height: calc(100vh - 160px);
        }
        .profile-header {
            text-align: center;
            margin-bottom: 40px;
        }
        .profile-title {
            font-size: 28px;
            font-weight: 700;
            color: #2c3e50;
            margin-bottom: 15px;
        }
        .profile-avatar {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            object-fit: cover;
            border: 5px solid white;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            margin-bottom: 20px;
            background-color: #717fe0;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            margin: 0 auto 20px;
        }
        .profile-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.05);
            padding: 30px;
            margin-bottom: 30px;
        }
        .profile-section-title {
            font-size: 18px;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f1f1f1;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #555;
        }
        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            transition: all 0.3s;
        }
        .form-control:focus {
            border-color: #717fe0;
            box-shadow: 0 0 0 2px rgba(113, 127, 224, 0.2);
            outline: none;
        }
        .btn-update {
            background-color: #717fe0;
            color: white;
            border: none;
            padding: 10px 25px;
            border-radius: 4px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
            font-size: 14px;
        }
        .btn-update:hover {
            background-color: #5a6bd1;
        }
        .orders-summary {
            background-color: #f9f9f9;
            padding: 15px;
            border-radius: 8px;
            margin-top: 20px;
        }
        .order-stat {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
            padding: 8px 0;
            border-bottom: 1px solid #eee;
        }
        .order-stat:last-child {
            border-bottom: none;
        }
        .order-stat-label {
            color: #666;
        }
        .order-stat-value {
            font-weight: 600;
            color: #2c3e50;
        }
        .change-password-toggle {
            color: #717fe0;
            font-size: 13px;
            cursor: pointer;
            margin-top: 5px;
            display: inline-block;
        }
        .change-password-toggle:hover {
            text-decoration: underline;
        }
        .password-fields {
            display: none;
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid #eee;
        }
        .stats-highlight {
            font-size: 24px;
            font-weight: 700;
            color: #717fe0;
            text-align: center;
            margin-bottom: 5px;
        }
        .stats-label {
            text-align: center;
            color: #666;
            font-size: 14px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="profile-container">
        <div class="container">
            <div class="profile-header">
                <div class="profile-avatar" id="avatarInitials" runat="server"></div>
                <h1 class="profile-title">My Profile</h1>
            </div>

            <div class="row">
                <div class="col-md-6">
                    <div class="profile-card">
                        <h3 class="profile-section-title">Personal Information</h3>
                        
                        <div class="form-group">
                            <label class="form-label">First Name</label>
                            <asp:TextBox ID="txtFirstName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Last Name</label>
                            <asp:TextBox ID="txtLastName" runat="server" CssClass="form-control"></asp:TextBox>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Email Address</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email"></asp:TextBox>
                        </div>
                        
                        <div class="form-group">
                            <label class="form-label">Phone Number</label>
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" TextMode="Phone"></asp:TextBox>
                        </div>
                        
                        <div class="form-group">
                            <span class="change-password-toggle" onclick="togglePasswordFields()">Change Password</span>
                            <div class="password-fields" id="passwordFields">
                                <div class="form-group">
                                    <label class="form-label">Current Password</label>
                                    <asp:TextBox ID="txtCurrentPassword" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">New Password</label>
                                    <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Confirm New Password</label>
                                    <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                        
                        <asp:Button ID="btnUpdateProfile" runat="server" Text="Update Profile" CssClass="btn-update" OnClick="btnUpdateProfile_Click" />
                    </div>
                </div>
                
                <div class="col-md-6">
                    <div class="profile-card">
                        <h3 class="profile-section-title">Order Statistics</h3>
                        
                        <div class="row text-center" style="margin-bottom: 20px;">
                            <div class="col-md-4">
                                <div class="stats-highlight"><asp:Literal ID="litTotalOrders" runat="server" Text="0"></asp:Literal></div>
                                <div class="stats-label">Total Orders</div>
                            </div>
                            <div class="col-md-4">
                                <div class="stats-highlight"><asp:Literal ID="litCompletedOrders" runat="server" Text="0"></asp:Literal></div>
                                <div class="stats-label">Completed</div>
                            </div>
                            <div class="col-md-4">
                                <div class="stats-highlight"><asp:Literal ID="litPendingOrders" runat="server" Text="0"></asp:Literal></div>
                                <div class="stats-label">Pending</div>
                            </div>
                        </div>
                        
                        <div class="orders-summary">
                            <div class="order-stat">
                                <span class="order-stat-label">Last Order Date</span>
                                <span class="order-stat-value"><asp:Literal ID="litLastOrderDate" runat="server" Text="N/A"></asp:Literal></span>
                            </div>
                            <div class="order-stat">
                                <span class="order-stat-label">Total Spent</span>
                                <span class="order-stat-value">Rs. <asp:Literal ID="litTotalSpent" runat="server" Text="0"></asp:Literal></span>
                            </div>
                            <div class="order-stat">
                                <span class="order-stat-label">Member Since</span>
                                <span class="order-stat-value"><asp:Literal ID="litMemberSince" runat="server"></asp:Literal></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="../UserTemplate/vendor/sweetalert/sweetalert.min.js"></script>
    <link rel="stylesheet" href="../UserTemplate/vendor/sweetalert/sweetalert.css">
    
    <script>
        function togglePasswordFields() {
            $('#passwordFields').slideToggle();
        }
        
        $(document).ready(function() {
            // Show success message if exists
            <% if (!string.IsNullOrEmpty(Request.QueryString["success"])) { %>
                swal("Success", "<%= Server.HtmlEncode(Request.QueryString["success"]) %>", "success");
            <% } %>
            
            // Show error message if exists
            <% if (!string.IsNullOrEmpty(Request.QueryString["error"])) { %>
                swal("Error", "<%= Server.HtmlEncode(Request.QueryString["error"]) %>", "error");
            <% } %>
        });
    </script>
</asp:Content>