<%@ Page Title="" Language="C#" MasterPageFile="~/Adminauth/Adminlogin.Master" AutoEventWireup="true" CodeBehind="adminlogin.aspx.cs" Inherits="Next_ae.Admin.adminlogin" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-color: #4361ee;
            --primary-light: #4895ef;
            --secondary-color: #3f37c9;
            --text-color: #2b2d42;
            --text-light: #8d99ae;
            --bg-color: #f8f9fa;
            --card-bg: #ffffff;
            --border-color: #e9ecef;
            --error-color: #ef233c;
            --success-color: #4cc9f0;
            --shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        }

        [data-theme="dark"] {
            --primary-color: #4895ef;
            --primary-light: #4361ee;
            --secondary-color: #3a0ca3;
            --text-color: #f8f9fa;
            --text-light: #adb5bd;
            --bg-color: #121212;
            --card-bg: #1e1e1e;
            --border-color: #2d2d2d;
            --shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            transition: background-color 0.3s, color 0.3s;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: var(--bg-color);
            color: var(--text-color);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            line-height: 1.6;
        }

        .container {
            position: relative;
            width: 1600px;
            max-width: 2500px;
            padding: 2rem;
            overflow: hidden;
        }

        .login-card {
            background-color: var(--card-bg);
            border-radius: 16px;
            padding: 2.5rem;
            width: 500px;
            max-width: 520px;
            margin: 0 auto;
            box-shadow: var(--shadow);
            position: relative;
            z-index: 2;
            border: 1px solid var(--border-color);
        }

        .branding {
            text-align: center;
            margin-bottom: 2rem;
        }

        .logo {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 1rem;
            color: white;
            font-size: 2rem;
        }

        .branding h1 {
            font-size: 1.8rem;
            margin-bottom: 0.5rem;
            color: var(--text-color);
        }

        .branding p {
            color: var(--text-light);
            font-size: 0.9rem;
        }

        .input-group {
            margin-bottom: 1.5rem;
        }

        .input-group label {
            display: block;
            margin-bottom: 0.5rem;
            font-weight: 500;
            color: var(--text-color);
        }

        .input-field {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-field i {
            position: absolute;
            left: 15px;
            color: var(--text-light);
        }

        .input-field input {
            width: 100%;
            padding: 12px 15px 12px 45px;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 1rem;
            background-color: var(--card-bg);
            color: var(--text-color);
            transition: border-color 0.3s;
        }

        .input-field input:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 2px rgba(67, 97, 238, 0.2);
        }

        .toggle-password {
            position: absolute;
            right: 15px;
            background: none;
            border: none;
            color: var(--text-light);
            cursor: pointer;
            padding: 5px;
        }

        .options {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            font-size: 0.9rem;
        }

        .remember-me {
            display: flex;
            align-items: center;
            cursor: pointer;
        }

        .remember-me input {
            margin-right: 8px;
            accent-color: var(--primary-color);
        }

        .forgot-password {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 500;
        }

        .forgot-password:hover {
            text-decoration: underline;
        }

        .login-btn {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, var(--primary-color), var(--primary-light));
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .login-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(67, 97, 238, 0.3);
        }

        .theme-switcher {
            display: flex;
            align-items: center;
            justify-content: center;
            margin-top: 2rem;
            gap: 10px;
            color: var(--text-light);
            font-size: 0.9rem;
        }

        .theme-btn {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            border: none;
            cursor: pointer;
            background-color: var(--border-color);
            color: var(--text-color);
            transition: transform 0.2s;
        }

        .theme-btn:hover {
            transform: scale(1.1);
        }

        .theme-btn.active {
            background-color: var(--primary-color);
            color: white;
        }

        .decoration {
            position: absolute;
            width: 100%;
            height: 100%;
            top: 0;
            left: 0;
            pointer-events: none;
            z-index: 1;
        }

        .circle {
            position: absolute;
            border-radius: 50%;
            background: linear-gradient(135deg, rgba(67, 97, 238, 0.1), rgba(72, 149, 239, 0.1));
        }

        .circle-1 {
            width: 300px;
            height: 300px;
            top: -100px;
            right: -100px;
        }

        .circle-2 {
            width: 200px;
            height: 200px;
            bottom: -50px;
            left: -50px;
        }

        .circle-3 {
            width: 150px;
            height: 150px;
            top: 50%;
            left: 30%;
        }

        #errorMessage {
            color: var(--error-color);
            margin-top: 1rem;
            text-align: center;
            display: none;
        }

        @media (max-width: 480px) {
            .login-card {
                padding: 1.5rem;
            }
    
            .branding h1 {
                font-size: 1.5rem;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="container">
        <div class="login-card">
            <div class="branding">
                <div class="logo">
                    <i class="fas fa-store"></i>
                </div>
                <h1>Admin Portal</h1>
                <p>Manage your ecommerce store</p>
            </div>
    
            <div id="loginForm">
                <div class="input-group">
                    <label for="username">Username</label>
                    <div class="input-field">
                        <i class="fas fa-user"></i>
                        <input type="text" id="username" name="username" placeholder="Enter admin username" required>
                    </div>
                </div>
        
                <div class="input-group">
                    <label for="password">Password</label>
                    <div class="input-field">
                        <i class="fas fa-lock"></i>
                        <input type="password" id="password" name="password" placeholder="Enter your password" required>
                        <button type="button" class="toggle-password" aria-label="Show password">
                            <i class="fas fa-eye"></i>
                        </button>
                    </div>
                </div>
        
                <div class="options">
                    <label class="remember-me">
                        <input type="checkbox" id="remember" name="remember">
                        <span>Remember me</span>
                    </label>
                    <a href="#" class="forgot-password">Forgot password?</a>
                </div>
                
        
               <!-- Replace both buttons with this single button -->
                <button type="button" id="btnLogin" class="login-btn">Login</button>
                <div id="errorMessage"></div>
            </div>
            
            <div class="theme-switcher">
                <span>Theme:</span>
                <button class="theme-btn light active" data-theme="light" title="Light theme">
                    <i class="fas fa-sun"></i>
                </button>
                <button class="theme-btn dark" data-theme="dark" title="Dark theme">
                    <i class="fas fa-moon"></i>
                </button>
                <button class="theme-btn system" data-theme="system" title="System preference">
                    <i class="fas fa-desktop"></i>
                </button>
            </div>
        </div>
        
        <div class="decoration">
            <div class="circle circle-1"></div>
            <div class="circle circle-2"></div>
            <div class="circle circle-3"></div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function () {
            // Theme switching functionality
            const themeButtons = $('.theme-btn');
            const html = document.documentElement;

            // Check for saved theme preference
            const savedTheme = localStorage.getItem('theme') || 'light';
            setTheme(savedTheme);

            // Theme button click handler
            themeButtons.on('click', function () {
                const theme = $(this).data('theme');
                setTheme(theme);
                localStorage.setItem('theme', theme);
            });

            function setTheme(theme) {
                // Update active button
                themeButtons.removeClass('active');
                $(`.theme-btn[data-theme="${theme}"]`).addClass('active');

                // Apply theme
                if (theme === 'system') {
                    const systemDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                    html.setAttribute('data-theme', systemDark ? 'dark' : 'light');

                    // Listen for system theme changes
                    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', e => {
                        if (localStorage.getItem('theme') === 'system') {
                            html.setAttribute('data-theme', e.matches ? 'dark' : 'light');
                        }
                    });
                } else {
                    html.setAttribute('data-theme', theme);
                }
            }

            // Toggle password visibility
            $('.toggle-password').on('click', function () {
                const password = $('#password');
                const type = password.attr('type') === 'password' ? 'text' : 'password';
                password.attr('type', type);
                $(this).html(type === 'password' ? '<i class="fas fa-eye"></i>' : '<i class="fas fa-eye-slash"></i>');
            });

            // Form submission
            $('#btnLogin').click(function () {
                const username = $('#username').val().trim();
                const password = $('#password').val().trim();
                const remember = $('#remember').is(':checked');
                const loginBtn = $('#btnLogin');
                const errorMsg = $('#errorMessage');

                // Clear previous errors
                errorMsg.hide().text('');

                // Validate inputs
                if (!username || !password) {
                    errorMsg.text('Please enter both username and password').show();
                    return;
                }

                // Show loading state
                loginBtn.html('<i class="fas fa-spinner fa-spin"></i> Authenticating...').prop('disabled', true);

                // Make AJAX call
                $.ajax({
                    type: "POST",
                    url: '<%= ResolveUrl("~/Admin/adminlogin.aspx/LoginAdmin") %>',
        data: JSON.stringify({
            username: username,
            password: password,
            remember: remember
        }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            console.log("Response:", response);

            try {
                // Handle both direct response and response.d
                var result = typeof response === 'string' ? JSON.parse(response) :
                    response.d ? JSON.parse(response.d) : response;

                if (result.Success) {
                    // Force page reload to ensure session is established
                    window.location.href = result.RedirectUrl || 'Dashboard.aspx';
                } else {
                    errorMsg.text(result.Message || 'Login failed').show();
                }
            } catch (e) {
                console.error("Error parsing response:", e);
                errorMsg.text('Invalid server response').show();
            }
        },
        error: function (xhr, status, error) {
            console.error("AJAX Error:", status, error);
            errorMsg.text('Server error occurred. Please try again.').show();
        },
        complete: function () {
            loginBtn.html('Login').prop('disabled', false);
        }
    });
            });
      
        });
    </script>
</asp:Content>