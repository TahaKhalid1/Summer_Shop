<%@ Page Title="Product List" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="ProductList.aspx.cs" Inherits="Next_ae.User.ProductList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- SweetAlert for beautiful alerts -->
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* Clean, minimal design */
        .product-list-container {
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
        
        .product-list-title {
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
        
        .btn-primary:hover {
            background-color: #4a7de8;
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
            transition: all 0.2s ease;
        }
        
        .search-input:focus {
            border-color: #5a8dee;
        }
        
        .search-icon {
            position: absolute;
            left: 10px;
            top: 50%;
            transform: translateY(-50%);
            color: #999;
            font-size: 12px;
        }
        
        .product-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        
        .product-table th {
            padding: 8px 12px;
            text-align: left;
            font-weight: 600;
            color: #555;
            background-color: #f9f9f9;
        }
        
        .product-table td {
            padding: 8px 12px;
            vertical-align: middle;
            color: #444;
        }
        
        .product-table tr:not(:last-child) td {
            border-bottom: 1px solid #f0f0f0;
        }
        
        .product-table tr:hover {
            background-color: #f9f9f9;
        }
        
        .product-image {
            width: 40px;
            height: 40px;
            object-fit: cover;
            border-radius: 4px;
            margin-right: 10px;
            vertical-align: middle;
        }
        
        .product-name-cell {
            display: flex;
            align-items: center;
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
        
        .status-draft {
            background-color: #fff8e6;
            color: #faad14;
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
            color: #5a8dee;
        }
        
        .btn-icon i {
            font-size: 12px;
        }
        
        .btn-delete {
            color: #ff5b5c;
        }
        
        .date-text {
            color: #888;
            font-size: 11px;
        }
        
        .empty-table {
            text-align: center;
            padding: 40px;
            color: #999;
        }
        
        .empty-icon {
            font-size: 48px;
            margin-bottom: 15px;
            color: #ddd;
        }
    </style>
    
    <script type="text/javascript">
        function confirmDelete(productId, productName) {
            Swal.fire({
                title: 'Delete Product?',
                text: `Are you sure you want to delete "${productName}"?`,
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
                        html: 'Please wait while we delete the product',
                        allowOutsideClick: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });

                    // Make AJAX call to delete the product
                    $.ajax({
                        type: "POST",
                        url: "<%= ResolveUrl("~/Admin/ProductList.aspx/DeleteProduct") %>",
                data: JSON.stringify({ productId: productId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Deleted!',
                        text: 'Product has been deleted',
                        confirmButtonColor: '#5a8dee'
                    }).then(() => {
                        // Refresh the page or update the table
                        location.reload();
                    });
                },
                error: function (xhr, status, error) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to delete product: ' + xhr.responseJSON.Message,
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
    <div class="product-list-container">
        <div class="breadcrumb">
            <a href="#">Home</a>
            <span class="breadcrumb-separator">/</span>
            <a href="#">Products</a>
        </div>
        
        <h1 class="product-list-title">Product list</h1>
        
        <div class="header-actions">
            <asp:HyperLink ID="btnAddProduct" runat="server" CssClass="btn btn-primary" NavigateUrl="~/Admin/Productlisting.aspx">
                <i class="fas fa-plus"></i> Add product
            </asp:HyperLink>
            
            <div class="search-box">
                <i class="fas fa-search search-icon"></i>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Search product..." 
                    AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
            </div>
            
            <span class="date-text"><%= DateTime.Now.ToString("dd MMM, yy") %></span>
        </div>
        
        <asp:GridView ID="gvProducts" runat="server" AutoGenerateColumns="false" CssClass="product-table"
            DataKeyNames="ProductID" OnRowDataBound="gvProducts_RowDataBound" OnRowCommand="gvProducts_RowCommand">
            <Columns>
                <asp:TemplateField HeaderText="Name">
                    <ItemTemplate>
                        <div class="product-name-cell">
                            <asp:Image ID="imgProduct" runat="server" CssClass="product-image" 
                                ImageUrl='<%# GetProductImageUrl(Eval("ProductID").ToString()) %>' 
                                AlternateText='<%# Eval("ProductName") %>' />
                            <%# Eval("ProductName") %>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="CategoryName" HeaderText="Category" />
                <asp:BoundField DataField="Price" HeaderText="Price" DataFormatString="${0:N2}" HtmlEncode="false" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <span class="status-badge status-<%# Eval("Status").ToString().ToLower() %>">
                            <%# Eval("Status") %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="Inventory" HeaderText="Inventory" />
                <asp:TemplateField HeaderText="Published">
                    <ItemTemplate>
                        <span class="date-text"><%# Eval("PublishedDate", "{0:dd MMM, yy}") %></span>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <div class="action-buttons">
                            <asp:HyperLink ID="lnkEdit" runat="server" CssClass="btn-icon" 
                                NavigateUrl='<%# "~/Admin/Productlisting.aspx?id=" + Eval("ProductID") %>'>
                                <i class="fas fa-edit"></i>
                            </asp:HyperLink>
                             <button class="btn-icon btn-delete" 
                                onclick='confirmDelete(<%# Eval("ProductID") %>, "<%# Eval("ProductName").ToString().Replace("\"", "\\\"") %>"); return false;'>
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <EmptyDataTemplate>
                <tr>
                    <td colspan="7" class="empty-table">
                        <div class="empty-icon">
                            <i class="fas fa-box-open"></i>
                        </div>
                        <h3>No products found</h3>
                        <p>Click "Add product" to create your first product</p>
                    </td>
                </tr>
            </EmptyDataTemplate>
        </asp:GridView>
    </div>
</asp:Content>