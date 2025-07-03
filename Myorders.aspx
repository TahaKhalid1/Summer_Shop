<%@ Page Title="My Orders" Language="C#" MasterPageFile="~/User/User.Master" AutoEventWireup="true" 
    CodeBehind="MyOrders.aspx.cs" Inherits="Next_ae.User.MyOrders" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .orders-container {
            padding: 50px 0;
            background-color: #f8f9fa;
        }
        .orders-title {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 30px;
            color: #2c3e50;
            position: relative;
            padding-bottom: 15px;
        }
        .orders-title:after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 60px;
            height: 3px;
            background: #717fe0;
        }
        .order-card {
            background: white;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            margin-bottom: 30px;
            overflow: hidden;
        }
        .order-header {
            padding: 15px 20px;
            border-bottom: 1px solid #eee;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            background-color: #f9f9f9;
        }
        .order-number {
            font-weight: 600;
            color: #2c3e50;
        }
        .order-date {
            color: #666;
            font-size: 14px;
        }
        .order-status {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            text-transform: uppercase;
        }
        .status-processing {
            background-color: #fff3cd;
            color: #856404;
        }
        .status-shipped {
            background-color: #cce5ff;
            color: #004085;
        }
        .status-delivered {
            background-color: #d4edda;
            color: #155724;
        }
        .status-cancelled {
            background-color: #f8d7da;
            color: #721c24;
        }
        .order-body {
            padding: 20px;
        }
        .order-item {
            display: flex;
            padding: 15px 0;
            border-bottom: 1px solid #eee;
        }
        .order-item:last-child {
            border-bottom: none;
        }
        .item-image {
            width: 80px;
            height: 80px;
            border-radius: 4px;
            object-fit: cover;
            margin-right: 15px;
        }
        .item-details {
            flex-grow: 1;
        }
        .item-name {
            font-weight: 600;
            margin-bottom: 5px;
            color: #2c3e50;
        }
        .item-price {
            color: #717fe0;
            font-weight: 600;
        }
        .item-quantity {
            color: #666;
            font-size: 14px;
        }
        .order-summary {
            padding: 20px;
            background-color: #f9f9f9;
            border-top: 1px solid #eee;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 10px;
        }
        .summary-label {
            color: #666;
        }
        .summary-value {
            font-weight: 600;
        }
        .summary-total {
            font-size: 18px;
            color: #2c3e50;
            padding-top: 10px;
            border-top: 1px solid #ddd;
            margin-top: 10px;
        }
        .order-actions {
            display: flex;
            justify-content: flex-end;
            padding: 15px 20px;
            border-top: 1px solid #eee;
        }
        .btn-action {
            padding: 8px 15px;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 500;
            margin-left: 10px;
            cursor: pointer;
            transition: all 0.3s;
        }
        .btn-track {
            background-color: #717fe0;
            color: white;
            border: 1px solid #717fe0;
        }
        .btn-track:hover {
            background-color: #5a6bd1;
        }
        .btn-cancel {
            background-color: white;
            color: #e74c3c;
            border: 1px solid #e74c3c;
        }
        .btn-cancel:hover {
            background-color: #f8d7da;
        }
        .btn-view {
            background-color: white;
            color: #2c3e50;
            border: 1px solid #ddd;
        }
        .btn-view:hover {
            background-color: #f1f1f1;
        }
        .btn-reorder {
            background-color: white;
            color: #28a745;
            border: 1px solid #28a745;
        }
        .btn-reorder:hover {
            background-color: #d4edda;
        }
        .empty-orders {
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
        .pagination {
            display: flex;
            justify-content: center;
            margin-top: 30px;
        }
        .page-item {
            margin: 0 5px;
        }
        .page-link {
            display: block;
            padding: 8px 15px;
            border: 1px solid #ddd;
            border-radius: 4px;
            color: #717fe0;
            font-weight: 500;
        }
        .page-link:hover {
            background-color: #f1f1f1;
            text-decoration: none;
        }
        .page-item.active .page-link {
            background-color: #717fe0;
            color: white;
            border-color: #717fe0;
        }
        .order-filter {
            margin-bottom: 30px;
            background-color: white;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .filter-title {
            font-weight: 600;
            margin-bottom: 15px;
            color: #2c3e50;
        }
        .filter-options {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        .filter-option {
            padding: 8px 15px;
            border-radius: 20px;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.3s;
            border: 1px solid #ddd;
        }
        .filter-option:hover, .filter-option.active {
            background-color: #717fe0;
            color: white;
            border-color: #717fe0;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="bg0 p-t-75 p-b-85 orders-container">
        <div class="container">
            <h1 class="orders-title">My Orders</h1>
            
            <!-- Order Filter -->
            <div class="order-filter">
                <div class="filter-title">Filter Orders</div>
                <div class="filter-options">
                    <div class="filter-option active" onclick="filterOrders('all')">All Orders</div>
                    <div class="filter-option" onclick="filterOrders('processing')">Processing</div>
                    <div class="filter-option" onclick="filterOrders('shipped')">Shipped</div>
                    <div class="filter-option" onclick="filterOrders('delivered')">Delivered</div>
                    <div class="filter-option" onclick="filterOrders('cancelled')">Cancelled</div>
                </div>
            </div>
            
            <asp:Panel ID="pnlOrders" runat="server">
                <asp:Repeater ID="rptOrders" runat="server" OnItemDataBound="rptOrders_ItemDataBound">
                    <ItemTemplate>
                        <div class="order-card">
                            <div class="order-header">
                                <div>
                                    <span class="order-number">Order #<%# Eval("OrderID") %></span>
                                    <span class="order-date">Placed on <%# Convert.ToDateTime(Eval("OrderDate")).ToString("MMM dd, yyyy") %></span>
                                </div>
                                <div>
                                    <span class="order-status status-<%# GetStatusClass(Eval("Status").ToString()) %>">
                                        <%# Eval("Status") %>
                                    </span>
                                </div>
                            </div>
                            
                            <div class="order-body">
                                <asp:Repeater ID="rptOrderItems" runat="server">
                                    <ItemTemplate>
                                        <div class="order-item">
                                            <asp:Image ID="imgProduct" runat="server" CssClass="item-image" 
                                                ImageUrl='<%# Eval("ProductImageUrl") %>' AlternateText='<%# Eval("ProductName") %>' />
                                            <div class="item-details">
                                                <div class="item-name"><%# Eval("ProductName") %></div>
                                                <div class="item-price"><%# Convert.ToDecimal(Eval("UnitPrice")).ToString("C") %></div>
                                                <div class="item-quantity">Quantity: <%# Eval("Quantity") %></div>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                            
                            <div class="order-summary">
                                <div class="summary-row">
                                    <span class="summary-label">Subtotal</span>
                                    <span class="summary-value"><%# Convert.ToDecimal(Eval("TotalAmount")).ToString("C") %></span>
                                </div>
                                <div class="summary-row">
                                    <span class="summary-label">Shipping</span>
                                    <span class="summary-value">Free</span>
                                </div>
                                <div class="summary-row summary-total">
                                    <span class="summary-label">Total</span>
                                    <span class="summary-value"><%# Convert.ToDecimal(Eval("TotalAmount")).ToString("C") %></span>
                                </div>
                            </div>
                            
                            <div class="order-actions">
                                <asp:HyperLink ID="hlViewOrder" runat="server" CssClass="btn-action btn-view" 
                                    NavigateUrl='<%# "~/User/OrderDetails.aspx?orderId=" + Eval("OrderID") %>'>
                                    View Details
                                </asp:HyperLink>
                                
                                <asp:LinkButton ID="btnCancelOrder" runat="server" CssClass="btn-action btn-cancel" 
                                    Visible='<%# Eval("Status").ToString() == "Processing" %>'
                                    CommandArgument='<%# Eval("OrderID") %>' OnClick="btnCancelOrder_Click">
                                    Cancel Order
                                </asp:LinkButton>
                                
                                <asp:LinkButton ID="btnReorder" runat="server" CssClass="btn-action btn-reorder" 
                                    CommandArgument='<%# Eval("OrderID") %>' OnClick="btnReorder_Click">
                                    Reorder
                                </asp:LinkButton>
                                
                                <asp:HyperLink ID="hlTrackOrder" runat="server" CssClass="btn-action btn-track" 
                                    Visible='<%# Eval("Status").ToString() != "Delivered" && Eval("Status").ToString() != "Cancelled" %>'
                                    NavigateUrl='<%# "~/User/TrackOrder.aspx?orderId=" + Eval("OrderID") %>'>
                                    Track Order
                                </asp:HyperLink>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                
                <asp:Panel ID="pnlEmptyOrders" runat="server" Visible="false" CssClass="empty-orders">
                    <div class="empty-icon">
                        <i class="zmdi zmdi-shopping-cart"></i>
                    </div>
                    <h3 class="empty-title">You haven't placed any orders yet</h3>
                    <p class="empty-text">When you place an order, you'll see it here.</p>
                    <asp:HyperLink ID="hlContinueShopping" runat="server" CssClass="btn-shop" 
                        NavigateUrl="~/Default.aspx">
                        Continue Shopping
                    </asp:HyperLink>
                </asp:Panel>
                
                <!-- Pagination -->
                <div class="pagination" id="paginationContainer" runat="server">
                    <asp:LinkButton ID="lnkPrevious" runat="server" CssClass="page-item" OnClick="lnkPrevious_Click">
                        <span class="page-link">&laquo; Previous</span>
                    </asp:LinkButton>
                    
                    <asp:Repeater ID="rptPagination" runat="server">
                        <ItemTemplate>
                            <asp:LinkButton ID="lnkPage" runat="server" CssClass='<%# "page-item " + (Convert.ToInt32(Eval("PageNumber")) == CurrentPage ? "active" : "") %>'
                                CommandArgument='<%# Eval("PageNumber") %>' OnClick="lnkPage_Click">
                                <span class="page-link"><%# Eval("PageNumber") %></span>
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <asp:LinkButton ID="lnkNext" runat="server" CssClass="page-item" OnClick="lnkNext_Click">
                        <span class="page-link">Next &raquo;</span>
                    </asp:LinkButton>
                </div>
            </asp:Panel>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="../UserTemplate/vendor/sweetalert/sweetalert.min.js"></script>
    <link rel="stylesheet" href="../UserTemplate/vendor/sweetalert/sweetalert.css">
    
    <script>
        function filterOrders(status) {
            // Update active filter button
            $('.filter-option').removeClass('active');
            $('.filter-option').each(function() {
                if ($(this).text().toLowerCase().includes(status) || 
                    (status === 'all' && $(this).text().includes('All Orders'))) {
                    $(this).addClass('active');
                }
            });
            
            // Show/hide orders based on status
            $('.order-card').each(function() {
                var orderStatus = $(this).find('.order-status').text().toLowerCase();
                if (status === 'all' || orderStatus.includes(status)) {
                    $(this).show();
                } else {
                    $(this).hide();
                }
            });
        }
        
        function confirmCancel(orderId) {
            swal({
                title: "Are you sure?",
                text: "You won't be able to revert this!",
                type: "warning",
                showCancelButton: true,
                confirmButtonColor: "#e74c3c",
                confirmButtonText: "Yes, cancel it!",
                closeOnConfirm: false
            }, function() {
                // Call server-side method to cancel order
                $.ajax({
                    type: "POST",
                    url: '<%= ResolveUrl("MyOrders.aspx/CancelOrder") %>',
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    data: JSON.stringify({ orderId: orderId }),
                    success: function(response) {
                        if (response.d.success) {
                            swal({
                                title: "Cancelled!",
                                text: "Your order has been cancelled.",
                                type: "success"
                            }, function() {
                                location.reload();
                            });
                        } else {
                            swal("Error", response.d.message, "error");
                        }
                    },
                    error: function(xhr, status, error) {
                        swal("Error", "Failed to cancel order: " + error, "error");
                    }
                });
            });
        }
    </script>
</asp:Content>