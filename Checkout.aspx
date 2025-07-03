<%@ Page Title="Checkout-ArbanChoice" Language="C#" MasterPageFile="~/User/User.Master" AutoEventWireup="true" 
    CodeBehind="Checkout.aspx.cs" Inherits="Next_ae.User.Checkout" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .checkout-container {
            padding: 50px 0;
            background-color: #f8f9fa;
        }
        .checkout-title {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 30px;
            color: #2c3e50;
            position: relative;
            padding-bottom: 15px;
        }
        .checkout-title:after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 0;
            width: 60px;
            height: 3px;
            background: #717fe0;
        }
        .checkout-section {
            margin-bottom: 40px;
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
        .section-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid #eee;
            color: #2c3e50;
        }
        .form-group {
            margin-bottom: 25px;
            position: relative;
        }
        .form-label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #555;
        }
        .form-control {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 15px;
            transition: all 0.3s;
            background-color: #f8f9fa;
        }
        .form-control:focus {
            border-color: #717fe0;
            box-shadow: 0 0 0 3px rgba(113, 127, 224, 0.2);
            background-color: white;
        }
        .radio-group {
            margin-bottom: 20px;
        }
        .radio-label {
            position: relative;
            padding-left: 30px;
            cursor: pointer;
            display: inline-block;
            margin-bottom: 0;
            font-weight: 500;
        }
        .btn-checkout {
            width: 100%;
            padding: 15px;
            font-size: 16px;
            font-weight: 600;
            background-color: #717fe0;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.3s;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .btn-checkout:hover {
            background-color: #5a6bd1;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(113, 127, 224, 0.3);
        }
        .order-summary {
            background-color: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            position: sticky;
            top: 20px;
        }
        .summary-item {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            padding-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        .summary-total {
            font-weight: 700;
            font-size: 18px;
            margin-top: 20px;
            color: #2c3e50;
        }
        .payment-method {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
            padding: 15px;
            border-radius: 8px;
            border: 1px solid #eee;
            transition: all 0.3s;
            cursor: pointer;
        }
        .payment-method:hover {
            border-color: #717fe0;
            background-color: #f8f9fa;
        }
        .payment-method.selected {
            border-color: #717fe0;
            background-color: #f0f2ff;
        }
        .payment-icon {
            margin-right: 15px;
            font-size: 28px;
            color: #555;
        }
        .payment-details {
            flex-grow: 1;
        }
        .payment-title {
            font-weight: 600;
            margin-bottom: 5px;
            color: #2c3e50;
        }
        .payment-desc {
            font-size: 14px;
            color: #777;
        }
        .error-message {
            color: #e74c3c;
            font-size: 13px;
            margin-top: 5px;
            display: block;
        }
        .coming-soon {
            padding: 20px;
            background-color: #f8f9fa;
            border-radius: 8px;
            border: 1px solid #eee;
            text-align: center;
            color: #666;
            font-style: italic;
            margin-top: 20px;
        }
        .section-number {
            display: inline-block;
            width: 25px;
            height: 25px;
            background-color: #717fe0;
            color: white;
            border-radius: 50%;
            text-align: center;
            line-height: 25px;
            margin-right: 10px;
            font-size: 14px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <asp:HiddenField ID="hfSubtotal" runat="server" />
    <asp:HiddenField ID="hfShipping" runat="server" />
    <asp:HiddenField ID="hfTotal" runat="server" />

    <div class="bg0 p-t-75 p-b-85 checkout-container">
        <div class="container">
            <div class="row">
                <div class="col-lg-8 col-xl-8 m-lr-auto m-b-50">
                    <h1 class="checkout-title">Checkout</h1>
                    
                    <!-- Customer Information -->
                    <div class="checkout-section">
                        <h3 class="section-title"><span class="section-number">1</span> Customer Information</h3>
                        <div class="form-group">
                            <asp:Label ID="lblEmail" runat="server" CssClass="form-label" Text="Email Address *"></asp:Label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="your@email.com" ValidationGroup="CheckoutValidation"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" 
                                ErrorMessage="Email is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                            <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                                ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                ErrorMessage="Invalid email format" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RegularExpressionValidator>
                        </div>
                    </div>
                    
                    <!-- Shipping Address -->
                    <div class="checkout-section">
                        <h3 class="section-title"><span class="section-number">2</span> Shipping Address</h3>
                        
                        <div class="form-group">
                            <asp:Label ID="lblShippingFullName" runat="server" CssClass="form-label" Text="Full Name *"></asp:Label>
                            <asp:TextBox ID="txtShippingFullName" runat="server" CssClass="form-control" placeholder="John Doe" ValidationGroup="CheckoutValidation"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvShippingFullName" runat="server" ControlToValidate="txtShippingFullName" 
                                ErrorMessage="Full name is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                        </div>
                        
                        <div class="form-group">
                            <asp:Label ID="lblShippingAddress1" runat="server" CssClass="form-label" Text="Address Line 1 *"></asp:Label>
                            <asp:TextBox ID="txtShippingAddress1" runat="server" CssClass="form-control" placeholder="Street address, P.O. box, company name" ValidationGroup="CheckoutValidation"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvShippingAddress1" runat="server" ControlToValidate="txtShippingAddress1" 
                                ErrorMessage="Address is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                        </div>
                        
                        <div class="form-group">
                            <asp:Label ID="lblShippingAddress2" runat="server" CssClass="form-label" Text="Address Line 2 (Optional)"></asp:Label>
                            <asp:TextBox ID="txtShippingAddress2" runat="server" CssClass="form-control" placeholder="Apartment, suite, unit, building, floor, etc."></asp:TextBox>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <asp:Label ID="lblShippingCity" runat="server" CssClass="form-label" Text="City *"></asp:Label>
                                    <asp:TextBox ID="txtShippingCity" runat="server" CssClass="form-control" placeholder="City" ValidationGroup="CheckoutValidation"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvShippingCity" runat="server" ControlToValidate="txtShippingCity" 
                                        ErrorMessage="City is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <asp:Label ID="lblShippingState" runat="server" CssClass="form-label" Text="State/Province *"></asp:Label>
                                    <asp:TextBox ID="txtShippingState" runat="server" CssClass="form-control" placeholder="State/Province" ValidationGroup="CheckoutValidation"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvShippingState" runat="server" ControlToValidate="txtShippingState" 
                                        ErrorMessage="State is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <asp:Label ID="lblShippingPostalCode" runat="server" CssClass="form-label" Text="Postal Code *"></asp:Label>
                                    <asp:TextBox ID="txtShippingPostalCode" runat="server" CssClass="form-control" placeholder="Postal code" ValidationGroup="CheckoutValidation"></asp:TextBox>
                                    <asp:RequiredFieldValidator ID="rfvShippingPostalCode" runat="server" ControlToValidate="txtShippingPostalCode" 
                                        ErrorMessage="Postal code is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <asp:Label ID="lblShippingCountry" runat="server" CssClass="form-label" Text="Country *"></asp:Label>
                                    <asp:DropDownList ID="ddlShippingCountry" runat="server" CssClass="form-control" ValidationGroup="CheckoutValidation">
                                        <asp:ListItem Value="">Select Country</asp:ListItem>
                                        <asp:ListItem Value="AE">United Arab Emirates</asp:ListItem>
                                        <asp:ListItem Value="SA">Saudi Arabia</asp:ListItem>
                                        <asp:ListItem Value="QA">Qatar</asp:ListItem>
                                        <asp:ListItem Value="KW">Kuwait</asp:ListItem>
                                        <asp:ListItem Value="OM">Oman</asp:ListItem>
                                        <asp:ListItem Value="BH">Bahrain</asp:ListItem>
                                    </asp:DropDownList>
                                    <asp:RequiredFieldValidator ID="rfvShippingCountry" runat="server" ControlToValidate="ddlShippingCountry" 
                                        InitialValue="" ErrorMessage="Country is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <asp:Label ID="lblShippingPhone" runat="server" CssClass="form-label" Text="Phone Number *"></asp:Label>
                            <asp:TextBox ID="txtShippingPhone" runat="server" CssClass="form-control" placeholder="Phone number" ValidationGroup="CheckoutValidation"></asp:TextBox>
                            <asp:RequiredFieldValidator ID="rfvShippingPhone" runat="server" ControlToValidate="txtShippingPhone" 
                                ErrorMessage="Phone number is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    
                    <!-- Billing Address -->
                    <div class="checkout-section">
                        <h3 class="section-title"><span class="section-number">3</span> Billing Address</h3>
                        
                        <div class="form-group">
                            <asp:CheckBox ID="cbSameAsShipping" runat="server" Checked="true" AutoPostBack="true" 
                                OnCheckedChanged="cbSameAsShipping_CheckedChanged" />
                            <asp:Label ID="lblSameAsShipping" runat="server" Text="Same as shipping address" AssociatedControlID="cbSameAsShipping"></asp:Label>
                        </div>
                        
                        <asp:Panel ID="pnlBillingAddress" runat="server" Visible="false">
                            <div class="form-group">
                                <asp:Label ID="lblBillingFullName" runat="server" CssClass="form-label" Text="Full Name *"></asp:Label>
                                <asp:TextBox ID="txtBillingFullName" runat="server" CssClass="form-control" placeholder="John Doe" ValidationGroup="CheckoutValidation"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvBillingFullName" runat="server" ControlToValidate="txtBillingFullName" 
                                    ErrorMessage="Full name is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                            </div>
                            
                            <div class="form-group">
                                <asp:Label ID="lblBillingAddress1" runat="server" CssClass="form-label" Text="Address Line 1 *"></asp:Label>
                                <asp:TextBox ID="txtBillingAddress1" runat="server" CssClass="form-control" placeholder="Street address, P.O. box, company name" ValidationGroup="CheckoutValidation"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvBillingAddress1" runat="server" ControlToValidate="txtBillingAddress1" 
                                    ErrorMessage="Address is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                            </div>
                            
                            <div class="form-group">
                                <asp:Label ID="lblBillingAddress2" runat="server" CssClass="form-label" Text="Address Line 2 (Optional)"></asp:Label>
                                <asp:TextBox ID="txtBillingAddress2" runat="server" CssClass="form-control" placeholder="Apartment, suite, unit, building, floor, etc."></asp:TextBox>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <asp:Label ID="lblBillingCity" runat="server" CssClass="form-label" Text="City *"></asp:Label>
                                        <asp:TextBox ID="txtBillingCity" runat="server" CssClass="form-control" placeholder="City" ValidationGroup="CheckoutValidation"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="rfvBillingCity" runat="server" ControlToValidate="txtBillingCity" 
                                            ErrorMessage="City is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <asp:Label ID="lblBillingState" runat="server" CssClass="form-label" Text="State/Province *"></asp:Label>
                                        <asp:TextBox ID="txtBillingState" runat="server" CssClass="form-control" placeholder="State/Province" ValidationGroup="CheckoutValidation"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="rfvBillingState" runat="server" ControlToValidate="txtBillingState" 
                                            ErrorMessage="State is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <asp:Label ID="lblBillingPostalCode" runat="server" CssClass="form-label" Text="Postal Code *"></asp:Label>
                                        <asp:TextBox ID="txtBillingPostalCode" runat="server" CssClass="form-control" placeholder="Postal code" ValidationGroup="CheckoutValidation"></asp:TextBox>
                                        <asp:RequiredFieldValidator ID="rfvBillingPostalCode" runat="server" ControlToValidate="txtBillingPostalCode" 
                                            ErrorMessage="Postal code is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <asp:Label ID="lblBillingCountry" runat="server" CssClass="form-label" Text="Country *"></asp:Label>
                                        <asp:DropDownList ID="ddlBillingCountry" runat="server" CssClass="form-control" ValidationGroup="CheckoutValidation">
                                            <asp:ListItem Value="">Select Country</asp:ListItem>
                                            <asp:ListItem Value="AE">United Arab Emirates</asp:ListItem>
                                            <asp:ListItem Value="SA">Saudi Arabia</asp:ListItem>
                                            <asp:ListItem Value="QA">Qatar</asp:ListItem>
                                            <asp:ListItem Value="KW">Kuwait</asp:ListItem>
                                            <asp:ListItem Value="OM">Oman</asp:ListItem>
                                            <asp:ListItem Value="BH">Bahrain</asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="rfvBillingCountry" runat="server" ControlToValidate="ddlBillingCountry" 
                                            InitialValue="" ErrorMessage="Country is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="form-group">
                                <asp:Label ID="lblBillingPhone" runat="server" CssClass="form-label" Text="Phone Number *"></asp:Label>
                                <asp:TextBox ID="txtBillingPhone" runat="server" CssClass="form-control" placeholder="Phone number" ValidationGroup="CheckoutValidation"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvBillingPhone" runat="server" ControlToValidate="txtBillingPhone" 
                                    ErrorMessage="Phone number is required" CssClass="error-message" Display="Dynamic" ValidationGroup="CheckoutValidation"></asp:RequiredFieldValidator>
                            </div>
                        </asp:Panel>
                    </div>
                    
                    <!-- Payment Method -->
                    <div class="checkout-section">
                        <h3 class="section-title"><span class="section-number">4</span> Payment Method</h3>
    
                        <div class="radio-group">
                            <asp:RadioButton ID="rbCOD" runat="server" GroupName="PaymentMethod" Checked="true" />
                            <asp:Label ID="lblCOD" runat="server" CssClass="radio-label" Text="Cash on Delivery" AssociatedControlID="rbCOD"></asp:Label>
        
                            <div class="payment-method selected" onclick="selectPaymentMethod('cod')">
                                <div class="payment-icon">
                                    <i class="zmdi zmdi-money"></i>
                                </div>
                                <div class="payment-details">
                                    <div class="payment-title">Cash on Delivery</div>
                                    <div class="payment-desc">Pay cash when your order is delivered</div>
                                </div>
                            </div>
                        </div>

                        <div class="coming-soon">
                            <p>More payment options coming soon!</p>
                        </div>
                    </div>
                </div>
                
                <!-- Order Summary -->
                <div class="col-lg-4 col-xl-4 m-lr-auto m-b-50">
                    <div class="order-summary">
                        <h3 class="section-title">Order Summary</h3>
                        
                        <asp:Repeater ID="rptOrderItems" runat="server">
                            <ItemTemplate>
                                <div class="summary-item">
                                    <div>
                                        <span><%# Eval("ProductName") %></span>
                                        <small><%# Eval("Quantity") %> x Rs. <%# Convert.ToDecimal(Eval("Price")).ToString("0.00") %></small>
                                    </div>
                                    <div>Rs. <%# Convert.ToDecimal(Eval("TotalPrice")).ToString("0.00") %></div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        
                        <div class="summary-item">
                            <div>Subtotal</div>
                            <div><asp:Literal ID="ltSubtotal" runat="server"></asp:Literal></div>
                        </div>
                        
                        <div class="summary-item">
                            <div>Shipping</div>
                            <div><asp:Literal ID="ltShipping" runat="server"></asp:Literal></div>
                        </div>
                        
                        <div class="summary-item summary-total">
                            <div>Total</div>
                            <div><asp:Literal ID="ltTotal" runat="server"></asp:Literal></div>
                        </div>
                        
                        <asp:Button ID="btnPlaceOrder" runat="server" Text="Place Order" 
                        CssClass="btn-checkout" OnClientClick="placeOrder(); return false;" />
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="../UserTemplate/vendor/sweetalert/sweetalert.min.js"></script>
    <link rel="stylesheet" href="../UserTemplate/vendor/sweetalert/sweetalert.css">
    
    <script>
        $(document).ready(function () {
            // Make payment methods clickable
            $('.payment-method').click(function () {
                var radioId = $(this).prev().find('input[type="radio"]').attr('id');
                $('#' + radioId).prop('checked', true);
                $('.payment-method').removeClass('selected');
                $(this).addClass('selected');
            });
        });

        function selectPaymentMethod(method) {
            $('#<%= rbCOD.ClientID %>').prop('checked', true);
            $('.payment-method').removeClass('selected');
            $('[for="<%= rbCOD.ClientID %>"]').parent().next('.payment-method').addClass('selected');
        }

        function validateBeforeSubmit() {
            var isValid = true;
            $('.error-message').hide();

            // Validate email
            if (!$('#<%= txtEmail.ClientID %>').val()) {
                $('#<%= txtEmail.ClientID %>').css('border-color', 'red');
                isValid = false;
            } else {
                $('#<%= txtEmail.ClientID %>').css('border-color', '');
            }

            // Validate shipping address
            var shippingValid = $('#<%= txtShippingFullName.ClientID %>').val() &&
                $('#<%= txtShippingAddress1.ClientID %>').val() &&
                $('#<%= txtShippingCity.ClientID %>').val() &&
                $('#<%= txtShippingState.ClientID %>').val() &&
                $('#<%= txtShippingPostalCode.ClientID %>').val() &&
                $('#<%= ddlShippingCountry.ClientID %>').val() &&
                $('#<%= txtShippingPhone.ClientID %>').val();

            if (!shippingValid) {
                showOrderError("Please complete all required shipping address fields");
                isValid = false;
            }

            // Validate billing address if different from shipping
            if (!$('#<%= cbSameAsShipping.ClientID %>').is(':checked')) {
                var billingValid = $('#<%= txtBillingFullName.ClientID %>').val() &&
                    $('#<%= txtBillingAddress1.ClientID %>').val() &&
                    $('#<%= txtBillingCity.ClientID %>').val() &&
                    $('#<%= txtBillingState.ClientID %>').val() &&
                    $('#<%= txtBillingPostalCode.ClientID %>').val() &&
                    $('#<%= ddlBillingCountry.ClientID %>').val() &&
                    $('#<%= txtBillingPhone.ClientID %>').val();

                if (!billingValid) {
                    showOrderError("Please complete all required billing address fields");
                    isValid = false;
                }
            }

            return isValid;
        }

        function showOrderError(message) {
            swal("Error", message, "error");
        }

        function placeOrder() {
            if (!validateBeforeSubmit()) {
                return;
            }

            var $btn = $('#<%= btnPlaceOrder.ClientID %>');
            $btn.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Processing...');

            // Gather all form data
            var orderData = {
                email: $('#<%= txtEmail.ClientID %>').val(),
                paymentMethod: "Cash on Delivery",
                sameAsBilling: $('#<%= cbSameAsShipping.ClientID %>').is(':checked'),
                subtotal: $('#<%= hfSubtotal.ClientID %>').val(),
                shipping: $('#<%= hfShipping.ClientID %>').val(),
                total: $('#<%= hfTotal.ClientID %>').val(),
                newShippingAddress: {
                    fullName: $('#<%= txtShippingFullName.ClientID %>').val(),
                    address1: $('#<%= txtShippingAddress1.ClientID %>').val(),
                    address2: $('#<%= txtShippingAddress2.ClientID %>').val(),
                    city: $('#<%= txtShippingCity.ClientID %>').val(),
                    state: $('#<%= txtShippingState.ClientID %>').val(),
                    postalCode: $('#<%= txtShippingPostalCode.ClientID %>').val(),
                    country: $('#<%= ddlShippingCountry.ClientID %>').val(),
                    phone: $('#<%= txtShippingPhone.ClientID %>').val()
                }
            };

            // Include billing address if different from shipping
            if (!orderData.sameAsBilling) {
                orderData.newBillingAddress = {
                    fullName: $('#<%= txtBillingFullName.ClientID %>').val(),
                    address1: $('#<%= txtBillingAddress1.ClientID %>').val(),
                    address2: $('#<%= txtBillingAddress2.ClientID %>').val(),
                    city: $('#<%= txtBillingCity.ClientID %>').val(),
                    state: $('#<%= txtBillingState.ClientID %>').val(),
                    postalCode: $('#<%= txtBillingPostalCode.ClientID %>').val(),
                    country: $('#<%= ddlBillingCountry.ClientID %>').val(),
                    phone: $('#<%= txtBillingPhone.ClientID %>').val()
                };
            }

            console.log("Order Data:", orderData); // For debugging

            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("Checkout.aspx/PlaceOrder") %>',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ orderData: orderData }),
                success: function (response) {
                    if (response.d && response.d.success) {
                        if (response.d.redirectUrl) {
                            window.location.href = response.d.redirectUrl;
                        } else {
                            swal("Success", "Your order has been placed successfully!", "success");
                        }
                    } else {
                        showOrderError(response.d ? response.d.message : "Failed to place order");
                    }
                },
                error: function (xhr, status, error) {
                    showOrderError("Failed to communicate with server: " + error);
                },
                complete: function () {
                    $btn.prop('disabled', false).html('Place Order');
                }
            });
        }
    </script>
</asp:Content>