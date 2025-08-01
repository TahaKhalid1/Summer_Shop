﻿<%@ Page Title="Login" Language="C#" MasterPageFile="~/Authentication/Authentication.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Next_ae.User.Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Montserrat:wght@100;200;300;400;500;600;700;800;900&display=swap');
        @import url('https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css');

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Montserrat', sans-serif;
        }

        body, html {
            height: 100%;
            width: 100%;
            overflow: hidden;
        }

        .container {
            position: relative;
            width: 100%;
            height: 100vh;
            background-color: #fff;
            overflow: hidden;
        }

        .forms-container {
            position: absolute;
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
        }

        .signin-signup {
            position: absolute;
            top: 50%;
            left: 75%;
            transform: translate(-50%, -50%);
            width: 50%;
            display: grid;
            grid-template-columns: 1fr;
            z-index: 5;
            transition: 1s 0.7s ease-in-out;
        }

        .sign-in-form, .sign-up-form {
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            padding: 0 5rem;
            overflow: hidden;
            grid-column: 1 / 2;
            grid-row: 1 / 2;
            transition: all 0.2s 0.7s;
        }

        .sign-in-form {
            z-index: 2;
        }

        .sign-up-form {
            z-index: 1;
            opacity: 0;
            transform: translateX(100%);
        }

        .title {
            font-size: 2.2rem;
            color: #444;
            margin-bottom: 10px;
        }

        .input-field {
            max-width: 380px;
            width: 100%;
            background-color: #f0f0f0;
            margin: 10px 0;
            height: 45px;
            border-radius: 5px;
            display: grid;
            grid-template-columns: 15% 85%;
            padding: 0 0.4rem;
            position: relative;
        }

        .input-field i {
            text-align: center;
            line-height: 55px;
            color: #acacac;
            transition: 0.5s;
            font-size: 1.1rem;
        }

        .input-field input, .input-field select {
            background: none;
            outline: none;
            border: none;
            line-height: 1;
            font-weight: 500;
            font-size: 1.1rem;
            color: #333;
            width: 100%;
            padding: 0.5rem;
        }

        .input-field input::placeholder {
            color: #aaa;
            font-weight: 500;
        }

        .social-text {
            padding: 0.7rem 0;
            font-size: 1rem;
        }

        .social-media {
            display: flex;
            justify-content: center;
        }

        .social-icon {
            height: 46px;
            width: 46px;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: 0 0.45rem;
            color: #333;
            border-radius: 50%;
            border: 1px solid #333;
            text-decoration: none;
            font-size: 1.1rem;
            transition: 0.3s;
        }

        .social-icon:hover {
            color: #F86F03;
            border-color: #F86F03;
        }

        .btn {
            width: 150px;
            background-color: #2015e3dc;
            border: none;
            outline: none;
            height: 49px;
            border-radius: 4px;
            color: #fff;
            text-transform: uppercase;
            font-weight: 600;
            margin: 10px 0;
            cursor: pointer;
            transition: 0.5s;
        }

        .btn:hover {
            background-color: #070707;
        }

        .panels-container {
            position: absolute;
            height: 100%;
            width: 100%;
            top: 0;
            left: 0;
            display: grid;
            grid-template-columns: repeat(2, 1fr);
        }

        .container:before {
            content: "";
            position: absolute;
            height: 2000px;
            width: 2000px;
            top: -10%;
            right: 48%;
            transform: translateY(-50%);
            background-image: linear-gradient(-45deg, #131312 0%, #000000 100%);
            transition: 1.8s ease-in-out;
            border-radius: 50%;
            z-index: 6;
        }

        .image {
            width: 100%;
            transition: transform 1.1s ease-in-out;
            transition-delay: 0.4s;
        }

        .panel {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            justify-content: space-around;
            text-align: center;
            z-index: 6;
        }

        .left-panel {
            pointer-events: all;
            padding: 3rem 17% 2rem 12%;
        }

        .right-panel {
            pointer-events: none;
            padding: 3rem 12% 2rem 17%;
        }

        .panel .content {
            color: #fff;
            transition: transform 0.9s ease-in-out;
            transition-delay: 0.6s;
        }

        .panel h3 {
            font-weight: 600;
            line-height: 1;
            font-size: 1.5rem;
        }

        .panel p {
            font-size: 0.95rem;
            padding: 0.7rem 0;
        }

        .btn.transparent {
            margin: 0;
            background: none;
            border: 2px solid #fff;
            width: 130px;
            height: 41px;
            font-weight: 600;
            font-size: 0.8rem;
        }

        .right-panel .image,
        .right-panel .content {
            transform: translateX(800px);
        }

        /* Animation */
        .container.sign-up-mode:before {
            transform: translate(100%, -50%);
            right: 52%;
        }

        .container.sign-up-mode .left-panel .image,
        .container.sign-up-mode .left-panel .content {
            transform: translateX(-800px);
        }

        .container.sign-up-mode .signin-signup {
            left: 25%;
        }

        .container.sign-up-mode .sign-up-form {
            opacity: 1;
            z-index: 2;
            transform: translateX(0%);
        }

        .container.sign-up-mode .sign-in-form {
            opacity: 0;
            z-index: 1;
            transform: translateX(-100%);
        }

        .container.sign-up-mode .right-panel .image,
        .container.sign-up-mode .right-panel .content {
            transform: translateX(0%);
        }

        .container.sign-up-mode .left-panel {
            pointer-events: none;
        }

        .container.sign-up-mode .right-panel {
            pointer-events: all;
        }

        .error-message {
            color: red;
            font-size: 0.9rem;
            margin-top: 5px;
        }

        @media (max-width: 870px) {
            .container {
                min-height: 800px;
                height: 100vh;
            }
            
            .signin-signup {
                width: 100%;
                top: 95%;
                transform: translate(-50%, -100%);
                transition: 1s 0.8s ease-in-out;
            }

            .signin-signup,
            .container.sign-up-mode .signin-signup {
                left: 50%;
            }

            .panels-container {
                grid-template-columns: 1fr;
                grid-template-rows: 1fr 2fr 1fr;
            }

            .panel {
                flex-direction: row;
                justify-content: space-around;
                align-items: center;
                padding: 2.5rem 8%;
                grid-column: 1 / 2;
            }

            .right-panel {
                grid-row: 3 / 4;
            }

            .left-panel {
                grid-row: 1 / 2;
            }

            .image {
                width: 200px;
                transition: transform 0.9s ease-in-out;
                transition-delay: 0.6s;
            }

            .panel .content {
                padding-right: 15%;
                transition: transform 0.9s ease-in-out;
                transition-delay: 0.8s;
            }

            .panel h3 {
                font-size: 1.2rem;
            }

            .panel p {
                font-size: 0.7rem;
                padding: 0.5rem 0;
            }

            .btn.transparent {
                width: 110px;
                height: 35px;
                font-size: 0.7rem;
            }

            .container:before {
                width: 1500px;
                height: 1500px;
                transform: translateX(-50%);
                left: 30%;
                bottom: 68%;
                right: initial;
                top: initial;
                transition: 2s ease-in-out;
            }

            .container.sign-up-mode:before {
                transform: translate(-50%, 100%);
                bottom: 32%;
                right: initial;
            }

            .container.sign-up-mode .left-panel .image,
            .container.sign-up-mode .left-panel .content {
                transform: translateY(-300px);
            }

            .container.sign-up-mode .right-panel .image,
            .container.sign-up-mode .right-panel .content {
                transform: translateY(0px);
            }

            .right-panel .image,
            .right-panel .content {
                transform: translateY(300px);
            }

            .container.sign-up-mode .signin-signup {
                top: 5%;
                transform: translate(-50%, 0);
            }
        }

        @media (max-width: 570px) {
            form {
                padding: 0 1.5rem;
            }

            .image {
                display: none;
            }
            
            .panel .content {
                padding: 0.5rem 1rem;
            }
            
            .container {
                padding: 1.5rem;
            }

            .container:before {
                bottom: 72%;
                left: 50%;
            }

            .container.sign-up-mode:before {
                bottom: 28%;
                left: 50%;
            }
        }
    </style>
</asp:Content>



<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container" id="mainContainer">
        <div class="forms-container">
            <div class="signin-signup">
                <!-- Sign In Form -->
                <asp:Panel ID="pnlSignIn" runat="server" CssClass="sign-in-form" DefaultButton="btnLogin">
                    <h2 class="title">Welcome Back</h2>
                    <div class="input-field">
                        <i class="fas fa-envelope"></i>
                        <asp:TextBox ID="txtLoginEmail" runat="server" placeholder="Email" TextMode="Email"></asp:TextBox>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvLoginEmail" runat="server" ControlToValidate="txtLoginEmail"
                        ErrorMessage="Email is required" CssClass="error-message" Display="Dynamic" ValidationGroup="Login"></asp:RequiredFieldValidator>
                    
                    <div class="input-field">
                        <i class="fas fa-lock"></i>
                        <asp:TextBox ID="txtLoginPassword" runat="server" placeholder="Password" TextMode="Password"></asp:TextBox>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvLoginPassword" runat="server" ControlToValidate="txtLoginPassword"
                        ErrorMessage="Password is required" CssClass="error-message" Display="Dynamic" ValidationGroup="Login"></asp:RequiredFieldValidator>
                    
                    <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="btn solid" OnClick="btnLogin_Click" ValidationGroup="Login" />
                    <asp:Label ID="lblLoginError" runat="server" Text="" CssClass="error-message" Visible="false"></asp:Label>
                    
                    <p class="social-text">Or sign in with</p>
                    <div class="social-media">
                        <a href="#" class="social-icon"><i class="fab fa-facebook-f"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-google"></i></a>
                        <a href="#" class="social-icon"><i class="fab fa-apple"></i></a>
                    </div>
                   <%-- <p class="social-text" style="margin-top:15px;">
                        <a href="ForgotPassword.aspx" style="color:#2015e3dc;">Forgot password?</a>
                    </p>--%>
                </asp:Panel>
                
                <!-- Sign Up Form -->
                <asp:Panel ID="pnlSignUp" runat="server" CssClass="sign-up-form" DefaultButton="btnSignUp">
                    <h2 class="title">Join Arban Choice</h2>
                    
                    <div class="input-field">
                        <i class="fas fa-user"></i>
                        <asp:TextBox ID="txtFirstName" runat="server" placeholder="First Name"></asp:TextBox>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvFirstName" runat="server" ControlToValidate="txtFirstName"
                        ErrorMessage="First name is required" CssClass="error-message" Display="Dynamic" ValidationGroup="Register"></asp:RequiredFieldValidator>
                    
                    <div class="input-field">
                        <i class="fas fa-user"></i>
                        <asp:TextBox ID="txtLastName" runat="server" placeholder="Last Name"></asp:TextBox>
                    </div>
                   
                    
                    <div class="input-field">
                        <i class="fas fa-envelope"></i>
                        <asp:TextBox ID="txtEmail" runat="server" placeholder="Email" TextMode="Email"></asp:TextBox>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                        ErrorMessage="Email is required" CssClass="error-message" Display="Dynamic" ValidationGroup="Register"></asp:RequiredFieldValidator>
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                        ErrorMessage="Invalid email format" ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                        CssClass="error-message" Display="Dynamic" ValidationGroup="Register"></asp:RegularExpressionValidator>
                    
                    <div class="input-field">
                        <i class="fas fa-lock"></i>
                        <asp:TextBox ID="txtPassword" runat="server" placeholder="Password (min. 8 characters)" TextMode="Password"></asp:TextBox>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                        ErrorMessage="Password is required" CssClass="error-message" Display="Dynamic" ValidationGroup="Register"></asp:RequiredFieldValidator>
                    <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword"
                        ErrorMessage="Password must be at least 8 characters with at least one number and one letter"
                        ValidationExpression="^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$"
                        CssClass="error-message" Display="Dynamic" ValidationGroup="Register"></asp:RegularExpressionValidator>
                    
                    <div class="input-field">
                        <i class="fas fa-phone"></i>
                        <asp:TextBox ID="txtPhone" runat="server" placeholder="Phone Number" TextMode="Phone"></asp:TextBox>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone"
                        ErrorMessage="Phone number is required" CssClass="error-message" Display="Dynamic" ValidationGroup="Register"></asp:RequiredFieldValidator>
                    
                    <asp:Button ID="btnSignUp" runat="server" Text="Create Account" CssClass="btn" OnClick="btnSignUp_Click" ValidationGroup="Register" />
                    <asp:Label ID="lblSignUpError" runat="server" Text="" CssClass="error-message" Visible="false"></asp:Label>
                    
                    <p class="social-text" style="margin-top:15px; font-size:0.8rem;">
                        By creating an account, you agree to Arban Choice's <a href="#" style="color:#2015e3dc;">Terms</a> and <a href="#" style="color:#2015e3dc;">Privacy Policy</a>
                    </p>
                </asp:Panel>
            </div>
        </div>

        <div class="panels-container">
            <div class="panel left-panel">
                <div class="content">
                    <h3>New to Arban Choice?</h3>
                    <p>Create an account to unlock exclusive deals, faster checkout, and personalized recommendations tailored just for you.</p>
                    <button type="button" class="btn transparent" id="sign-up-btn">Join Now</button>
                </div>
                <img src="https://i.ibb.co/6HXL6q1/Privacy-policy-rafiki.png" class="image" alt="" />
            </div>
            <div class="panel right-panel">
                <div class="content">
                    <h3>Already a Member?</h3>
                    <p>Welcome back! Sign in to track your orders, manage your wishlist, and continue your shopping experience.</p>
                    <button type="button" class="btn transparent" id="sign-in-btn">Sign In</button>
                </div>
                <img src="https://i.ibb.co/nP8H853/Mobile-login-rafiki.png" class="image" alt="" />
            </div>
        </div>
    </div>

    <script>
        const sign_in_btn = document.querySelector("#sign-in-btn");
        const sign_up_btn = document.querySelector("#sign-up-btn");
        const container = document.querySelector(".container");

        sign_up_btn.addEventListener("click", () => {
            container.classList.add("sign-up-mode");
        });

        sign_in_btn.addEventListener("click", () => {
            container.classList.remove("sign-up-mode");
        });

        // Initialize to show sign-in form by default
        document.addEventListener("DOMContentLoaded", function () {
            container.classList.remove("sign-up-mode");
        });
    </script>
    <script type="text/javascript">
        function loginSuccess() {
            // This function would be called after successful login
            // Refresh the page or update UI elements as needed
            window.location.reload();
        }

        function loginFailed() {
            // Handle login failure
            alert('Login failed. Please check your credentials.');
        }
    </script>
</asp:Content>




