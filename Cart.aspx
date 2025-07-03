













































<%@ Page Title="Cart-ArbanChoise" Language="C#" MasterPageFile="~/User/User.Master" AutoEventWireup="true" 
    CodeBehind="Cart.aspx.cs" Inherits="Next_ae.User.Cart" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="../UserTemplate/vendor/sweetalert/sweetalert.min.js"></script>
    <link rel="stylesheet" href="../UserTemplate/vendor/sweetalert/sweetalert.css">
    
    <style>
        .empty-cart-container {
            text-align: center;
            padding: 50px;
            margin: 50px 0;
            border: 2px dashed #e6e6e6;
            border-radius: 10px;
            background-color: #fafafa;
        }
        .empty-cart-icon {
            font-size: 80px;
            color: #ddd;
            margin-bottom: 20px;
        }
        .empty-cart-title {
            font-size: 28px;
            color: #333;
            margin-bottom: 15px;
            font-weight: 500;
        }
        .empty-cart-message {
            font-size: 16px;
            color: #666;
            margin-bottom: 30px;
        }
        .continue-shopping-btn {
            padding: 15px 40px;
            font-size: 16px;
            border-radius: 4px;
            transition: all 0.3s;
        }
        .cart-actions {
            margin-top: 20px;
        }
        .num-product {
            width: 50px;
            text-align: center;
        }
        .product-details {
            margin-top: 10px;
        }
        .product-details p {
            margin: 3px 0;
            font-size: 14px;
            color: #666;
        }
        .how-itemcart1 {
            width: 100px;
            height: 100px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .how-itemcart1 img {
            max-width: 100%;
            max-height: 100%;
            object-fit: contain;
        }
        .wrap-num-product {
            display: flex;
            align-items: center;
        }
        .btn-num-product-down, 
        .btn-num-product-up {
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            background: #f5f5f5;
            border: 1px solid #e6e6e6;
        }
        .btn-num-product-down:hover, 
        .btn-num-product-up:hover {
            background: #e6e6e6;
        }
        .btn-remove-item {
            background-color: #ff6b6b;
            color: white;
            border: none;
            padding: 8px 15px;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .btn-remove-item:hover {
            background-color: #ff5252;
        }
        .btn-update-cart {
            background-color: #4CAF50;
            color: white;
        }
        .btn-checkout {
            background-color: #2196F3;
            color: white;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="bg0 p-t-75 p-b-85">
        <div class="container">
            <!-- Empty Cart Message -->
            <asp:Panel ID="emptyCartMessage" runat="server" CssClass="empty-cart-container" Visible="false">
                <div class="empty-cart-icon">
                    <i class="zmdi zmdi-shopping-cart"></i>
                </div>
                <h3 class="empty-cart-title">Your Shopping Cart is Empty</h3>
                <p class="empty-cart-message">Looks like you haven't added any items to your cart yet.</p>
                <a href="Products.aspx" class="flex-c-m stext-101 cl0 size-116 bg3 bor14 hov-btn3 p-lr-15 trans-04 pointer continue-shopping-btn">
                    Continue Shopping
                </a>
            </asp:Panel>

            <!-- Cart Contents -->
            <asp:Panel ID="cartTable" runat="server" Visible="false">
                <div class="row">
                    <div class="col-lg-10 col-xl-7 m-lr-auto m-b-50">
                        <div class="m-l-25 m-r--38 m-lr-0-xl">
                            <div class="wrap-table-shopping-cart">
                                <table class="table-shopping-cart">
                                    <tr class="table_head">
                                        <th class="column-1">Product</th>
                                        <th class="column-2">Details</th>
                                        <th class="column-3">Price</th>
                                        <th class="column-4">Quantity</th>
                                        <th class="column-5">Total</th>
                                        <th class="column-6">Action</th>
                                    </tr>
                                    
                                    <asp:Repeater ID="rptCartItems" runat="server" OnItemDataBound="rptCartItems_ItemDataBound">
                                        <ItemTemplate>
                                            <tr class="table_row">
                                                <td class="column-1">
                                                     <div class="how-itemcart1">
                                                        <asp:Image ID="imgProduct" runat="server" CssClass="product-image" />
                                                        <asp:HiddenField ID="hfImageUrl" runat="server" Value='<%# Eval("ImageUrl") %>' />
                                                    </div>
                                                </td>
                                                <td class="column-2">
                                                    <h4><%# Eval("ProductName") %></h4>
                                                    <div class="product-details">
                                                        <asp:Label ID="lblSize" runat="server" Text='<%# "Size: " + Eval("Size") %>' Visible='<%# !string.IsNullOrEmpty(Eval("Size").ToString()) %>'></asp:Label>
                                                        <asp:Label ID="lblColor" runat="server" Text='<%# "Color: " + Eval("Color") %>' Visible='<%# !string.IsNullOrEmpty(Eval("Color").ToString()) %>'></asp:Label>
                                                    </div>
                                                    <asp:HiddenField ID="hfCartItemID" runat="server" Value='<%# Eval("CartItemID") %>' />
                                                    <asp:HiddenField ID="hfProductID" runat="server" Value='<%# Eval("ProductID") %>' />
                                                </td>
                                                <td class="column-3">Rs. <%# Convert.ToDecimal(Eval("Price")).ToString("0.00") %></td>
                                                <td class="column-4">
                                                    <div class="wrap-num-product flex-w m-l-auto m-r-0">
                                                        <div class="btn-num-product-down cl8 hov-btn3 trans-04 flex-c-m" onclick="decreaseQuantity(this)">
                                                            <i class="fs-16 zmdi zmdi-minus"></i>
                                                        </div>
                                                        <asp:TextBox ID="txtQuantity" runat="server" 
                                                            CssClass="mtext-104 cl3 txt-center num-product" 
                                                            Text='<%# Eval("Quantity") %>' 
                                                            TextMode="Number" 
                                                            min="1" 
                                                            onchange="validateQuantity(this)"></asp:TextBox>
                                                        <div class="btn-num-product-up cl8 hov-btn3 trans-04 flex-c-m" onclick="increaseQuantity(this)">
                                                            <i class="fs-16 zmdi zmdi-plus"></i>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td class="column-5">Rs. <%# Convert.ToDecimal(Eval("TotalPrice")).ToString("0.00") %></td>
                                                <td class="column-6">
                                                    <button type="button" class="btn-remove-item" 
                                                        onclick="removeItem(<%# Eval("CartItemID") %>, this)">
                                                        Remove
                                                    </button>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </table>
                            </div>

                            <div class="flex-w flex-sb-m bor15 p-t-18 p-b-15 p-lr-40 p-lr-15-sm cart-actions">
                                <button type="button" id="btnUpdateCart" class="flex-c-m stext-101 cl2 size-119 bg8 bor13 hov-btn3 p-lr-15 trans-04 pointer m-tb-10 btn-update-cart"
                                    onclick="updateCart()">
                                    Update Cart
                                </button>
                                
                                <a href="Shop.aspx" class="flex-c-m stext-101 cl2 size-119 bg1 bor13 hov-btn3 p-lr-15 trans-04 pointer m-tb-10">
                                    Continue Shopping
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Checkout Section -->
                    <div class="col-sm-10 col-lg-7 col-xl-5 m-lr-auto m-b-50">
                        <div class="bor10 p-lr-40 p-t-30 p-b-40 m-l-63 m-r-40 m-lr-0-xl p-lr-15-sm">
                            <h4 class="mtext-109 cl2 p-b-30">
                                Cart Summary
                            </h4>

                            <div class="flex-w flex-t bor12 p-b-13">
                                <div class="size-208">
                                    <span class="stext-110 cl2">
                                        Subtotal:
                                    </span>
                                </div>

                                <div class="size-209">
                                    <span id="lblSubtotal" class="mtext-110 cl2">Rs. 0.00</span>
                                </div>
                            </div>

                            <div class="flex-w flex-t bor12 p-t-15 p-b-13">
                                <div class="size-208">
                                    <span class="stext-110 cl2">
                                        Shipping:
                                    </span>
                                </div>

                                <div class="size-209">
                                    <span id="lblShipping" class="mtext-110 cl2">Rs. 0.00</span>
                                </div>
                            </div>

                            <div class="flex-w flex-t p-t-27 p-b-33">
                                <div class="size-208">
                                    <span class="mtext-101 cl2">
                                        Total:
                                    </span>
                                </div>

                                <div class="size-209 p-t-1">
                                    <span id="lblTotal" class="mtext-110 cl2">Rs. 0.00</span>
                                </div>
                            </div>

                            <button type="button" id="btnProceedToCheckout" 
                                class="flex-c-m stext-101 cl0 size-116 bg3 bor14 hov-btn3 p-lr-15 trans-04 pointer btn-checkout"
                                onclick="proceedToCheckout()">
                                Proceed to Checkout
                            </button>
                        </div>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>

    <script>
        // Store cart items for easy access
        var cartItems = [];
        
        // Initialize cart items from the page
        $(document).ready(function() {
            // Populate cartItems array
            $('.table_row').each(function() {
                var cartItemId = $(this).find('[id*=hfCartItemID]').val();
                var quantity = $(this).find('.num-product').val();
                cartItems.push({
                    cartItemId: cartItemId,
                    quantity: quantity
                });
            });
            
            console.log("Cart initialized with items:", cartItems);
            
            // Update cart summary on page load
            updateCartSummary();
        });

        function validateQuantity(input) {
            if (input.value < 1 || isNaN(input.value)) {
                input.value = 1;
                swal('Error!', 'Quantity must be at least 1', 'error');
                return false;
            }
            return true;
        }

        function increaseQuantity(button) {
            var input = button.parentNode.querySelector('.num-product');
            input.value = parseInt(input.value) + 1;
            updateCartItemInArray(input);
        }

        function decreaseQuantity(button) {
            var input = button.parentNode.querySelector('.num-product');
            if (parseInt(input.value) > 1) {
                input.value = parseInt(input.value) - 1;
                updateCartItemInArray(input);
            }
        }
        
        function updateCartItemInArray(input) {
            var row = $(input).closest('.table_row');
            var cartItemId = row.find('[id*=hfCartItemID]').val();
            
            // Update the cartItems array
            for (var i = 0; i < cartItems.length; i++) {
                if (cartItems[i].cartItemId == cartItemId) {
                    cartItems[i].quantity = input.value;
                    break;
                }
            }
        }

        function removeItem(cartItemId, button) {
            swal({
                title: "Are you sure?",
                text: "You are about to remove this item from your cart",
                icon: "warning",
                buttons: true,
                dangerMode: true,
            }).then((willDelete) => {
                if (willDelete) {
                    // Show loading on button
                    $(button).html('<i class="fa fa-spinner fa-spin"></i> Removing...');
                    
                    $.ajax({
                        type: "POST",
                        url: '<%= ResolveUrl("Cart.aspx/RemoveItem") %>',
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        data: JSON.stringify({ cartItemId: cartItemId }),
                        success: function(response) {
                            if (response.d.Success) {
                                swal("Success!", response.d.Message, "success").then(() => {
                                    // Remove the row from UI
                                    $(button).closest('.table_row').remove();
                                    updateCartSummary();
                                    updateCartCount();
                                    
                                    // Check if cart is empty now
                                    if ($('.table_row').length === 0) {
                                        location.reload(); // Reload to show empty cart message
                                    }
                                });
                            } else {
                                handleCartError(response);
                            }
                        },
                        error: function(xhr, status, error) {
                            swal("Error!", "Failed to remove item: " + error, "error");
                        },
                        complete: function() {
                            $(button).html('Remove');
                        }
                    });
                }
            });
        }

        function updateCart() {
            // Prepare updated quantities
            var updates = [];
            $('.table_row').each(function() {
                var cartItemId = $(this).find('[id*=hfCartItemID]').val();
                var quantity = $(this).find('.num-product').val();
                updates.push({
                    CartItemID: cartItemId,
                    Quantity: quantity
                });
            });
            
            // Show loading on button
            $('#btnUpdateCart').html('<i class="fa fa-spinner fa-spin"></i> Updating...');
            
            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("Cart.aspx/UpdateCart") %>',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ updates: updates }),
                success: function(response) {
                    if (response.d.Success) {
                        swal("Success!", response.d.Message, "success").then(() => {
                            updateCartSummary();
                            updateCartCount();
                        });
                    } else {
                        handleCartError(response);
                    }
                },
                error: function(xhr, status, error) {
                    swal("Error!", "Failed to update cart: " + error, "error");
                },
                complete: function() {
                    $('#btnUpdateCart').html('Update Cart');
                }
            });
        }
        
        function updateCartSummary() {
            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("Cart.aspx/GetCartSummary") %>',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            data: "{}",
            success: function (response) {
                if (response.d) {
                    $('#lblSubtotal').text(response.d.Subtotal);
                    $('#lblShipping').text(response.d.Shipping);
                    $('#lblTotal').text(response.d.Total);
                }
            },
            error: function (xhr, status, error) {
                console.error("Failed to update cart summary:", error);
            }
        });
           }
        
        function updateCartCount() {
            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("Cart.aspx/GetCartCount") %>',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: "{}",
                success: function(response) {
                    if (response.d) {
                        $('.cart-count').text(response.d);
                    }
                },
                error: function(xhr, status, error) {
                    console.error("Failed to update cart count:", error);
                }
            });
        }

        function proceedToCheckout() {
            // Show loading on button
            $('#btnProceedToCheckout').html('<i class="fa fa-spinner fa-spin"></i> Processing...');
            
            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("Cart.aspx/ProceedToCheckout") %>',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: "{}",
                success: function (response) {
                    if (response.d.Success) {
                        window.location.href = "Checkout.aspx";
                    } else {
                        handleCartError(response);
                    }
                },
                error: function (xhr, status, error) {
                    swal("Error!", "Failed to proceed to checkout: " + error, "error");
                },
                complete: function () {
                    $('#btnProceedToCheckout').html('Proceed to Checkout');
                }
            });
        }

        function handleCartError(response) {
            if (response.d.Message === "not_logged_in") {
                swal({
                    title: "Login Required",
                    text: "You need to login to continue",
                    icon: "warning",
                    buttons: {
                        login: {
                            text: "Login Now",
                            value: "login"
                        },
                        cancel: "Cancel"
                    }
                }).then((value) => {
                    if (value === "login") {
                        window.location.href = response.d.RedirectUrl || "Login.aspx";
                    }
                });
            } else if (response.d.Message === "cart_empty") {
                swal("Oops!", "Your cart is empty. Please add items before checkout.", "error");
            } else {
                swal("Error!", response.d.Message || "An error occurred", "error");
            }
        }
    </script>
</asp:Content>