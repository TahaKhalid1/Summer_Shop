<%@ Page Title="Manage Categories" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="CategoryManagement.aspx.cs" Inherits="Next_ae.User.CategoryManagement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- SweetAlert for beautiful alerts -->
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <script type="text/javascript">
        function showSuccessMessage(message) {
            Swal.fire({
                icon: 'success',
                title: 'Success!',
                text: message,
                confirmButtonColor: '#5a8dee'
            });
        }

        function showErrorMessage(message) {
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: message,
                confirmButtonColor: '#ff5b5c'
            });
        }

        function toggleCategoryType() {
            const categoryType = document.getElementById('<%= rblCategoryType.ClientID %>');
            const categoryDropdown = document.getElementById('<%= ddlParentCategory.ClientID %>').parentNode;
            
            if (categoryType.querySelector('input[value="SubCategory"]').checked) {
                categoryDropdown.style.display = 'block';
            } else {
                categoryDropdown.style.display = 'none';
            }
        }

        document.addEventListener('DOMContentLoaded', function() {
            toggleCategoryType();
            
            document.getElementById('<%= rblCategoryType.ClientID %>').addEventListener('change', toggleCategoryType);
        });
    </script>
    
    <style>
        .card {
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.02);
            margin-bottom: 20px;
        }

        .card-header {
            padding: 15px 20px;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background-color: black;
        }

        .card-title {
            font-size: 16px;
            font-weight: 600;
            color: white;
        }

        .card-body {
            padding: 20px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: 500;
            color: #222f3e;
        }

        .form-control {
            width: 100%;
            padding: 10px 15px;
            border-radius: 5px;
            border: 1px solid #ddd;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 8px 16px;
            border-radius: 5px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            border: none;
        }

        .btn-primary {
            background-color: #5a8dee;
            color: #fff;
        }

        .btn-success {
            background-color: #39da8a;
            color: #fff;
        }

        .error-message {
            color: #ff5b5c;
            font-size: 12px;
            margin-top: 5px;
            display: none;
        }

        .has-error .form-control {
            border-color: #ff5b5c;
        }

        .category-type-selector {
            margin-bottom: 20px;
        }
        
        .category-type-option {
            display: inline-block;
            margin-right: 15px;
        }

        .form-switch {
            position: relative;
            display: inline-block;
            width: 50px;
            height: 24px;
        }

        .form-switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #ccc;
            transition: .4s;
            border-radius: 24px;
        }

        .slider:before {
            position: absolute;
            content: "";
            height: 16px;
            width: 16px;
            left: 4px;
            bottom: 4px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
        }

        input:checked + .slider {
            background-color: #39da8a;
        }

        input:checked + .slider:before {
            transform: translateX(26px);
        }

        .switch-label {
            margin-left: 10px;
            font-size: 14px;
            color: #475f7b;
            vertical-align: middle;
        }

        .step-actions {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="card">
        <div class="card-header">
            <div class="card-title">Manage Categories</div>
        </div>
        <div class="card-body">
            <div class="category-type-selector">
                <asp:RadioButtonList ID="rblCategoryType" runat="server" RepeatDirection="Horizontal" CssClass="category-type-options" AutoPostBack="true" OnSelectedIndexChanged="rblCategoryType_SelectedIndexChanged">
                    <asp:ListItem Value="Category" Selected="True" CssClass="category-type-option">Add Category</asp:ListItem>
                    <asp:ListItem Value="SubCategory" CssClass="category-type-option">Add Sub Category</asp:ListItem>
                </asp:RadioButtonList>
            </div>
            
            <div class="form-group" id="parentCategoryGroup" runat="server" style="display:none;">
                <label class="form-label">Parent Category</label>
                <asp:DropDownList ID="ddlParentCategory" runat="server" CssClass="form-control" AutoPostBack="false">
                    <asp:ListItem Value="0">-- Select Category --</asp:ListItem>
                </asp:DropDownList>
                <div class="error-message">Please select a parent category</div>
            </div>
            
            <div class="form-group">
                <asp:Label ID="lblName" runat="server" CssClass="form-label" Text="Category Name"></asp:Label>
                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Enter name"></asp:TextBox>
                <div class="error-message">Please enter a name</div>
            </div>
            
            <div class="form-group">
                <label class="form-label">Status</label>
                <div>
                    <label class="form-switch">
                        <asp:CheckBox ID="cbIsActive" runat="server" Checked="true" />
                        <span class="slider"></span>
                    </label>
                    <span class="switch-label">Active</span>
                </div>
            </div>
            
            <div class="step-actions">
                
                <asp:Button ID="btnPublish" runat="server" Text="Publish" CssClass="btn btn-success" OnClick="btnPublish_Click" />
            </div>
        </div>
    </div>
</asp:Content>