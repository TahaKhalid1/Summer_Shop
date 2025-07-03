



<%@ Page Title="Next-Shop" Language="C#" MasterPageFile="~/User/User.Master" AutoEventWireup="true" CodeBehind="Shop.aspx.cs" Inherits="Next_ae.User.Shop" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="../UserTemplate/vendor/slick/slick.min.js"></script>
    <script src="../UserTemplate/vendor/MagnificPopup/jquery.magnific-popup.min.js"></script>
    <script src="../UserTemplate/vendor/sweetalert/sweetalert.min.js"></script>
    <link rel="stylesheet" href="../UserTemplate/vendor/slick/slick.css">
    <link rel="stylesheet" href="../UserTemplate/vendor/MagnificPopup/magnific-popup.css">
    <link rel="stylesheet" href="../UserTemplate/vendor/sweetalert/sweetalert.css">
    
     <style type="text/css">
     .wrap-modal1 {
         position: fixed;
         top: 0;
         left: 0;
         width: 100%;
         height: 100%;
         background-color: rgba(0,0,0,0.7);
         z-index: 9999;
         display: none;
         overflow-y: auto;
     }

     .wrap-modal1 .container {
         background: white;
         margin: 90px auto;
         padding: 20px;
         max-width: 1300px;
         position: relative;
     }
    /* .block2-pic {
         height: 100%;  
         overflow: hidden;
         max-width:fit-content;
         max-height:fit-content;       
         display: block;
        
         justify-content: center;
     }*/

    .block2-pic {
        width: 100%;
        height: 300px; /* Fixed height for all images */
        overflow: hidden;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #f5f5f5; /* Background color for consistency */
    }

     .block2 {
         background: #fff;
         border-radius: 4px;
         overflow: hidden;
         box-shadow: 0 2px 10px rgba(0,0,0,0.05);
         transition: all 0.3s ease;
         height: 100%;   
         display: flex;
         flex-direction: column;
     }
     
     /*.block2-pic img {
         max-width:auto;
         max-height: auto;
         
         object-fit: contain;
     }*/

     .block2-pic img {
        width: auto;
        height: 100%;
        max-width: 100%;
        object-fit: contain; /* Ensures entire image is visible */
        transition: transform 0.3s ease; /* Smooth hover effect */
    }
     .isotope-grid {
         display: flex;
         flex-wrap: wrap;
         margin: -15px;
     }

     /*.isotope-item {
         margin-bottom: 30px;
         .block2-pic:hover img
     }*/

     .block2-pic:hover img {
            transform: scale(1.05); /* Slight zoom on hover */
        }

     .isotope-item {
        margin-bottom: 30px;
        height: 450px; /* Fixed height for product cards */
        display: flex;
        flex-direction: column;
    }

     .btn-addwish-b2 {
    cursor: pointer;
    transition: all 0.3s ease;
}

.btn-addwish-b2:hover .icon-heart1 {
    opacity: 0;
}

.btn-addwish-b2:hover .icon-heart2 {
    opacity: 1;
}

.icon-heart1 {
    opacity: 1;
    transition: opacity 0.3s ease;
}

.icon-heart2 {
    opacity: 0;
    transition: opacity 0.3s ease;
    position: absolute;
    top: 0;
    left: 0;
}

/* Quick View Gallery Styles */
.wrap-slick3 {
    position: relative;
}

.wrap-slick3-arrows {
    position: absolute;
    top: 50%;
    width: 100%;
    z-index: 10;
}

.slick-prev, .slick-next {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    background: rgba(255,255,255,0.7);
    border: none;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    z-index: 10;
    cursor: pointer;
}

.slick-prev {
    left: 15px;
}

.slick-next {
    right: 15px;
}

.wrap-slick3-dots {
    position: absolute;
    bottom: 20px;
    width: 100%;
    text-align: center;
    z-index: 10;
}

.slick-dots {
    display: inline-block;
    margin: 0;
    padding: 0;
    list-style: none;
}

.slick-dots li {
    display: inline-block;
    margin: 0 5px;
}

.slick-dots li button {
    font-size: 0;
    width: 10px;
    height: 10px;
    border-radius: 50%;
    border: none;
    background: #ccc;
    padding: 0;
}

.slick-dots li.slick-active button {
    background: #333;
}

.item-slick3 {
    position: relative;
}

.wrap-pic-w {
    position: relative;
    overflow: hidden;
}

.wrap-pic-w img {
    width: 100%;
    height: auto;
    display: block;
}



 </style>

     <script type="text/javascript">
         // Store the current product ID globally
         var currentProductId = 0;

         $(document).ready(function () {
             // Quick view button click handler
             $(document).on('click', '.js-show-modal1', function (e) {
                 e.preventDefault();
                 currentProductId = $(this).data('product-id');
                 console.log("Quick view for product ID:", currentProductId);

                 $('.wrap-modal1').show();
                 $('body').css('overflow', 'hidden');
                 $('.gallery-lb').html('<div class="text-center p-5"><i class="fa fa-spinner fa-spin fa-3x"></i></div>');

                 $.ajax({
                     url: 'Shop.aspx/GetProductQuickView',
                     type: 'POST',
                     dataType: 'json',
                     contentType: 'application/json; charset=utf-8',
                     data: JSON.stringify({ productId: currentProductId }),
                     success: function (response) {
                         console.log("Product data received:", response.d);
                         if (response.d) {
                             var product = response.d;

                             // Update product info
                             $('.js-name-detail').text(product.Name || 'No name available');
                             $('.mtext-106').text('Rs. ' + (product.Price ? product.Price.toFixed(2) : '0.00'));
                             $('.stext-102').text(product.ShortDescription || 'No description available');

                             // Update images
                             var galleryHtml = '';
                             if (product.Images && product.Images.length > 0) {
                                 $.each(product.Images, function (index, image) {
                                     galleryHtml += `
                    <div class="item-slick3" data-thumb="${image.ThumbUrl || image.Url}">
                        <div class="wrap-pic-w pos-relative">
                            <img src="${image.Url}" alt="${product.Name}">
                            <a class="flex-c-m size-108 how-pos1 bor0 fs-16 cl10 bg0 hov-btn3 trans-04" href="${image.Url}">
                                <i class="fa fa-expand"></i>
                            </a>
                        </div>
                    </div>`;
                                 });
                             } else {
                                 galleryHtml = '<div class="text-center p-5">No images available</div>';
                             }
                             $('.gallery-lb').html(galleryHtml);

                             // Destroy existing slick slider if it exists
                             if ($('.gallery-lb').hasClass('slick-initialized')) {
                                 $('.gallery-lb').slick('unslick');
                             }

                             // Initialize slick slider with proper settings
                             $('.gallery-lb').slick({
                                 slidesToShow: 1,
                                 slidesToScroll: 1,
                                 arrows: true,
                                 fade: true,
                                 dots: true,
                                 infinite: true,
                                 adaptiveHeight: true,
                                 prevArrow: '<button type="button" class="slick-prev"><i class="zmdi zmdi-chevron-left"></i></button>',
                                 nextArrow: '<button type="button" class="slick-next"><i class="zmdi zmdi-chevron-right"></i></button>'
                             });

                             // Initialize magnific popup
                             $('.gallery-lb').magnificPopup({
                                 delegate: 'a',
                                 type: 'image',
                                 gallery: { enabled: true },
                                 mainClass: 'mfp-fade'
                             });

                             // Update sizes
                             var sizesHtml = '<option value="">Choose an option</option>';
                             if (product.Sizes && product.Sizes.length > 0) {
                                 $.each(product.Sizes, function (index, size) {
                                     sizesHtml += `<option value="${size.Name}">${size.Name}</option>`;
                                 });
                             }
                             $('select[name="size"]').html(sizesHtml);

                             // Update colors
                             var colorsHtml = '<option value="">Choose an option</option>';
                             if (product.Colors && product.Colors.length > 0) {
                                 $.each(product.Colors, function (index, color) {
                                     colorsHtml += `<option value="${color.Name}">${color.Name}</option>`;
                                 });
                             }
                             $('select[name="color"]').html(colorsHtml);
                         }
                     },
                     error: function (xhr, status, error) {
                         console.error("Error loading product:", error);
                         $('.gallery-lb').html('<div class="text-center p-5">Error loading product details</div>');
                     }
                 });
             });
             // Search functionality
             $(document).on('click', '.js-show-search', function (e) {
                 e.preventDefault();
                 e.stopPropagation();

                 var $searchPanel = $('.panel-search');
                 var $searchIcon = $(this).find('.icon-search');
                 var $closeIcon = $(this).find('.icon-close-search');

                 if ($searchPanel.is(':visible')) {
                     $searchPanel.slideUp(300);
                     $searchIcon.removeClass('dis-none');
                     $closeIcon.addClass('dis-none');
                 } else {
                     $searchPanel.slideDown(300, function () {
                         $('input[name="search-product"]').focus();
                     });
                     $searchIcon.addClass('dis-none');
                     $closeIcon.removeClass('dis-none');
                 }
             });



         // Prevent panel from closing when clicking inside
         $('.panel-search').on('click', function (e) {
             e.stopPropagation();
         });


             $(document).on('click', function (e) {
                 if (!$(e.target).closest('.panel-search').length &&
                     !$(e.target).closest('.js-show-search').length) {
                     $('.panel-search').slideUp(300);
                     $('.js-show-search .icon-search').removeClass('dis-none');
                     $('.js-show-search .icon-close-search').addClass('dis-none');
                 }
             });

             $(document).on('keypress', 'input[name="search-product"]', function (e) {
                 if (e.which === 13) { // Enter key pressed
                     e.preventDefault();
                     performSearch($(this).val());
                 }
             });

             $(document).on('click', '.panel-search button', function (e) {
                 e.preventDefault();
                 e.stopPropagation();
                 var searchTerm = $('input[name="search-product"]').val();
                 performSearch(searchTerm);
             });

         $(document).on('click', '.js-close-search', function (e) {
             e.preventDefault();
             e.stopPropagation();
             $('.panel-search').slideUp(300);
             $('.js-show-search .icon-search').removeClass('dis-none');
             $('.js-show-search .icon-close-search').addClass('dis-none');
         });

             function performSearch(searchTerm) {
                 if (searchTerm.trim() === '') {
                     // If search is empty, reload all products
                     window.location.href = 'Shop.aspx';
                     return;
                 }

                 // Show loading indicator
                 $('.isotope-grid').html('<div class="col-12 text-center p-5"><i class="fa fa-spinner fa-spin fa-3x"></i></div>');

                 $.ajax({
                     url: 'Shop.aspx/SearchProducts',
                     type: 'POST',
                     dataType: 'json',
                     contentType: 'application/json; charset=utf-8',
                     data: JSON.stringify({ searchTerm: searchTerm }),
                     success: function (response) {
                         if (response.d && response.d.length > 0) {
                             var products = response.d;
                             var html = '';

                             $.each(products, function (index, product) {
                                 html += `
                    <div class="col-sm-6 col-md-4 col-lg-3 p-b-35 isotope-item ${product.Gender || ''}">
                        <div class="block2">
                            <div class="block2-pic hov-img0">
                                <img src="${product.ImageUrl || '../UserTemplate/images/default-product.jpg'}" alt="${product.ProductName}">
                                <a href="#" class="block2-btn flex-c-m stext-103 cl2 size-102 bg0 bor2 hov-btn1 p-lr-15 trans-04 js-show-modal1"
                                   data-product-id="${product.ProductID}">
                                    Quick View
                                </a>
                            </div>
                            <div class="block2-txt flex-w flex-t p-t-14">
                                <div class="block2-txt-child1 flex-col-l">
                                    <a href="ShopDetail.aspx?id=${product.ProductID}" class="stext-104 cl4 hov-cl1 trans-04 js-name-b2 p-b-6">
                                        ${product.ProductName}
                                    </a>
                                    <span class="stext-105 cl3">
                                        Rs.${product.Price ? product.Price.toFixed(2) : '0.00'}
                                    </span>
                                </div>
                                <div class="block2-txt-child2 flex-r p-t-3">
                                    <a href="#" class="btn-addwish-b2 dis-block pos-relative js-addwish-b2" 
                                       data-product-id="${product.ProductID}">
                                        <img class="icon-heart1 dis-block trans-04" src="../UserTemplate/images/icons/icon-heart-01.png" alt="ICON">
                                        <img class="icon-heart2 dis-block trans-04 ab-t-l" src="../UserTemplate/images/icons/icon-heart-02.png" alt="ICON">
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>`;
                             });

                             $('.isotope-grid').html(html);
                             $('.panel-search').slideUp();
                         } else {
                             $('.isotope-grid').html('<div class="col-12 text-center p-5">No products found matching your search.</div>');
                         }
                     },
                     error: function (xhr, status, error) {
                         console.error("Search error:", error);
                         $('.isotope-grid').html('<div class="col-12 text-center p-5">Error performing search. Please try again.</div>');
                     }
                 });
             }

             

             // Wishlist functionality
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
             // Close modal handlers
             $('.js-hide-modal1').on('click', function () {
                 $('.wrap-modal1').hide();
                 $('body').css('overflow', 'auto');
             });

             $('.overlay-modal1').on('click', function () {
                 $('.wrap-modal1').hide();
                 $('body').css('overflow', 'auto');
             });

             // Add to cart button click handler
             $(document).on('click', '.js-addcart-detail', function (e) {
                 e.preventDefault();

                 if (!currentProductId) {
                     console.error("No product ID found");
                     swal("Error", "Product information not loaded correctly", "error");
                     return;
                 }

                 var quantity = parseInt($('.num-product').val()) || 1;
                 var size = $('select[name="size"]').val();
                 var color = $('select[name="color"]').val();

                 if (!size || !color) {
                     swal("Error", "Please select both size and color", "error");
                     return;
                 }

                 if (quantity < 1) {
                     swal("Error", "Quantity must be at least 1", "error");
                     return;
                 }

                 var $btn = $(this);
                 $btn.prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Adding...');

                 $.ajax({
                     url: 'Shop.aspx/AddToCart',
                     type: 'POST',
                     dataType: 'json',
                     contentType: 'application/json; charset=utf-8',
                     data: JSON.stringify({
                         productId: currentProductId,
                         quantity: quantity,
                         size: size,
                         color: color
                     }),
                     success: function (response) {
                         console.log("Add to cart response:", response);
                         if (response.d.Success) {
                             swal("Success", response.d.Message, "success");
                             updateCartCount();
                             setTimeout(function () {
                                 $('.js-hide-modal1').click();
                             }, 1000);
                         } else {
                             if (response.d.Message === "not_logged_in") {
                                 swal({
                                     title: "Oops!",
                                     text: "Please login to add items to your cart",
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
                         console.error("Add to cart error:", error);
                         swal("Error", "An error occurred while adding to cart", "error");
                     },
                     complete: function () {
                         $btn.prop('disabled', false).html('Add to cart');
                     }
                 });
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

         function updateCartCount() {
             $.ajax({
                 url: 'Shop.aspx/GetCartCount',
                 type: 'POST',
                 dataType: 'json',
                 contentType: 'application/json; charset=utf-8',
                 success: function (response) {
                     if (response.d) {
                         $('.cart-count').text(response.d);
                     }
                 },
                 error: function (xhr, status, error) {
                     console.error("Error getting cart count:", error);
                 }
             });
         }
     </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
   <div class="bg0 m-t-23 p-b-140">
    <div class="container">
        <!-- Filter info label added here -->
        <div class="row">
            <div class="col-12">
                <asp:Label ID="lblFilterInfo" runat="server" CssClass="stext-106 cl6" Visible="false" 
                    style="display: block; margin-bottom: 20px; font-weight: 600;"></asp:Label>
            </div>
        </div>

        <div class="flex-w flex-sb-m p-b-52">
            <%--<div class="flex-w flex-l-m filter-tope-group m-tb-10">
                <button class="stext-106 cl6 hov1 bor3 trans-04 m-r-32 m-tb-5 how-active1" data-filter="*">
                    All Products
                </button>
                <button class="stext-106 cl6 hov1 bor3 trans-04 m-r-32 m-tb-5" data-filter=".women">
                    Women
                </button>
                <button class="stext-106 cl6 hov1 bor3 trans-04 m-r-32 m-tb-5" data-filter=".men">
                    Men
                </button>
                <button class="stext-106 cl6 hov1 bor3 trans-04 m-r-32 m-tb-5" data-filter=".bag">
                    T-shirts
                </button>
                <button class="stext-106 cl6 hov1 bor3 trans-04 m-r-32 m-tb-5" data-filter=".shoes">
                    Trousers
                </button>
                <button class="stext-106 cl6 hov1 bor3 trans-04 m-r-32 m-tb-5" data-filter=".watches">
                    Shorts
                </button>
            </div>--%>

        <%-- <div class="flex-w flex-c-m m-tb-10">
    <div class="flex-c-m stext-106 cl6 size-105 bor4 pointer hov-btn3 trans-04 m-tb-4 js-show-search">
        <i class="icon-search cl2 m-r-6 fs-15 trans-04 zmdi zmdi-search"></i>
        <i class="icon-close-search cl2 m-r-6 fs-15 trans-04 zmdi zmdi-close dis-none"></i>
        Search
    </div>
    
    <div class="dis-none panel-search w-full p-t-10 p-b-15">
        <div class="bor8 dis-flex p-l-15">
            <button class="size-113 flex-c-m fs-16 cl2 hov-cl1 trans-04 js-search-submit">
                <i class="zmdi zmdi-search"></i>
            </button>
            <input class="mtext-107 cl2 size-114 plh2 p-r-15" type="text" 
                   name="search-product" placeholder="Search products..." id="searchInput">
            <button class="size-113 flex-c-m fs-16 cl2 hov-cl1 trans-04 js-close-search ml-2">
                <i class="zmdi zmdi-close"></i>
            </button>
        </div>
    </div>
</div>--%>
            </div>
            <!-- Search panel positioned relative to the container -->
            
            <div class="row isotope-grid">
                <asp:Repeater ID="rptProducts" runat="server" OnItemDataBound="rptProducts_ItemDataBound">
                    <ItemTemplate>
                        <div class='col-sm-6 col-md-4 col-lg-3 p-b-35 isotope-item <%# Eval("Gender") %>'>
                            <div class="block2">
                                <div class="block2-pic hov-img0">
                                    <asp:Image ID="imgProduct" runat="server" AlternateText='<%# Eval("ProductName") %>' />
                                    <a href="#" class="block2-btn flex-c-m stext-103 cl2 size-102 bg0 bor2 hov-btn1 p-lr-15 trans-04 js-show-modal1"
                                       data-product-id='<%# Eval("ProductID") %>'>
                                        Quick View
                                    </a>
                                </div>
                                <div class="block2-txt flex-w flex-t p-t-14">
                                    <div class="block2-txt-child1 flex-col-l">
                                        <a href='ShopDetail.aspx?id=<%# Eval("ProductID") %>' class="stext-104 cl4 hov-cl1 trans-04 js-name-b2 p-b-6">
                                            <%# Eval("ProductName") %>
                                        </a>
                                        <span class="stext-105 cl3">
                                            Rs.<%# Eval("Price", "{0:0.00}") %>
                                        </span>
                                    </div>
                                    <div class="block2-txt-child2 flex-r p-t-3">
                                        <a href="#" class="btn-addwish-b2 dis-block pos-relative js-addwish-b2" 
                                           data-product-id='<%# Eval("ProductID") %>'>
                                            <img class="icon-heart1 dis-block trans-04" src="../UserTemplate/images/icons/icon-heart-01.png" alt="ICON">
                                            <img class="icon-heart2 dis-block trans-04 ab-t-l" src="../UserTemplate/images/icons/icon-heart-02.png" alt="ICON">
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Label ID="lblMessage" runat="server" CssClass="no-products-message" Visible="false" />
            </div>
        </div>
    </div>
<!-- Cart -->
<div class="wrap-header-cart js-panel-cart">
    <div class="s-full js-hide-cart"></div>

    <div class="header-cart flex-col-l p-l-65 p-r-25">
        <div class="header-cart-title flex-w flex-sb-m p-b-8">
            <span class="mtext-103 cl2">
                Your Cart
            </span>

            <div class="fs-35 lh-10 cl2 p-lr-5 pointer hov-cl1 trans-04 js-hide-cart">
                <i class="zmdi zmdi-close"></i>
            </div>
        </div>

        <asp:Panel ID="pnlEmptyCart" runat="server" CssClass="empty-cart-message" Visible="false">
            <div class="text-center p-t-30 p-b-30">
                <i class="zmdi zmdi-shopping-cart" style="font-size: 50px; color: #ccc;"></i>
                <p class="mtext-107 cl6 p-t-10">Kindly Login First To Check Cart</p>
                <a href="Login.aspx" class="flex-c-m stext-101 cl0 size-107 bg3 bor14 hov-btn3 p-lr-15 trans-04 m-t-10">
                    Login
                </a>
            </div>
        </asp:Panel>

        <div id="cartContent" runat="server" class="header-cart-content flex-w js-pscroll">
            <!-- Cart items will be loaded server-side -->
        </div>
    </div>
</div>


    <!-- Quick View Modal -->
    <div class="wrap-modal1 js-modal1 p-t-60 p-b-20">
        <div class="overlay-modal1 js-hide-modal1"></div>

        <div class="container">
            <div class="bg0 p-t-60 p-b-30 p-lr-15-lg how-pos3-parent">
                <button class="how-pos3 hov3 trans-04 js-hide-modal1">
                    <img src="../UserTemplate/images/icons/icon-close.png" alt="CLOSE">
                </button>

                <div class="row">
                    <div class="col-md-6 col-lg-7 p-b-30">
                       <div class="p-l-25 p-r-30 p-lr-0-lg">
                        <div class="wrap-slick3 flex-sb flex-w">
                            <div class="wrap-slick3-dots"></div>
                            <div class="wrap-slick3-arrows flex-sb-m flex-w"></div>
                            <div class="slick3 gallery-lb">
                                <!-- Dynamic content will be loaded here via AJAX -->
                            </div>
                        </div>
                    </div>
                    </div>
                    
                    <div class="col-md-6 col-lg-5 p-b-30">
                        <div class="p-r-50 p-t-5 p-lr-0-lg">
                            <h4 class="mtext-105 cl2 js-name-detail p-b-14">
                                <!-- Product name will be loaded here -->
                            </h4>

                            <span class="mtext-106 cl2">
                                <!-- Price will be loaded here -->
                            </span>

                            <p class="stext-102 cl3 p-t-23">
                                <!-- Description will be loaded here -->
                            </p>
                            
                            <div class="p-t-33">
                                <div class="flex-w flex-r-m p-b-10">
                                    <div class="size-203 flex-c-m respon6">
                                        Size
                                    </div>

                                    <div class="size-204 respon6-next">
                                        <div class="rs1-select2 bor8 bg0">
                                            <select class="js-select2" name="size" required>
                                                <option value="">Choose an option</option>
                                            </select>
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
                                            <select class="js-select2" name="color" required>
                                                <option value="">Choose an option</option>
                                            </select>
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
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>