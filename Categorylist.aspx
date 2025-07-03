<%@ Page Title="Category List" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="CategoryList.aspx.cs" Inherits="Next_ae.User.CategoryList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        .category-list-container {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 20px;
        }
        .breadcrumb {
            font-size: 14px;
            color: #666;
            margin-bottom: 15px;
        }
        .breadcrumb a {
            color: #5a8dee;
            text-decoration: none;
        }
        .breadcrumb-separator {
            margin: 0 5px;
            color: #999;
        }
        .category-list-title {
            font-size: 18px;
            font-weight: 600;
            color: #222f3e;
            margin-bottom: 15px;
        }
        .header-actions {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 20px;
        }
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 8px 12px;
            border-radius: 4px;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
            border: none;
        }
        .btn-primary {
            background-color: #5a8dee;
            color: #fff;
        }
        .search-box {
            position: relative;
            margin-left: auto;
        }
        .search-input {
            padding: 8px 12px 8px 30px;
            border-radius: 4px;
            border: 1px solid #e0e0e0;
            outline: none;
            width: 200px;
            font-size: 13px;
        }
        .category-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        .category-table th {
            padding: 8px 12px;
            text-align: left;
            font-weight: 600;
            color: #555;
            background-color: #f9f9f9;
        }
        .category-table td {
            padding: 8px 12px;
            vertical-align: middle;
            color: #444;
        }
        .category-table tr:not(:last-child) td {
            border-bottom: 1px solid #f0f0f0;
        }
        .status-badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: 500;
        }
        .status-active {
            background-color: #e6f7ee;
            color: #10b759;
        }
        .status-inactive {
            background-color: #feeaea;
            color: #ff4d4f;
        }
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        .btn-icon {
            padding: 3px 6px;
            border-radius: 3px;
            font-size: 11px;
            cursor: pointer;
            border: none;
            background: none;
        }
        .btn-edit {
            color: #5a8dee;
        }
        .btn-delete {
            color: #ff5b5c;
        }
        .subcategory-indent {
            padding-left: 20px;
        }
        .parent-category-name {
            font-size: 11px;
            color: #777;
            font-style: italic;
            margin-left: 5px;
        }
        .empty-table {
            text-align: center;
            padding: 40px;
            color: #999;
        }
    </style>
    
    <script type="text/javascript">
        function confirmDelete(categoryId, categoryName) {
            Swal.fire({
                title: 'Delete Category?',
                text: `Are you sure you want to delete "${categoryName}"?`,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ff5b5c',
                cancelButtonColor: '#a3afbd',
                confirmButtonText: 'Yes, delete it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Show loading indicator
                    Swal.fire({
                        title: 'Deleting...',
                        html: 'Please wait while we delete the category',
                        allowOutsideClick: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });

                    // Make AJAX call to delete the category
                    $.ajax({
                        type: "POST",
                        url: "<%= ResolveUrl("~/User/CategoryList.aspx/DeleteCategory") %>",
                data: JSON.stringify({ 
                    categoryId: categoryId, 
                    categoryType: document.getElementById('<%= hdnCategoryType.ClientID %>').value
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Deleted!',
                        text: 'Category has been deleted',
                        confirmButtonColor: '#5a8dee'
                    }).then(() => {
                        // Refresh the page to see changes
                        location.reload();
                    });
                },
                error: function (xhr, status, error) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to delete category: ' + xhr.responseJSON.Message,
                        confirmButtonColor: '#5a8dee'
                    });
                }
            });
        }
    });
        }
    </script>
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:HiddenField ID="hdnCategoryType" runat="server" />
    <div class="category-list-container">
        <div class="breadcrumb">
            <a href="#">Home</a>
            <span class="breadcrumb-separator">/</span>
            <a href="#">Categories</a>
        </div>
        
        <h1 class="category-list-title">Category list</h1>
        
        <div class="header-actions">
            <asp:HyperLink ID="btnAddCategory" runat="server" CssClass="btn btn-primary" NavigateUrl="~/Admin/Categorylisting.aspx">
                <i class="fas fa-plus"></i> Add Category
            </asp:HyperLink>
            
            <div class="search-box">
                <i class="fas fa-search search-icon"></i>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Search categories..." 
                    AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
            </div>
        </div>
        
        <asp:GridView ID="gvCategories" runat="server" AutoGenerateColumns="false" CssClass="category-table"
            DataKeyNames="CategoryID" OnRowCommand="gvCategories_RowCommand">
            <Columns>
                <asp:TemplateField HeaderText="Name">
                    <ItemTemplate>
                        <div class='<%# Eval("IsSubCategory").ToString() == "1" ? "subcategory-indent" : "" %>'>
                            <%# Eval("Name") %>
                            <asp:Label runat="server" CssClass="parent-category-name" 
                                Visible='<%# Eval("IsSubCategory").ToString() == "1" %>'
                                Text='<%# "(Parent: " + Eval("ParentCategoryName") + ")" %>' />
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="Type" HeaderText="Type" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <span class='status-badge status-<%# Eval("Status").ToString().ToLower() %>'>
                            <%# Eval("Status") %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <div class="action-buttons">
                            <asp:HyperLink ID="btnEdit" runat="server" CssClass="btn-icon btn-edit"
                                NavigateUrl='<%# "~/Admin/Categorylisting.aspx?id=" + Eval("CategoryID") + "&type=" + (Eval("IsSubCategory").ToString() == "1" ? "sub" : "main") %>'>
                                <i class="fas fa-edit"></i>
                            </asp:HyperLink>
                            <button class="btn-icon btn-delete" 
                                onclick='document.getElementById("<%= hdnCategoryType.ClientID %>").value = "<%# Eval("IsSubCategory").ToString() == "1" ? "sub" : "main" %>"; confirmDelete(<%# Eval("CategoryID") %>, "<%# Eval("Name").ToString().Replace("\"", "\\\"") %>"); return false;'>
                                <i class="fas fa-trash"></i>
                            </button>
                                                    </div>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <EmptyDataTemplate>
                <tr>
                    <td colspan="4" class="empty-table">
                        <div class="empty-icon">
                            <i class="fas fa-box-open"></i>
                        </div>
                        <h3>No categories found</h3>
                        <p>Click "Add Category" to create your first category</p>
                    </td>
                </tr>
            </EmptyDataTemplate>
        </asp:GridView>
    </div>
</asp:Content>