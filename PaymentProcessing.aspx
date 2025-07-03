<%@ Page Title="Payment Processing" Language="C#" MasterPageFile="~/User/User.Master" AutoEventWireup="true" 
    CodeBehind="PaymentProcessing.aspx.cs" Inherits="Next_ae.User.PaymentProcessing" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .payment-processing {
            padding: 50px 0;
            text-align: center;
        }
        .processing-icon {
            font-size: 60px;
            color: #717fe0;
            margin-bottom: 30px;
            animation: spin 2s linear infinite;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .processing-title {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 20px;
            color: #333;
        }
        .processing-message {
            font-size: 16px;
            color: #666;
            margin-bottom: 30px;
        }
        .hidden-button {
            display: none;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="bg0 p-t-75 p-b-85 payment-processing">
        <div class="container">
            <div class="processing-icon">
                <i class="zmdi zmdi-refresh"></i>
            </div>
            
            <h1 class="processing-title">Processing Your Payment</h1>
            <p class="processing-message">
                Please wait while we process your payment. Do not refresh or close this page.
            </p>
            
            <asp:HiddenField ID="hfOrderId" runat="server" />
            <asp:HiddenField ID="hfPaymentMethod" runat="server" />
            
            <!-- Add this hidden button for server-side processing -->
            <asp:Button ID="btnCompletePayment" runat="server" CssClass="hidden-button" 
                OnClick="btnCompletePayment_Click" />
        </div>
    </div>
    
    <script src="https://js.stripe.com/v3/"></script>
    <script>
        // Simulate payment processing
        setTimeout(function () {
            // Set the hidden field values
            document.getElementById('<%= hfOrderId.ClientID %>').value = '<%= Request.QueryString["orderId"] %>';
            document.getElementById('<%= hfPaymentMethod.ClientID %>').value = '<%= Request.QueryString["paymentMethod"] %>';
            
            // Trigger the button click
            document.getElementById('<%= btnCompletePayment.ClientID %>').click();
        }, 3000);
    </script>
</asp:Content>