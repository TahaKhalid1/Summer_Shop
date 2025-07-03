<%@ Page Title="Order List" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="OrderList.aspx.cs" Inherits="Next_ae.User.OrderList" EnableEventValidation="false" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- SweetAlert for beautiful alerts -->
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* [Keep all existing styles] */
        .order-list-container {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            padding: 20px;
        }
        
        .breadcrumb {
            font-size: 14px;
            color: #666;
            margin-bottom: 15px;
        }
        
        .header-section {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .filter-section {
            display: flex;
            gap: 15px;
            align-items: center;
        }
        
        .filter-dropdown, .search-input {
            padding: 8px 12px;
            border-radius: 4px;
            border: 1px solid #e0e0e0;
            font-size: 13px;
        }
        
        .search-box {
            position: relative;
        }
        
        .search-input {
            padding-left: 30px;
            width: 250px;
        }
        
        .search-icon {
            position: absolute;
            left: 10px;
            top: 50%;
            transform: translateY(-50%);
            color: #999;
        }
        
        .order-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }
        
        .order-table th {
            padding: 12px;
            text-align: left;
            font-weight: 600;
            color: #555;
            background-color: #f9f9f9;
            border-bottom: 2px solid #e0e0e0;
        }
        
        .order-table td {
            padding: 12px;
            vertical-align: middle;
            color: #444;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .order-table tr:hover {
            background-color: #f9f9f9;
        }
        
        .status-badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 500;
        }
        
        .status-processing {
            background-color: #fff8e6;
            color: #faad14;
        }
        
        .status-delivered {
            background-color: #e6f7ee;
            color: #10b759;
        }
        
        .status-completed {
            background-color: #f0f5ff;
            color: #5a8dee;
        }
        
        .status-cancelled {
            background-color: #feeaea;
            color: #ff4d4f;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
            flex-wrap: wrap;
        }
        
        .btn-action {
            padding: 5px 10px;
            border-radius: 4px;
            font-size: 12px;
            cursor: pointer;
            border: none;
            transition: all 0.2s ease;
            display: flex;
            align-items: center;
            gap: 5px;
        }
        
        .btn-process {
            background-color: #fff8e6;
            color: #faad14;
            border: 1px solid #faad14;
        }
        
        .btn-deliver {
            background-color: #e6f7ee;
            color: #10b759;
            border: 1px solid #10b759;
        }
        
        .btn-complete {
            background-color: #f0f5ff;
            color: #5a8dee;
            border: 1px solid #5a8dee;
        }
        
        .btn-cancel {
            background-color: #feeaea;
            color: #ff4d4f;
            border: 1px solid #ff4d4f;
        }
        
        .btn-print {
            background-color: #f0f0f0;
            color: #666;
            border: 1px solid #ddd;
        }
        
        .btn-notify {
            background-color: #e6f3ff;
            color: #1890ff;
            border: 1px solid #1890ff;
        }
        
        .order-id-link {
            color: #5a8dee;
            text-decoration: none;
            font-weight: 500;
        }
        
        .customer-info {
            display: flex;
            flex-direction: column;
        }
        
        .customer-name {
            font-weight: 500;
        }
        
        .customer-contact {
            font-size: 12px;
            color: #888;
        }
        
        .shipping-info {
            font-size: 12px;
            line-height: 1.4;
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
        
        .order-actions {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
        }
        
        /* Add new styles for modal and checkboxes */
        .details-modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.4);
        }
        
        .modal-content {
            background-color: #fefefe;
            margin: 5% auto;
            padding: 20px;
            border: 1px solid #888;
            width: 70%;
            max-height: 80vh;
            overflow-y: auto;
            border-radius: 5px;
            box-shadow: 0 4px 8px 0 rgba(0,0,0,0.2);
        }
        
        .close-modal {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        
        .close-modal:hover {
            color: black;
        }
        
        .export-section {
            margin-bottom: 15px;
            display: flex;
            justify-content: flex-end;
        }
        
        .btn-export {
            background-color: #28a745;
            color: white;
            padding: 8px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
        }
        
        .btn-export:hover {
            background-color: #218838;
        }
        
        .btn-details {
            background-color: #6c757d;
            color: white;
            border: 1px solid #6c757d;
        }
        
        .select-all-checkbox {
            margin-right: 5px;
        }

          /* Enhanced modal styles */
    .order-details-container {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        color: #333;
    }
    
    .order-header {
        background: linear-gradient(135deg, #6a11cb 0%, #2575fc 100%);
        color: white;
        padding: 20px;
        border-radius: 5px 5px 0 0;
        margin-bottom: 20px;
    }
    
    .order-header h2 {
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .order-meta {
        display: flex;
        gap: 20px;
        margin-top: 15px;
        font-size: 14px;
    }
    
    .meta-label {
        font-weight: 600;
        opacity: 0.8;
    }
    
    .order-summary-section {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        margin-bottom: 25px;
        padding: 0 20px;
    }
    
    .customer-info, .shipping-info {
        background: #f9f9f9;
        padding: 15px;
        border-radius: 5px;
        border: 1px solid #eee;
    }
    
    .customer-info h3, .shipping-info h3 {
        margin-top: 0;
        color: #444;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .products-section {
        padding: 0 20px 20px;
    }
    
    .products-section h3 {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #444;
    }
    
    .products-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
        gap: 20px;
        margin-top: 15px;
    }
    
    .product-card {
        display: flex;
        border: 1px solid #e0e0e0;
        border-radius: 5px;
        overflow: hidden;
        transition: transform 0.2s, box-shadow 0.2s;
    }
    
    .product-card:hover {
        transform: translateY(-3px);
        box-shadow: 0 5px 15px rgba(0,0,0,0.1);
    }
    
    .product-image {
        width: 120px;
        height: 120px;
        background: #f5f5f5;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .product-image img {
        max-width: 100%;
        max-height: 100%;
        object-fit: contain;
    }
    
    .product-details {
        flex: 1;
        padding: 15px;
    }
    
    .product-details h4 {
        margin: 0 0 8px 0;
        color: #333;
    }
    
    .product-description {
        font-size: 13px;
        color: #666;
        margin: 5px 0;
    }
    
    .product-specs {
        display: flex;
        gap: 15px;
        margin: 10px 0;
        font-size: 13px;
    }
    
    .product-specs span {
        font-weight: 600;
        color: #555;
    }
    
    .product-pricing {
        display: flex;
        justify-content: space-between;
        font-size: 14px;
        margin-top: 15px;
        padding-top: 10px;
        border-top: 1px dashed #ddd;
    }
    
    .product-pricing span {
        font-weight: 600;
        color: #555;
    }
    
    .total-price {
        font-weight: 600;
        color: #2e7d32;
    }
    
    /* Modal close button */
    .close-modal {
        color: white;
        float: right;
        font-size: 28px;
        font-weight: bold;
        cursor: pointer;
        opacity: 0.8;
        transition: opacity 0.2s;
    }
    
    .close-modal:hover {
        opacity: 1;
    }
    </style>
    
    <script type="text/javascript">
        // [Keep existing JavaScript functions]

        //function showDetailsModal(content) {
        //    var modal = document.createElement('div');
        //    modal.className = 'details-modal';
        //    modal.id = 'detailsModal';
        //    modal.innerHTML = `
        //        <div class="modal-content">
        //            <span class="close-modal" onclick="closeModal()">&times;</span>
        //            ${content}
        //        </div>
        //    `;
        //    document.body.appendChild(modal);
        //    modal.style.display = 'block';
        //}

        function closeModal() {
            var modal = document.getElementById('detailsModal');
            if (modal) {
                modal.style.display = 'none';
                document.body.removeChild(modal);
            }
        }

        function toggleSelectAll(source) {
            var checkboxes = document.querySelectorAll('input[type="checkbox"][name="chkSelect"]');
            for (var i = 0; i < checkboxes.length; i++) {
                checkboxes[i].checked = source.checked;
            }
        }
        function showDetailsModal(content) {
            var modal = document.createElement('div');
            modal.className = 'details-modal';
            modal.id = 'detailsModal';
            modal.innerHTML = `
            <div class="modal-content">
                <span class="close-modal" onclick="closeModal()">&times;</span>
                ${content}
            </div>
        `;
            document.body.appendChild(modal);
            modal.style.display = 'block';

            // Close modal when clicking outside
            modal.addEventListener('click', function (e) {
                if (e.target === modal) {
                    closeModal();
                }
            });
        }

        function confirmStatusChange(orderId, currentStatus, newStatus) {
            Swal.fire({
                title: 'Update Order Status?',
                html: `Change order <b>#${orderId}</b> from <span class="status-badge ${getStatusClass(currentStatus)}">${currentStatus}</span> to <span class="status-badge ${getStatusClass(newStatus)}">${newStatus}</span>?`,
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#5a8dee',
                cancelButtonColor: '#a3afbd',
                confirmButtonText: `Update to ${newStatus}`
            }).then((result) => {
                if (result.isConfirmed) {
                    // Trigger the postback correctly
                    __doPostBack('ctl00$ContentPlaceHolder1$gvOrders', `UpdateStatus$${orderId}|${newStatus}`);
                }
            });
        }

        function getStatusClass(status) {
            switch (status.toLowerCase()) {
                case 'processing': return 'status-processing';
                case 'delivered': return 'status-delivered';
                case 'completed': return 'status-completed';
                case 'cancelled': return 'status-cancelled';
                default: return 'status-processing';
            }
        }


    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="order-list-container">
        <div class="breadcrumb">
            <a href="#">Dashboard</a>
            <span class="breadcrumb-separator">/</span>
            <a href="#">Orders</a>
        </div>
        
        <div class="header-section">
            <h1>Order Management</h1>
            <div class="filter-section">
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="filter-dropdown" AutoPostBack="true" 
                    OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                    <asp:ListItem Value="All" Text="All Orders"></asp:ListItem>
                    <asp:ListItem Value="Processing" Text="Processing" Selected="True"></asp:ListItem>
                    <asp:ListItem Value="Delivered" Text="Delivered"></asp:ListItem>
                    <asp:ListItem Value="Completed" Text="Completed"></asp:ListItem>
                    <asp:ListItem Value="Cancelled" Text="Cancelled"></asp:ListItem>
                </asp:DropDownList>
                
                <div class="search-box">
                    <i class="fas fa-search search-icon"></i>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Search orders..."></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" 
                        OnClick="btnSearch_Click" style="margin-left: 10px;"/>
                </div>
            </div>
        </div>
        
        <div class="export-section">
            <asp:Button ID="btnExport" runat="server" Text="Export Selected to Excel" 
                CssClass="btn-export" OnClick="btnExport_Click" />
        </div>
        
        <asp:GridView ID="gvOrders" runat="server" AutoGenerateColumns="false" CssClass="order-table"
            DataKeyNames="OrderID" OnRowCommand="gvOrders_RowCommand" OnRowDataBound="gvOrders_RowDataBound">
            <Columns>
                <asp:TemplateField HeaderText="Select">
                    <HeaderTemplate>
                        <input type="checkbox" id="chkSelectAll" class="select-all-checkbox" onclick="toggleSelectAll(this)" />
                    </HeaderTemplate>
                    <ItemTemplate>
                        <asp:CheckBox ID="chkSelect" runat="server" />
                    </ItemTemplate>
                    <ItemStyle Width="40px" HorizontalAlign="Center" />
                </asp:TemplateField>
                
                <asp:TemplateField HeaderText="Order #">
                    <ItemTemplate>
                        <%--<a href='Orderlist.aspx?id=<%# Eval("OrderID") %>'  class="order-id-link">
                            #<%# Eval("OrderID") %>
                        </a>--%>
                        <asp:LinkButton ID="btnDetail" runat="server" CssClass="btn-action btn-detail" 
                            CommandName="ShowDetail" CommandArgument='<%# Eval("OrderID") %>'>
                          #<%# Eval("OrderID") %>
                        </asp:LinkButton>
                        <div style="font-size: 11px; color: #888; margin-top: 3px;">
                            <%# Eval("OrderDate", "{0:MMM dd, yyyy hh:mm tt}") %>
                        </div>
                        <asp:Label ID="lblOrderDate" runat="server" Text='<%# Eval("OrderDate", "{0:MMM dd, yyyy hh:mm tt}") %>' Visible="false"></asp:Label>
                    </ItemTemplate>
                </asp:TemplateField>
                
                <asp:TemplateField HeaderText="Customer">
                    <ItemTemplate>
                        <div class="customer-info">
                            <span class="customer-name"><%# Eval("CustomerName") %></span>
                            <asp:Label ID="lblCustomerName" runat="server" Text='<%# Eval("CustomerName") %>' Visible="false"></asp:Label>
                            <span class="customer-contact"><%# Eval("CustomerEmail") %></span>
                            <asp:Label ID="lblCustomerEmail" runat="server" Text='<%# Eval("CustomerEmail") %>' Visible="false"></asp:Label>
                            <span class="customer-contact"><%# Eval("CustomerPhone") %></span>
                            <asp:Label ID="lblCustomerPhone" runat="server" Text='<%# Eval("CustomerPhone") %>' Visible="false"></asp:Label>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
                
                <asp:TemplateField HeaderText="Shipping">
                    <ItemTemplate>
                        <div class="shipping-info">
                            <%# Eval("AddressLine1") %><br />
                            <%# Eval("City") %>, <%# Eval("State") %> <%# Eval("PostalCode") %><br />
                            <%# Eval("Country") %>
                        </div>
                    </ItemTemplate>
                </asp:TemplateField>
                
                <asp:TemplateField HeaderText="Items">
                    <ItemTemplate>
                        <%# Eval("ItemCount") %> item(s)
                        <asp:Label ID="lblItemCount" runat="server" Text='<%# Eval("ItemCount") %>' Visible="false"></asp:Label>
                    </ItemTemplate>
                </asp:TemplateField>
                
                <asp:TemplateField HeaderText="Amount">
                    <ItemTemplate>
                        <div style="font-weight: 500;"><%# Eval("TotalAmount", "${0:N2}") %></div>
                        <asp:Label ID="lblTotalAmount" runat="server" Text='<%# Eval("TotalAmount", "${0:N2}") %>' Visible="false"></asp:Label>
                        <div style="font-size: 11px; color: #888;"><%# Eval("PaymentMethod") %></div>
                        <asp:Label ID="lblPaymentMethod" runat="server" Text='<%# Eval("PaymentMethod") %>' Visible="false"></asp:Label>
                    </ItemTemplate>
                </asp:TemplateField>
                
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <asp:Label ID="lblStatus" runat="server" Text='<%# Eval("Status") %>'></asp:Label>
                    </ItemTemplate>
                </asp:TemplateField>
                
                <asp:TemplateField HeaderText="Actions">
    <ItemTemplate>
        <div class="action-buttons">
            <asp:LinkButton ID="btnDetails" runat="server" CssClass="btn-action btn-details" 
                CommandName="ShowDetails" CommandArgument='<%# Eval("OrderID") %>'>
                <i class="fas fa-list"></i> Details
            </asp:LinkButton>
            
            <asp:LinkButton ID="btnProcess" runat="server" CssClass="btn-action btn-process" 
                CommandName="UpdateStatus" CommandArgument='<%# Eval("OrderID") + "|Processing" %>'
                OnClientClick='<%# "confirmStatusChange(" + Eval("OrderID") + ", \"" + Eval("Status") + "\", \"Processing\"); return false;" %>'>
                <i class="fas fa-cog"></i> Process
            </asp:LinkButton>
            
            <asp:LinkButton ID="btnDeliver" runat="server" CssClass="btn-action btn-deliver" 
                CommandName="UpdateStatus" CommandArgument='<%# Eval("OrderID") + "|Delivered" %>'
                OnClientClick='<%# "confirmStatusChange(" + Eval("OrderID") + ", \"" + Eval("Status") + "\", \"Delivered\"); return false;" %>'>
                <i class="fas fa-truck"></i> Deliver
            </asp:LinkButton>
            
            <asp:LinkButton ID="btnComplete" runat="server" CssClass="btn-action btn-complete" 
                CommandName="UpdateStatus" CommandArgument='<%# Eval("OrderID") + "|Completed" %>'
                OnClientClick='<%# "confirmStatusChange(" + Eval("OrderID") + ", \"" + Eval("Status") + "\", \"Completed\"); return false;" %>'>
                <i class="fas fa-check"></i> Complete
            </asp:LinkButton>
            
            <asp:LinkButton ID="btnNotify" runat="server" CssClass="btn-action btn-notify" 
                CommandName="SendNotification" CommandArgument='<%# Eval("OrderID") %>'>
                <i class="fas fa-envelope"></i> Notify
            </asp:LinkButton>
            
            <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn-action btn-cancel" 
                CommandName="CancelOrder" CommandArgument='<%# Eval("OrderID") %>'
                OnClientClick='<%# "confirmCancel(" + Eval("OrderID") + "); return false;" %>'>
                <i class="fas fa-times"></i> Cancel
            </asp:LinkButton>
        </div>
    </ItemTemplate>
</asp:TemplateField>
            </Columns>
            <EmptyDataTemplate>
                <tr>
                    <td colspan="8" class="empty-table">
                        <div class="empty-icon">
                            <i class="fas fa-clipboard-list"></i>
                        </div>
                        <h3>No orders found</h3>
                        <p>There are currently no orders matching your criteria</p>
                    </td>
                </tr>
            </EmptyDataTemplate>
        </asp:GridView>
    </div>
</asp:Content>