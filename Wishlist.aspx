<%@ Page Title="My Wishlist" Language="C#" MasterPageFile="~/User/User.Master" AutoEventWireup="true" 
    CodeBehind="Wishlist.aspx.cs" Inherits="Next_ae.User.Wishlist" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .wishlist-container {
            padding: 50px 0;
            background-color: #f8f9fa;
        }
        .wishlist-title {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 30px;
            color: #2c3e50;
            position: relative;
            padding-bottom: 15px;
        }
        .wishlist-title:after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 60px;
            height: 3px;
            background: #717fe0;
        }
        .wishlist-card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 30px;
            overflow: hidden;
        }
        .wishlist-header {
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            background-color: #f9f9f9;
        }
        .wishlist-date {
            color: #666;
            font-size: 14px;
        }
        .wishlist-body {
            padding: 20px;
        }
        .wishlist-item {
            display: flex;
            padding: 15px 0;
            border-bottom: 1px solid #eee;
        }
        .wishlist-item:last-child {
            border-bottom: none;
        }
        .wishlist-image {
            width: 80px;
            height: 80px;
            border-radius: 4px;
            object-fit: cover;
            margin-right: 15px;
        }
        .wishlist-details {
            flex-grow: 1;
        }
        .wishlist-name {
            font-weight: 600;
            margin-bottom: 5px;
            color: #2c3e50;
        }
        .wishlist-price {
            color: #717fe0;
            font-weight: 600;
        }
        .wishlist-actions {
            display: flex;
            justify-content: flex-end;
            padding: 15px 20px;
            border-top: 1px solid #eee;
        }
        .btn-wishlist {
            padding: 8px 15px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 500;
            margin-left: 10px;
            cursor: pointer;
            transition: all 0.3s;
        }
        .btn-addcart {
            background-color: #717fe0;
            color: white;
            border: 1px solid #717fe0;
        }
        .btn-addcart:hover {
            background-color: #5a6bd1;
        }
        .btn-remove {
            background-color: white;
            color: #e74c3c;
            border: 1px solid #e74c3c;
        }
        .btn-remove:hover {
            background-color: #f8d7da;
        }
        .empty-wishlist {
            text-align: center;
            padding: 50px 20px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .empty-icon {
            font-size: 60px;
            color: #ddd;
            margin-bottom: 20px;
        }
        .empty-title {
            font-size: 20px;
            font-weight: 600;
            margin-bottom: 10px;
            color: #2c3e50;
        }
        .empty-text {
            color: #666;
            margin-bottom: 20px;
        }
        .btn-shop {
            padding: 10px 25px;
            background-color: #717fe0;
            color: white;
            border-radius: 4px;
            font-weight: 500;
            display: inline-block;
            transition: all 0.3s;
        }
        .btn-shop:hover {
            background-color: #5a6bd1;
            text-decoration: none;
            color: white;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="bg0 p-t-75 p-b-85 wishlist-container">
        <div class="container">
            <h1 class="wishlist-title">My Wishlist</h1>
            
            <asp:Panel ID="pnlWishlist" runat="server">
                <asp:Repeater ID="rptWishlist" runat="server" OnItemDataBound="rptWishlist_ItemDataBound">
                    <ItemTemplate>
                        <div class="wishlist-card">
                            <div class="wishlist-header">
                                <span class="wishlist-date">Added on <%# Convert.ToDateTime(Eval("AddedDate")).ToString("MMM dd, yyyy") %></span>
                            </div>
                            
                            <div class="wishlist-body">
                                <div class="wishlist-item">
                                    <asp:Image ID="imgProduct" runat="server" CssClass="wishlist-image" 
                                        ImageUrl='<%# Eval("ImageUrl") %>' AlternateText='<%# Eval("ProductName") %>' />
                                    <div class="wishlist-details">
                                        <div class="wishlist-name"><%# Eval("ProductName") %></div>
                                        <div class="wishlist-price">Rs.<%# Convert.ToDecimal(Eval("Price")).ToString("0.00") %></div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="wishlist-actions">
                                <asp:LinkButton ID="btnAddToCart" runat="server" CssClass="btn-wishlist btn-addcart"
                                    CommandArgument='<%# Eval("ProductID") %>' OnClick="btnAddToCart_Click">
                                    Add to Cart
                                </asp:LinkButton>
                                
                                <asp:LinkButton ID="btnRemove" runat="server" CssClass="btn-wishlist btn-remove"
                                    CommandArgument='<%# Eval("WishlistID") + "|" + Eval("ProductID") %>' OnClick="btnRemove_Click">
                                    Remove
                                </asp:LinkButton>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                
                <asp:Panel ID="pnlEmptyWishlist" runat="server" Visible="false" CssClass="empty-wishlist">
                    <div class="empty-icon">
                        <i class="zmdi zmdi-favorite-outline"></i>
                    </div>
                    <h3 class="empty-title">Your wishlist is empty</h3>
                    <p class="empty-text">When you add products to your wishlist, they'll appear here.</p>
                    <asp:HyperLink ID="hlContinueShopping" runat="server" CssClass="btn-shop" 
                        NavigateUrl="~/Default.aspx">
                        Continue Shopping
                    </asp:HyperLink>
                </asp:Panel>
            </asp:Panel>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="../UserTemplate/vendor/sweetalert/sweetalert.min.js"></script>
    <link rel="stylesheet" href="../UserTemplate/vendor/sweetalert/sweetalert.css">
</asp:Content>