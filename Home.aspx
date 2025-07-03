	<%@ Page Title="ArbanChoice" Language="C#" MasterPageFile="~/User/Home.Master" AutoEventWireup="true" CodeBehind="Home.aspx.cs" Inherits="Next_ae.User.Home" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

	<style>
        .svg-hover {
            transition: transform 0.3s ease, fill 0.3s ease;
        }
        .svg-hover:hover {
            transform: scale(1.1);
            fill: #2a9d8f;
        }
    </style>
    
    <!-- Add AOS CSS -->
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">




     <section class="site-content" >
        <!-------------------------------->
        <!----------hero section Start---------->
        <!-------------------------------->
         <section class="section-slide" data-aos="fade-in">
		<div class="wrap-slick1">
			<div class="slick1">
				<div class="item-slick1" style="background-image: url(../UserTemplate/images/banner1.jpg);">
					<div class="container h-full">
						<div class="flex-col-l-m h-full p-t-100 p-b-30 respon5">
							<div class="layer-slick1 animated visible-false" data-appear="fadeInDown" data-delay="0">
								<span class="ltext-101 cl2 respon2">
									Women Collection 2025
								</span>
							</div>
								
							<div class="layer-slick1 animated visible-false" data-appear="fadeInUp" data-delay="800">
								<h2 class="ltext-201 cl2 p-t-19 p-b-43 respon1">
									NEW SEASON
								</h2>
							</div>
								
							<div class="layer-slick1 animated visible-false" data-appear="zoomIn" data-delay="1600">
								<a href="Shop.aspx" class="flex-c-m stext-101 cl0 size-101 bg1 bor1 hov-btn1 p-lr-15 trans-04">
									Shop Now
								</a>
							</div>
						</div>
					</div>
				</div>

				<div class="item-slick1" style="background-image: url(../UserTemplate/images/banner2.jpg);">
					<div class="container h-full">
						<div class="flex-col-l-m h-full p-t-100 p-b-30 respon5">
							<div class="layer-slick1 animated visible-false" data-appear="rollIn" data-delay="0">
								<span class="ltext-101 cl2 respon2">
									Men New-Season
								</span>
							</div>
								
							<div class="layer-slick1 animated visible-false" data-appear="lightSpeedIn" data-delay="800">
								<h2 class="ltext-201 cl2 p-t-19 p-b-43 respon1">
									Trousers & Shorts
								</h2>
							</div>
								
							<div class="layer-slick1 animated visible-false" data-appear="slideInUp" data-delay="1600">
								<a href="Shop.aspx" class="flex-c-m stext-101 cl0 size-101 bg1 bor1 hov-btn1 p-lr-15 trans-04">
									Shop Now
								</a>
							</div>
						</div>
					</div>
				</div>

				<div class="item-slick1" style="background-image: url(../UserTemplate/images/banner3.png);">
					<div class="container h-full">
						<div class="flex-col-l-m h-full p-t-100 p-b-30 respon5">
							<div class="layer-slick1 animated visible-false" data-appear="rotateInDownLeft" data-delay="0">
								<span class="ltext-101 cl2 respon2">
									Men Collection 2025
								</span>
							</div>
								
							<div class="layer-slick1 animated visible-false" data-appear="rotateInUpRight" data-delay="800">
								<h2 class="ltext-201 cl2 p-t-19 p-b-43 respon1">
									New arrivals
								</h2>
							</div>
								
							<div class="layer-slick1 animated visible-false" data-appear="rotateIn" data-delay="1600">
								<a href="Shop.aspx" class="flex-c-m stext-101 cl0 size-101 bg1 bor1 hov-btn1 p-lr-15 trans-04">
									Shop Now
								</a>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
</section>







<!----------Hero Section End---------->
<!-------------------------------->


<!-- New Arrivals Section -->
<section class="sec-product bg0 p-t-100 p-b-50" data-aos="fade-up" data-aos-delay="200">
    <div class="container">
        <div class="p-b-32">
            <h3 class="ltext-105 cl5 txt-center respon1">
                New Arrivals
            </h3>
        </div>

        <!-- New Arrivals Products -->
        <div class="row isotope-grid">
            <asp:Repeater ID="rptNewArrivals" runat="server" OnItemDataBound="rptNewArrivals_ItemDataBound">
                <ItemTemplate>
                    <div class='col-sm-6 col-md-3 col-lg-3 p-b-35 isotope-item'>
                        <div class="block2">
                            <div class="block2-pic hov-img0">
                                <asp:Image ID="imgProduct" runat="server" AlternateText='<%# Eval("ProductName") %>' />
                                
                            </div>
                            <div class="block2-txt flex-w flex-t p-t-14">
                                <div class="block2-txt-child1 flex-col-l">
                                    <a href='ShopDetail.aspx?id=<%# Eval("ProductID") %>' class="stext-104 cl4 hov-cl1 trans-04 js-name-b2 p-b-6">
                                        <%# Eval("ProductName") %>
                                    </a>
                                    <span class="stext-105 cl3">
                                        $<%# Eval("Price", "{0:0.00}") %>
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
</section>



	

<section class="how-it-works" data-aos="fade-up" data-aos-delay="150">
    <div class="container">
        <div class="how-it-works-wrapper">
            <div class="section-title text-center">
                <h2 class="title text-uppercase">How it <span class="primary-text">works</span></h2>
                <p class="mb-0">
                    Get your perfect basics in just 3 simple steps
                </p>
            </div>
            <div class="row d-flex align-items-stretch"> <!-- Added align-items-stretch -->
                <!-- Step 1 -->
                <div class="col-lg-4 d-flex"> <!-- Added d-flex -->
                    <div class="work-fetures text-center w-100"> <!-- Added w-100 -->
                        <div class="work-fetures-img mb-3"> <!-- Added mb-3 for consistent spacing -->
                            <img src="../UserTemplate/assets/img/how-it-works/how-1.png" alt="Browse collection" class="img-fluid" style="height: 120px;"> <!-- Added fixed height -->
                        </div>
                        <div class="work-fetures-content">
                            <h3 class="feture-title">Browse Collection</h3>
                            <p class="mb-0">Explore our essential t-shirts, trousers and shorts</p>
                        </div>
                    </div>
                </div>
                
                <!-- Step 2 -->
                <div class="col-lg-4 d-flex"> <!-- Added d-flex -->
                    <div class="work-fetures text-center w-100"> <!-- Added w-100 -->
                        <div class="work-fetures-img mb-3"> <!-- Added mb-3 for consistent spacing -->
                            <img src="../UserTemplate/assets/img/how-it-works/how-2.png" alt="Select items" class="img-fluid" style="height: 120px;"> <!-- Added fixed height -->
                        </div>
                        <div class="work-fetures-content">
                            <h3 class="feture-title">Select Items</h3>
                            <p class="mb-0">Choose your favorite styles and sizes</p>
                        </div>
                    </div>
                </div>
                
                <!-- Step 3 -->
                <div class="col-lg-4 d-flex"> <!-- Added d-flex -->
                    <div class="work-fetures text-center w-100"> <!-- Added w-100 -->
                        <div class="work-fetures-img mb-3"> <!-- Added mb-3 for consistent spacing -->
                            <img src="../UserTemplate/assets/img/how-it-works/how-3.png" alt="Fast delivery" class="img-fluid" style="height: 120px;"> <!-- Added fixed height -->
                        </div>
                        <div class="work-fetures-content">
                            <h3 class="feture-title">Fast Delivery</h3>
                            <p class="mb-0">Get your order in 2-5 business days</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>





       

<!-------------------------------->
<!----------How It Works End---------->
<!-------------------------------->

<!-------------------------------->
<!----------Simple Secure Start---------->
<!-------------------------------->
<section class="simple-secure" data-aos="fade-left">
    <div class="container-fluid">
        <div class="simple-secure-wrapper mx-auto">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <div class="simple-secure-img">
                        <!-- Outfit combo SVG: Combine t-shirt + trousers from SVGRepo -->
                        <img src="../UserTemplate/assets/img/simple-secure/secure-1.png" alt="Casual outfit combo" style="height:600px">
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="simple-secure-content text-center text-lg-start">
                        <h2 class="title text-uppercase">
                            <span class="primary-text">Essential</span> basics for everyday wear
                        </h2>
                        <p class="text">
                            Arban Choice focuses on the fundamentals - comfortable, durable clothing 
                            that fits perfectly into your daily life. No fuss, just quality essentials.
                        </p>
                        <a class="btn btn-primary" href="#">View Collection</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
<!-------------------------------->
<!----------Simple Secure End---------->
<!-------------------------------->

<!-------------------------------->
<!----------Most Trusted Start---------->
<!-------------------------------->
<section class="most-trusted position-relative" data-aos="fade-right">
    <div class="container-fluid">
        <div class="most-trusted-wrapper mx-auto">
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <div class="most-trusted-content mx-auto position-relative text-center text-lg-start">
                        <h6 class="small-title text-uppercase fs-7">Why Choose Us</h6>
                        <h2 class="title text-uppercase">The <span class="primary-text">perfect fit</span>
                            for your lifestyle</h2>
                        <p class="text">
                            We specialize in wardrobe essentials that combine comfort, quality, 
                            and affordability for both men and women.
                        </p>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="platform-features-area position-relative">
                        <div class="row">
                            <div class="col-12">
                                <div class="platform-features mx-auto">
                                    <div class="platform-features-img">
                                        <!-- Quality SVG: https://www.svgrepo.com/svg/530643/fabric -->
                                        <img src="../UserTemplate/assets/img/most-trusted/trusted-1.png" alt="Premium quality">
                                    </div>
                                    <h3 class="features-title mb-0">Premium Quality</h3>
                                </div>
                            </div>
                        </div>
                        <div class="row platform-features-area-bottom">
                            <div class="col-lg-6">
                                <div class="platform-features platform-features-left mx-auto">
                                    <div class="platform-features-img">
                                        <!-- Fit SVG: https://www.svgrepo.com/svg/530642/fit -->
                                        <img src="../UserTemplate/assets/img/most-trusted/mosttrusted-4.png"  alt="Perfect fit" >
                                    </div>
                                    <h3 class="features-title mb-0">Perfect Fit</h3>
                                </div>
                            </div>
                            <div class="col-lg-6">
                                <div class="platform-features platform-features-right mx-auto">
                                    <div class="platform-features-img">
                                        <!-- Care SVG: https://www.svgrepo.com/svg/530641/washing-machine -->
                                        <img src="../UserTemplate/assets/img/most-trusted/trusted-3.png"  alt="Easy care"  >
                                    </div>
                                    <h3 class="features-title mb-0">Easy Care</h3>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>
<!-------------------------------->
<!----------Most Trusted End---------->
<!-------------------------------->

<!-------------------------------->
<!----------Anytime Anywhere Start---------->
<!-------------------------------->
<section class="anytime-anywhere" data-aos="zoom-in">
    <div class="container">
        <div class="anytime-anywhere-wrapper">o
            <div class="row align-items-center">
                <div class="col-lg-6">
                    <div class="anytime-anywhere-img">
                        <!-- Devices SVG: https://www.svgrepo.com/svg/340860/mobile -->
                        <img src="../UserTemplate/assets/img/anytime-anywhere/anytime.png" alt="Shop on any device">
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="anytime-anywhere-content text-center text-lg-start">
                        <h6 class="small-title text-uppercase fs-7">ARBAN CHOICE</h6>
                        <h2 class="title text-uppercase">Shop <span class="primary-text">Anywhere</span>
                            Any <span class="primary-text">Time</span></h2>
                        <p class="text">
                            Our online store is always open. Browse our collection of essentials 
                            whenever inspiration strikes.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

    </section>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
	<script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    <script>
        AOS.init({
            duration: 800,          // Animation duration
            easing: 'ease-in-out',  // Easing type
            once: false,            // Whether animation should happen only once
            offset: 120,            // Offset (px) from the original trigger point
            delay: 100,             // Delay between animations
        });
    </script>
</asp:Content>
