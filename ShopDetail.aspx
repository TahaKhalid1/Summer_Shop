









    <%@ Page Title="Product Details" Language="C#" MasterPageFile="~/User/User.Master" AutoEventWireup="true" CodeBehind="ShopDetail.aspx.cs" Inherits="Next_ae.User.ShopDetail" %>
    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="../UserTemplate/vendor/slick/slick.min.js"></script>
        <script src="../UserTemplate/vendor/MagnificPopup/jquery.magnific-popup.min.js"></script>
        <script src="../UserTemplate/vendor/sweetalert/sweetalert.min.js"></script>
        <link rel="stylesheet" href="../UserTemplate/vendor/slick/slick.css">
        <link rel="stylesheet" href="../UserTemplate/vendor/MagnificPopup/magnific-popup.css">
        <link rel="stylesheet" href="../UserTemplate/vendor/sweetalert/sweetalert.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">

      <script type="text/javascript">



          // Wishlist functionality
          $(document).on('click', '.js-addwish-b2', function (e) {
              e.preventDefault();
              var productId = $(this).data('product-id');
              console.log("Adding to wishlist, product ID:", productId);

              // Verify productId is valid
              if (!productId || isNaN(productId)) {
                  swal("Error", "Invalid product ID", "error");
                  return;
              }

              $.ajax({
                  url: 'Shop.aspx/AddToWishlist',
                  type: 'POST',
                  dataType: 'json',
                  contentType: 'application/json; charset=utf-8',
                  data: JSON.stringify({ productId: parseInt(productId) }), // Ensure it's parsed as integer
                  success: function (response) {
                      console.log("Wishlist response:", response);
                      if (response.d.Success) {
                          swal("Success", response.d.Message, "success");
                      } else {
                          if (response.d.Message === "not_logged_in") {
                              swal({
                                  title: "Oops!",
                                  text: "Please login to add items to your wishlist",
                                  icon: "warning",
                                  buttons: {
                                      login: {
                                          text: "Login",
                                          value: "login",
                                      },
                                      cancel: "Cancel"
                                  }
                              }).then((value) => {
                                  if (value === "login") {
                                      // Get current page URL and encode it
                                      var returnUrl = encodeURIComponent(window.location.pathname + window.location.search);
                                      window.location.href = "Login.aspx?ReturnUrl=" + returnUrl;
                                  }
                              });
                          } else {
                              swal("Error", response.d.Message, "error");
                          }
                      }
                  },
                  error: function (xhr, status, error) {
                      console.error("Add to wishlist error:", {
                          status: status,
                          error: error,
                          responseText: xhr.responseText
                      });
                      swal("Error", "An error occurred while adding to wishlist. Please try again.", "error");
                  }
              });
          });
          $(document).ready(function () {
              console.log("Document ready - initializing components");

              // Debug: Check if jQuery is loaded
              console.log("jQuery version:", $.fn.jquery);

              // Initialize star rating
              initStarRating();

              // Add to cart handler
              $(document).on('click', '.js-addcart-detail', function (e) {
                  e.preventDefault();
                  console.log("Add to cart button clicked");

                  addToCart();
              });

              // Quantity controls
              $('.btn-num-product-down').on('click', function (e) {
                  e.preventDefault();
                  var numProduct = $(this).next('.num-product');
                  var value = parseInt(numProduct.val());
                  if (value > 1) numProduct.val(value - 1);
              });

              $('.btn-num-product-up').on('click', function (e) {
                  e.preventDefault();
                  var numProduct = $(this).prev('.num-product');
                  numProduct.val(parseInt(numProduct.val()) + 1);
              });
          });

          function initStarRating() {
              console.log("Initializing star rating");

              // Set initial state
              $('.star-rating i').removeClass('fas').addClass('far');
              $('.star-rating i').css('color', '#d1d1d1');
              $('#<%= hdnRating.ClientID %>').val('0');

            // Click handler for stars
            $('.star-rating i').click(function () {
                var rating = $(this).data('rating');
                console.log("Star clicked - rating:", rating);

                // Update visual display
                $('.star-rating i').each(function () {
                    var starValue = $(this).data('rating');
                    if (starValue <= rating) {
                        $(this).removeClass('far').addClass('fas').css('color', '#ffc107');
                    } else {
                        $(this).removeClass('fas').addClass('far').css('color', '#d1d1d1');
                    }
                });

                // Update hidden field
                $('#<%= hdnRating.ClientID %>').val(rating);
                console.log("Updated hidden field value to:", $('#<%= hdnRating.ClientID %>').val());
            });
          }

          function addToCart() {
              var productId = $('#<%= hdnProductId.ClientID %>').val();
            var quantity = parseInt($('.num-product').val()) || 1;
            var size = $('#<%= ddlSizes.ClientID %>').val();
              var color = $('#<%= ddlColors.ClientID %>').val();


              if (!size || !color) {
                  swal("Error", "Please select both size and color", "error");
                  return;
              }

              if (quantity < 1) {
                  swal("Error", "Quantity must be at least 1", "error");
                  return;
              }

        
            console.log("Add to cart parameters:", {
                productId: productId,
                quantity: quantity,
                size: size,
                color: color
            });

            var $btn = $('.js-addcart-detail');
            $btn.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Adding...');

            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("ShopDetail.aspx/AddToCart") %>',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    productId: parseInt(productId),
                    quantity: quantity,
                    size: size || "",
                    color: color || ""
                }),
                success: function(response) {
                    console.log("AJAX success:", response);
                    if (response.d && response.d.Success) {
                        swal("Success", response.d.Message, "success");
                        updateCartCount();
                    } else {
                        handleAddToCartError(response);
                    }
                },
                error: function(xhr, status, error) {
                    console.error("AJAX error:", status, error);
                    swal("Error", "Failed to communicate with server", "error");
                },
                complete: function() {
                    $btn.prop('disabled', false).html('Add to cart');
                }
            });
        }

        function handleAddToCartError(response) {
            console.log("Handling add to cart error:", response);
        
            if (response.d && response.d.Message === "not_logged_in") {
                swal({
                    title: "Login Required",
                    text: "You need to login to add items to your cart",
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
            } else {
                var errorMsg = response.d ? response.d.Message : "Unknown error occurred";
                swal("Error", errorMsg, "error");
            }
        }

        function updateCartCount() {
            $.ajax({
                type: "POST",
                url: '<%= ResolveUrl("ShopDetail.aspx/GetCartCount") %>',
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

          function validateReview() {
              console.log("Starting review validation...");

              // Get all values
              var rating = $('#<%= hdnRating.ClientID %>').val();
              var reviewText = $('#<%= txtReview.ClientID %>').val();
              var name = $('#<%= txtName.ClientID %>').val();
    var email = $('#<%= txtEmail.ClientID %>').val();

    console.log("Rating:", rating);
    console.log("Review text length:", reviewText.length);
    console.log("Name:", name);
    console.log("Email:", email);

    // Validate rating
    if (!rating || rating === "0") {
        console.log("Validation failed - rating not selected");
        swal("Error", "Please select a rating by clicking on the stars", "error");
        return false;
    }

    // Validate review text
    if (!reviewText || reviewText.trim() === "") {
        console.log("Validation failed - review text empty");
        swal("Error", "Please write your review", "error");
        return false;
    }

    // Validate name
    if (!name || name.trim() === "") {
        console.log("Validation failed - name empty");
        swal("Error", "Please enter your name", "error");
        return false;
    }

    // Validate email
    var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!email || !emailRegex.test(email)) {
        console.log("Validation failed - invalid email");
        swal("Error", "Please enter a valid email address", "error");
        return false;
    }

    console.log("Validation passed - submitting review");

    // Show loading indicator
    var $btn = $('#<%= btnSubmitReview.ClientID %>');
    $btn.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Submitting...');

    // IMPORTANT: Return true to allow the postback
              __doPostBack('<%= btnSubmitReview.UniqueID %>', '');
              return true;
          }

// Add this to handle button state if validation fails
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_endRequest(function() {
                // Re-enable button after async postback
                $('#<%= btnSubmitReview.ClientID %>').prop('disabled', false).html('Submit');

                // Reinitialize star rating
                initStarRating();
            });


          

          function ShowLoading() {
              // Show loading indicator on the button
              $('.js-addcart-detail').html('<i class="fa fa-spinner fa-spin"></i> Submitting...');
          }

          // Handle AJAX success/error messages
          var prm = Sys.WebForms.PageRequestManager.getInstance();
          prm.add_endRequest(function () {
              // This runs after every async postback
              if (typeof lastReviewSubmitSuccess !== 'undefined' && lastReviewSubmitSuccess) {
                  swal("Success", "Review submitted successfully!", "success");
              } else if (typeof lastReviewSubmitError !== 'undefined') {
                  swal("Error", lastReviewSubmitError, "error");
              }
          });

          // Add this to your existing script section
          var prm = Sys.WebForms.PageRequestManager.getInstance();
          prm.add_endRequest(function () {
              // Reinitialize any necessary scripts after async postback
              initStarRating();

              // Reattach event handlers
              $('.star-rating i').click(function () {
                  var rating = $(this).data('rating');
                  $('.star-rating i').each(function () {
                      var starValue = $(this).data('rating');
                      if (starValue <= rating) {
                          $(this).removeClass('far').addClass('fas').css('color', '#ffc107');
                      } else {
                          $(this).removeClass('fas').addClass('far').css('color', '#d1d1d1');
                      }
                  });
                  $('#<%= hdnRating.ClientID %>').val(rating);
    });
});
      </script>

        <style>
            .star-rating i {
                transition: all 0.2s ease;
                cursor: pointer;
            }
            .star-rating i:hover {
                transform: scale(1.2);
            }
            .star-rating i.fas {
                color: #ffc107 !important;
            }
            .star-rating i.far {
                color: #d1d1d1 !important;
            }
            .fa-spinner {
                margin-right: 5px;
            }

            /* Ensure proper cursor behavior */
.flex-c-m {
    cursor: pointer !important;
}

.flex-c-m[disabled] {
    cursor: not-allowed !important;
    opacity: 0.7;
}

/* Fix for button text alignment during loading */
.flex-c-m .fa-spinner {
    margin-right: 8px;
}
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
           <asp:HiddenField ID="hdnProductId" runat="server" />
        <asp:HiddenField ID="hdnRating" runat="server" Value="0" />
    
        <section class="sec-product-detail bg0 p-t-65 p-b-60">
            <div class="container">
                <div class="row">
                    <div class="col-md-6 col-lg-7 p-b-30">
                        <div class="p-l-25 p-r-30 p-lr-0-lg">
                            <div class="wrap-slick3 flex-sb flex-w">
                                <div class="wrap-slick3-dots"></div>
                                <div class="wrap-slick3-arrows flex-sb-m flex-w"></div>

                                <div class="slick3 gallery-lb">
                                    <asp:Repeater ID="rptProductImages" runat="server">
                                        <ItemTemplate>
                                            <div class="item-slick3" data-thumb='<%# Eval("ImageUrl") %>'>
                                                <div class="wrap-pic-w pos-relative">
                                                    <img src='<%# Eval("ImageUrl") %>' alt='<%# Eval("AltText") %>'>
                                                    <a class="flex-c-m size-108 how-pos1 bor0 fs-16 cl10 bg0 hov-btn3 trans-04" href='<%# Eval("ImageUrl") %>'>
                                                        <i class="fa fa-expand"></i>
                                                    </a>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6 col-lg-5 p-b-30">
                        <div class="p-r-50 p-t-5 p-lr-0-lg">
                            <h4 class="mtext-105 cl2 js-name-detail p-b-14">
                                <asp:Literal ID="ltProductName" runat="server" />
                            </h4>

                            <span class="mtext-106 cl2">
                                <asp:Literal ID="ltPrice" runat="server" />
                            </span>

                            <p class="stext-102 cl3 p-t-23">
                                <asp:Literal ID="ltShortDescription" runat="server" />
                            </p>
                        
                            <!-- Product options -->
                            <div class="p-t-33">
                                <div class="flex-w flex-r-m p-b-10">
                                    <div class="size-203 flex-c-m respon6">
                                        Size
                                    </div>

                                    <div class="size-204 respon6-next">
                                        <div class="rs1-select2 bor8 bg0">
                                            <asp:DropDownList ID="ddlSizes" runat="server" CssClass="js-select2" name="size">
                                                <asp:ListItem Text="Choose an option" Value="" Selected="True" />
                                            </asp:DropDownList>
                                            <div class="dropDownSelect2"></div>
                                        </div>
                                    </div>
                                </div>

                                <div class="flex-w flex-r-m p-b-10">
                                    <div class="size-203 flex-c-m respon6">
                                        Color
                                    </div>

                                    <div class="size-204 respon6-next">
                                        <div class="rs1-select2 bor8 bg0">
                                            <asp:DropDownList ID="ddlColors" runat="server" CssClass="js-select2" name="color">
                                                <asp:ListItem Text="Choose an option" Value="" Selected="True" />
                                            </asp:DropDownList>
                                            <div class="dropDownSelect2"></div>
                                        </div>
                                    </div>
                                </div>

                                <div class="flex-w flex-r-m p-b-10">
                                    <div class="size-204 flex-w flex-m respon6-next">
                                        <div class="wrap-num-product flex-w m-r-20 m-tb-10">
                                            <div class="btn-num-product-down cl8 hov-btn3 trans-04 flex-c-m">
                                                <i class="fs-16 zmdi zmdi-minus"></i>
                                            </div>

                                            <input class="mtext-104 cl3 txt-center num-product" type="number" name="num-product" value="1" min="1">

                                            <div class="btn-num-product-up cl8 hov-btn3 trans-04 flex-c-m">
                                                <i class="fs-16 zmdi zmdi-plus"></i>
                                            </div>
                                        </div>

                                        <button class="flex-c-m stext-101 cl0 size-101 bg1 bor1 hov-btn1 p-lr-15 trans-04 js-addcart-detail">
                                            Add to cart
                                        </button>
                                    </div>
                                </div>	
                            </div>

                            <!-- Social sharing -->
                        
                            <div class="flex-w flex-m p-l-100 p-t-40 respon7">
                                <div class="flex-m bor9 p-r-10 m-r-11">
                                    <a href="#" class="btn-addwish-b2 dis-block pos-relative js-addwish-b2" 
                                           data-product-id='<%# Eval("ProductID") %>'>
                                            <img class="icon-heart1 dis-block trans-04" src="../UserTemplate/images/icons/icon-heart-01.png" alt="ICON">
                                            <img class="icon-heart2 dis-block trans-04 ab-t-l" src="../UserTemplate/images/icons/icon-heart-02.png" alt="ICON">
                                        </a>
                                </div>

                                <a href="#" class="fs-14 cl3 hov-cl1 trans-04 lh-10 p-lr-5 p-tb-2 m-r-8 tooltip100" data-tooltip="Facebook">
                                    <i class="fa fa-facebook"></i>
                                </a>

                                <a href="#" class="fs-14 cl3 hov-cl1 trans-04 lh-10 p-lr-5 p-tb-2 m-r-8 tooltip100" data-tooltip="Twitter">
                                    <i class="fa fa-twitter"></i>
                                </a>

                                <a href="#" class="fs-14 cl3 hov-cl1 trans-04 lh-10 p-lr-5 p-tb-2 m-r-8 tooltip100" data-tooltip="Google Plus">
                                    <i class="fa fa-google-plus"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Product tabs -->
                <div class="bor10 m-t-50 p-t-43 p-b-40">
                    <!-- Tab01 -->
                    <div class="tab01">
                        <!-- Nav tabs -->
                        <ul class="nav nav-tabs" role="tablist">
                            <li class="nav-item p-b-10">
                                <a class="nav-link active" data-toggle="tab" href="#description" role="tab">Description</a>
                            </li>

                            <li class="nav-item p-b-10">
                                <a class="nav-link" data-toggle="tab" href="#information" role="tab">Additional information</a>
                            </li>

                            <li class="nav-item p-b-10">
                                <a class="nav-link" data-toggle="tab" href="#reviews" role="tab">Reviews</a>
                            </li>
                        </ul>

                        <!-- Tab panes -->
                        <div class="tab-content p-t-43">
                            <!-- Description tab -->
                            <div class="tab-pane fade show active" id="description" role="tabpanel">
                                <div class="how-pos2 p-lr-15-md">
                                    <p class="stext-102 cl6">
                                        <asp:Literal ID="ltDescription" runat="server" />
                                    </p>
                                </div>
                            </div>

                            <!-- Additional information tab -->
                            <div class="tab-pane fade" id="information" role="tabpanel">
                                <div class="row">
                                    <div class="col-sm-10 col-md-8 col-lg-6 m-lr-auto">
                                        <ul class="p-lr-28 p-lr-15-sm">
                                            <li class="flex-w flex-t p-b-7">
                                                <span class="stext-102 cl3 size-205">
                                                    Weight
                                                </span>
                                                <span class="stext-102 cl6 size-206">
                                                    <asp:Literal ID="ltWeight" runat="server" />
                                                </span>
                                            </li>

                                            <li class="flex-w flex-t p-b-7">
                                                <span class="stext-102 cl3 size-205">
                                                    Dimensions
                                                </span>
                                                <span class="stext-102 cl6 size-206">
                                                    <asp:Literal ID="ltDimensions" runat="server" />
                                                </span>
                                            </li>

                                            <li class="flex-w flex-t p-b-7">
                                                <span class="stext-102 cl3 size-205">
                                                    Color
                                                </span>
                                                <span class="stext-102 cl6 size-206">
                                                    <asp:Literal ID="ltAvailableColors" runat="server" />
                                                </span>
                                            </li>

                                            <li class="flex-w flex-t p-b-7">
                                                <span class="stext-102 cl3 size-205">
                                                    Size
                                                </span>
                                                <span class="stext-102 cl6 size-206">
                                                    <asp:Literal ID="ltAvailableSizes" runat="server" />
                                                </span>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>

                            <!-- Reviews tab -->
                            <!-- Reviews tab -->
    <div class="tab-pane fade" id="reviews" role="tabpanel">
        <div class="row">
            <div class="col-sm-10 col-md-8 col-lg-6 m-lr-auto">
                <div class="p-b-30 m-lr-15-sm">
                    <!-- Reviews list -->
                    <asp:UpdatePanel ID="upReviews" runat="server" UpdateMode="Conditional">
                        <ContentTemplate>
                            <div class="p-b-20">
                                <h4 class="mtext-108 cl2 p-b-7">Customer Reviews</h4>
                                <asp:Repeater ID="rptReviews" runat="server">
    <ItemTemplate>
        <div class="flex-w flex-t p-b-68">
            <div class="wrap-pic-s size-109 bor0 of-hidden m-r-18 m-t-6">
                <img src='<%# Eval("AvatarUrl") %>' alt="AVATAR">
            </div>

            <div class="size-207">
                <div class="flex-w flex-sb-m p-b-17">
                    <span class="mtext-107 cl2 p-r-20">
                        <%# Eval("CustomerName") %>
                    </span>

                    <span class="fs-18 cl11">
                        <%# GetStarRating(Eval("Rating")) %>
                    </span>
                </div>

                <p class="stext-102 cl6">
                    <%# Eval("ReviewText") %>
                </p>
                
                <div class="flex-w flex-sb-m p-t-17">
                    <span class="stext-107 cl6">
                        <%# Convert.ToDateTime(Eval("CreatedDate")).ToString("MMMM dd, yyyy") %>
                    </span>
                </div>
            </div>
        </div>
    </ItemTemplate>
</asp:Repeater>
                                <asp:Label ID="lblNoReviews" runat="server" Text="No reviews yet. Be the first to review!" 
                                    CssClass="stext-102 cl6" Visible="false"></asp:Label>
                            </div>
                        
                    
                
                    <!-- Add review form -->
                    <div class="p-t-20">
                        <h5 class="mtext-108 cl2 p-b-7">Add a review</h5>
                        <p class="stext-102 cl6">Your email address will not be published. Required fields are marked *</p>

                        
                                <div class="flex-w flex-m p-t-50 p-b-23">
                                    <span class="stext-102 cl3 m-r-16">Your Rating <span style="color:red">*</span></span>
                                    <div class="star-rating">
                                        <i class="far fa-star" data-rating="1" style="font-size:24px; margin-right:5px;"></i>
                                        <i class="far fa-star" data-rating="2" style="font-size:24px; margin-right:5px;"></i>
                                        <i class="far fa-star" data-rating="3" style="font-size:24px; margin-right:5px;"></i>
                                        <i class="far fa-star" data-rating="4" style="font-size:24px; margin-right:5px;"></i>
                                        <i class="far fa-star" data-rating="5" style="font-size:24px;"></i>
                                    </div>
                                    <asp:HiddenField ID="HiddenField1" runat="server" Value="0" />
                                </div>

                                <div class="row p-b-25">
                                    <div class="col-12 p-b-5">
                                        <label class="stext-102 cl3" for="txtReview">Your review *</label>
                                        <asp:TextBox ID="txtReview" runat="server" TextMode="MultiLine" 
                                            CssClass="size-110 bor8 stext-102 cl2 p-lr-20 p-tb-10" 
                                            placeholder="Write your review here..." required></asp:TextBox>
                                    </div>

                                    <div class="col-sm-6 p-b-5">
                                        <label class="stext-102 cl3" for="txtName">Name *</label>
                                        <asp:TextBox ID="txtName" runat="server" 
                                            CssClass="size-111 bor8 stext-102 cl2 p-lr-20" 
                                            placeholder="Your name" required></asp:TextBox>
                                    </div>

                                    <div class="col-sm-6 p-b-5">
                                        <label class="stext-102 cl3" for="txtEmail">Email *</label>
                                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" 
                                            CssClass="size-111 bor8 stext-102 cl2 p-lr-20" 
                                            placeholder="Your email" required></asp:TextBox>
                                    </div>
                                </div>

                             <asp:Button ID="btnSubmitReview" runat="server" Text="Submit" 
                                    CssClass="flex-c-m stext-101 cl0 size-112 bg7 bor11 hov-btn3 p-lr-15 trans-04 m-b-10"  
                                    OnClick="btnSubmitReview_Click" 
                                    OnClientClick="return validateReview();" 
                                    CausesValidation="true" />
                            </ContentTemplate>
                              <Triggers>
                                        <asp:PostBackTrigger ControlID="btnSubmitReview" />
                                </Triggers>
                        </asp:UpdatePanel>
                    </div>
                </div>
                <div>
            </div>
        </div>
    </div>
                           

            <!-- Product meta -->
            <div class="bg6 flex-c-m flex-w size-302 m-t-73 p-tb-15">
                <span class="stext-107 cl6 p-lr-25">
                    SKU: <asp:Literal ID="ltSKU" runat="server" />
                </span>

                <span class="stext-107 cl6 p-lr-25">
                    Categories: <asp:Literal ID="ltCategories" runat="server" />
                </span>
            </div>
        </section>

        <!-- Related Products -->
        <section class="sec-relate-product bg0 p-t-45 p-b-105">
            <div class="container">
                <div class="p-b-45">
                    <h3 class="ltext-106 cl5 txt-center">
                        Related Products
                    </h3>
                </div>

                <!-- Related products slider -->
                <div class="wrap-slick2">
                    <div class="slick2">
                        <asp:Repeater ID="rptRelatedProducts" runat="server">
                            <ItemTemplate>
                                <div class="item-slick2 p-l-15 p-r-15 p-t-15 p-b-15">
                                    <!-- Block2 -->
                                    <div class="block2">
                                        <div class="block2-pic hov-img0">
                                            <img src='<%# Eval("ImageUrl") %>' alt='<%# Eval("ProductName") %>'>

                                            <a href='ShopDetail.aspx?id=<%# Eval("ProductID") %>' class="block2-btn flex-c-m stext-103 cl2 size-102 bg0 bor2 hov-btn1 p-lr-15 trans-04">
                                                Quick View
                                            </a>
                                        </div>

                                        <div class="block2-txt flex-w flex-t p-t-14">
                                            <div class="block2-txt-child1 flex-col-l ">
                                                <a href='ShopDetail.aspx?id=<%# Eval("ProductID") %>' class="stext-104 cl4 hov-cl1 trans-04 js-name-b2 p-b-6">
                                                    <%# Eval("ProductName") %>
                                                </a>

                                                <span class="stext-105 cl3">
                                                    Rs. <%# Eval("Price", "{0:0.00}") %>
                                                </span>
                                                </div>

                                            <div class="block2-txt-child2 flex-r p-t-3">
                                                <a href="#" class="btn-addwish-b2 dis-block pos-relative js-addwish-b2">
                                                    <img class="icon-heart1 dis-block trans-04" src="../UserTemplate/images/icons/icon-heart-01.png" alt="ICON">
                                                    <img class="icon-heart2 dis-block trans-04 ab-t-l" src="../UserTemplate/images/icons/icon-heart-02.png" alt="ICON">
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
        </section>
    </asp:Content>

















