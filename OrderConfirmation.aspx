<%@ Page Title="Order Confirmation" Language="C#" MasterPageFile="~/User/User.Master" AutoEventWireup="true" 
    CodeBehind="OrderConfirmation.aspx.cs" Inherits="Next_ae.User.OrderConfirmation" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .confirmation-container {
            padding: 50px 0;
            text-align: center;
        }
        .confirmation-icon {
            font-size: 80px;
            color: #4CAF50;
            margin-bottom: 30px;
        }
        .confirmation-title {
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 20px;
            color: #333;
        }
        .confirmation-message {
            font-size: 16px;
            color: #666;
            margin-bottom: 30px;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }
        .order-details {
            background-color: #f9f9f9;
            padding: 30px;
            border-radius: 8px;
            max-width: 600px;
            margin: 0 auto 30px;
            text-align: left;
        }
        .detail-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        .detail-label {
            font-weight: 500;
            color: #555;
        }
        .detail-value {
            font-weight: 600;
        }
        .btn-continue {
            padding: 15px 40px;
            font-size: 16px;
            border-radius: 4px;
            transition: all 0.3s;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="bg0 p-t-75 p-b-85 confirmation-container">
        <div class="container">
            <div class="confirmation-icon">
                <i class="zmdi zmdi-check-circle"></i>
            </div>
            
            <h1 class="confirmation-title">Thank You For Your Order!</h1>
            <p class="confirmation-message">
                Your order has been placed successfully. We've sent a confirmation email to 
                <asp:Literal ID="ltEmail" runat="server"></asp:Literal> with your order details.
            </p>
            
            <div class="order-details">
                <div class="detail-row">
                    <span class="detail-label">Order Number:</span>
                    <span class="detail-value"><asp:Literal ID="ltOrderNumber" runat="server"></asp:Literal></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Order Date:</span>
                    <span class="detail-value"><asp:Literal ID="ltOrderDate" runat="server"></asp:Literal></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Payment Method:</span>
                    <span class="detail-value"><asp:Literal ID="ltPaymentMethod" runat="server"></asp:Literal></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Total Amount:</span>
                    <span class="detail-value"><asp:Literal ID="ltOrderTotal" runat="server"></asp:Literal></span>
                </div>
                <div class="detail-row" style="border-bottom: none;">
                    <span class="detail-label">Estimated Delivery:</span>
                    <span class="detail-value"><asp:Literal ID="ltDeliveryDate" runat="server"></asp:Literal></span>
                </div>
            </div>
            
            <a href="Shop.aspx" class="flex-c-m stext-101 cl0 size-116 bg3 bor14 hov-btn3 p-lr-15 trans-04 pointer btn-continue">
                Continue Shopping
            </a>
        </div>
    </div>
</asp:Content>