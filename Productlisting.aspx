
<%@ Page Title="Add Product" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Productlisting.aspx.cs" Inherits="Next_ae.User.Productlisting" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- SweetAlert for beautiful alerts -->
    <link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <script type="text/javascript">
        // Helper functions
        function updateFileName(input, displayElementId) {
            const displayElement = document.getElementById(displayElementId);
            if (input.files.length > 0) {
                displayElement.textContent = input.files[0].name;
                input.closest('.file-upload-wrapper').classList.remove('has-error');
            } else {
                displayElement.textContent = 'No file selected';
            }
        }

        function updateFileNames(input, displayElementId) {
            const displayElement = document.getElementById(displayElementId);
            if (input.files.length > 0) {
                if (input.files.length === 1) {
                    displayElement.textContent = input.files[0].name;
                } else {
                    displayElement.textContent = `${input.files.length} files selected`;
                }
            } else {
                displayElement.textContent = 'No files selected';
            }
        }

        function showSuccessMessage(message) {
            Swal.fire({
                icon: 'success',
                title: 'Success!',
                text: message,
                confirmButtonColor: '#5a8dee'
            });
        }

        function showErrorMessage(message) {
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: message,
                confirmButtonColor: '#ff5b5c'
            });
        }

        document.addEventListener('DOMContentLoaded', function () {
            const steps = document.querySelectorAll('.step');
            const stepContents = document.querySelectorAll('.step-content');
            const prevBtn = document.querySelector('.prev-step');
            const nextBtn = document.querySelector('.next-step');
            const publishBtn = document.querySelector('.publish-product');
            const progressBar = document.querySelector('.step-progress-bar');

            let currentStep = 1;
            const totalSteps = steps.length;

            // Make file upload boxes clickable
            document.getElementById('mainImageUploadBox').addEventListener('click', function () {
                document.getElementById('<%= fileMainImage.ClientID %>').click();
            });

            document.getElementById('galleryImagesUploadBox').addEventListener('click', function () {
                document.getElementById('<%= fileGalleryImages.ClientID %>').click();
            });

            function updateProgress() {
                const progressPercentage = ((currentStep - 1) / (totalSteps - 1)) * 100;
                progressBar.style.width = `${progressPercentage}%`;

                steps.forEach((step, index) => {
                    const stepNumber = parseInt(step.dataset.step);
                    if (stepNumber < currentStep) {
                        step.classList.add('completed');
                        step.classList.remove('active');
                    } else if (stepNumber === currentStep) {
                        step.classList.add('active');
                        step.classList.remove('completed');
                    } else {
                        step.classList.remove('active', 'completed');
                    }
                });

                stepContents.forEach(content => {
                    if (parseInt(content.dataset.step) === currentStep) {
                        content.classList.add('active');
                    } else {
                        content.classList.remove('active');
                    }
                });

                prevBtn.disabled = currentStep === 1;

                if (currentStep === totalSteps) {
                    nextBtn.style.display = 'none';
                    publishBtn.style.display = 'inline-flex';
                } else {
                    nextBtn.style.display = 'inline-flex';
                    publishBtn.style.display = 'none';
                }
            }

            function validateStep(step) {
                let isValid = true;
                document.querySelectorAll('.has-error').forEach(el => {
                    el.classList.remove('has-error');
                });

                if (step === 1) {
                    const category = document.getElementById('<%= ddlCategory.ClientID %>');
                    const brand = document.getElementById('<%= txtBrand.ClientID %>');

                    if (category.value === "0") {
                        category.closest('.form-group').classList.add('has-error');
                        isValid = false;
                    }

                    if (brand.value.trim() === "") {
                        brand.closest('.form-group').classList.add('has-error');
                        isValid = false;
                    }
                }

                if (step === 2) {
                    const productName = document.getElementById('<%= txtProductName.ClientID %>');
                    const shortDesc = document.getElementById('<%= txtShortDescription.ClientID %>');
                    const fullDesc = document.getElementById('<%= txtDescription.ClientID %>');
                    
                    if (productName.value.trim() === "") {
                        productName.closest('.form-group').classList.add('has-error');
                        isValid = false;
                    }
                    
                    if (shortDesc.value.trim() === "") {
                        shortDesc.closest('.form-group').classList.add('has-error');
                        isValid = false;
                    }
                    
                    if (fullDesc.value.trim() === "") {
                        fullDesc.closest('.form-group').classList.add('has-error');
                        isValid = false;
                    }
                }
                
                if (step === 3) {
                    const sku = document.getElementById('<%= txtSKU.ClientID %>');
                    
                    if (sku.value.trim() === "") {
                        sku.closest('.form-group').classList.add('has-error');
                        isValid = false;
                    }
                }
                
                if (step === 4) {
                    const mainImage = document.getElementById('<%= fileMainImage.ClientID %>');
                    
                    if (mainImage.files.length === 0) {
                        mainImage.closest('.file-upload-wrapper').classList.add('has-error');
                        isValid = false;
                    }
                }
                
                if (step === 6) {
                    const price = document.getElementById('<%= txtPrice.ClientID %>');
                    const quantity = document.getElementById('<%= txtQuantity.ClientID %>');

                    if (price.value.trim() === "" || isNaN(parseFloat(price.value))) {
                        price.closest('.form-group').classList.add('has-error');
                        isValid = false;
                    }

                    if (quantity.value.trim() === "" || isNaN(parseInt(quantity.value))) {
                        quantity.closest('.form-group').classList.add('has-error');
                        isValid = false;
                    }
                }

                return isValid;
            }

            function validateAllSteps() {
                for (let step = 1; step <= 6; step++) {
                    if (!validateStep(step)) {
                        currentStep = step;
                        updateProgress();
                        return false;
                    }
                }
                return true;
            }

            nextBtn.addEventListener('click', function () {
                if (validateStep(currentStep) && currentStep < totalSteps) {
                    currentStep++;
                    updateProgress();
                }
            });

            prevBtn.addEventListener('click', function () {
                if (currentStep > 1) {
                    currentStep--;
                    updateProgress();
                }
            });

            publishBtn.addEventListener('click', function (e) {
                e.preventDefault();

                if (validateAllSteps()) {
                    publishBtn.disabled = true;
                    publishBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Saving...';

                    // Create form data
                    const formData = new FormData();
                    formData.append('__EVENTTARGET', '<%= btnPublishProduct.UniqueID %>');
                    formData.append('__EVENTARGUMENT', '');

                    // Add all form fields
                    document.querySelectorAll('input, select, textarea').forEach(field => {
                        if (field.name && !field.disabled && field.type !== 'file') {
                            formData.append(field.name, field.value);
                        }
                    });

                    // Add file uploads
                    const mainImage = document.getElementById('<%= fileMainImage.ClientID %>');
                    if (mainImage.files.length > 0) {
                        formData.append(mainImage.name, mainImage.files[0]);
                    }

                    const galleryImages = document.getElementById('<%= fileGalleryImages.ClientID %>');
                    for (let i = 0; i < galleryImages.files.length; i++) {
                        formData.append(galleryImages.name, galleryImages.files[i]);
                    }

                    // Submit via AJAX
                    fetch(window.location.href, {
                        method: 'POST',
                        body: formData,
                        headers: {
                            'Accept': 'application/json',
                            'X-Requested-With': 'XMLHttpRequest'
                        }
                    })
                        .then(response => response.json())
                        .then(data => {
                            if (data.success) {
                                showSuccessMessage(data.message);
                                // Generate new product ID
                                document.getElementById('<%= txtProductCode.ClientID %>').value = 'PROD-' + new Date().toISOString().replace(/[-:T.]/g, '').slice(0, 14);
                        } else {
                            showErrorMessage(data.message);
                        }
                        publishBtn.disabled = false;
                        publishBtn.innerHTML = 'Publish Product';
                    })
                        .catch(error => {
                            showErrorMessage('Error submitting form: ' + error.message);
                            publishBtn.disabled = false;
                            publishBtn.innerHTML = 'Publish Product';
                        });
                }
            });

            updateProgress();
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        :root {
            --primary: #5a8dee;
            --secondary: #475f7b;
            --success: #39da8a;
            --danger: #ff5b5c;
            --warning: #fdac41;
            --info: #00cfdd;
            --dark: #222f3e;
            --light: #a3afbd;
            --white: #fff;
            --black: #000;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Poppins', sans-serif;
        }

        body {
            background-color: #f2f4f6;
            color: #333;
        }

        .container {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar Styles */
        .sidebar {
            width: 260px;
            background-color: var(--white);
            box-shadow: 0 0 35px 0 rgba(154, 161, 171, 0.15);
            transition: all 0.3s ease;
            position: fixed;
            height: 100%;
            z-index: 1000;
        }

        .sidebar-header {
            padding: 0 20px;
            height: 70px;
            display: flex;
            align-items: center;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }

        .sidebar-logo {
            font-size: 20px;
            font-weight: 600;
            color: var(--primary);
        }

        .sidebar-menu {
            padding: 20px 0;
        }

        .menu-title {
            padding: 10px 20px;
            font-size: 11px;
            text-transform: uppercase;
            color: var(--light);
            font-weight: 600;
            letter-spacing: 0.5px;
        }

        .menu-item {
            display: flex;
            align-items: center;
            padding: 12px 20px;
            color: var(--secondary);
            text-decoration: none;
            transition: all 0.3s ease;
        }

        .menu-item:hover {
            color: var(--primary);
            background-color: rgba(90, 141, 238, 0.1);
        }

        .menu-item.active {
            color: var(--primary);
            background-color: rgba(90, 141, 238, 0.1);
        }

        .menu-icon {
            margin-right: 10px;
            font-size: 16px;
        }

        .menu-text {
            font-size: 14px;
        }

        /* Main Content Styles */
        .main-content {
            flex: 1;
            margin-left: 260px;
            padding: 20px;
        }

        /* Header Styles */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px;
            background-color: var(--white);
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.02);
            margin-bottom: 20px;
        }

        .header-title {
            font-size: 20px;
            font-weight: 600;
            color: var(--dark);
        }

        .header-actions {
            display: flex;
            align-items: center;
        }

        .search-box {
            position: relative;
            margin-right: 15px;
        }

        .search-input {
            padding: 8px 15px 8px 35px;
            border-radius: 5px;
            border: 1px solid #ddd;
            outline: none;
            width: 200px;
            transition: all 0.3s ease;
        }

        .search-input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(90, 141, 238, 0.2);
        }

        .search-icon {
            position: absolute;
            left: 10px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--light);
        }

        .user-profile {
            display: flex;
            align-items: center;
        }

        .user-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            margin-right: 10px;
            object-fit: cover;
        }

        .user-name {
            font-size: 14px;
            font-weight: 500;
            color: var(--dark);
        }

        /* Card Styles */
        .card {
            background-color: var(--white);
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.02);
            margin-bottom: 20px;
        }

        .card-header {
            padding: 15px 20px;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .card-title {
            font-size: 16px;
            font-weight: 600;
            color: var(--dark);
        }

        .card-body {
            padding: 20px;
        }

        /* Form Styles */
        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: 500;
            color: var(--dark);
        }

        .form-control {
            width: 100%;
            padding: 10px 15px;
            border-radius: 5px;
            border: 1px solid #ddd;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        .form-control:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(90, 141, 238, 0.2);
            outline: none;
        }

        textarea.form-control {
            min-height: 120px;
            resize: vertical;
        }

        .form-row {
            display: flex;
            flex-wrap: wrap;
            margin: 0 -10px;
        }

        .form-col {
            flex: 1;
            padding: 0 10px;
            min-width: 250px;
        }

        /* File Upload Styles */
        .file-upload {
            position: relative;
            overflow: hidden;
            display: inline-block;
            width: 100%;
        }

        .file-upload-btn {
            border: 2px dashed #ddd;
            border-radius: 5px;
            padding: 40px 20px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 100%;
        }

        .file-upload-btn:hover {
            border-color: var(--primary);
            background-color: rgba(90, 141, 238, 0.05);
        }

        .file-upload-input {
            position: absolute;
            left: 0;
            top: 0;
            opacity: 0;
            width: 100%;
            height: 100%;
            cursor: pointer;
        }

        .upload-icon {
            font-size: 36px;
            color: var(--light);
            margin-bottom: 10px;
        }

        .upload-text {
            font-size: 14px;
            color: var(--secondary);
        }

        .upload-hint {
            font-size: 12px;
            color: var(--light);
            margin-top: 5px;
        }

        /* Preview Images */
        .preview-images {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 15px;
        }

        .preview-image {
            position: relative;
            width: 80px;
            height: 80px;
            border-radius: 5px;
            overflow: hidden;
        }

        .preview-image img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .remove-image {
            position: absolute;
            top: 5px;
            right: 5px;
            width: 20px;
            height: 20px;
            background-color: var(--danger);
            color: var(--white);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 10px;
            cursor: pointer;
        }

        /* Switch Styles */
        .form-switch {
            position: relative;
            display: inline-block;
            width: 50px;
            height: 24px;
        }

        .form-switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #ccc;
            transition: .4s;
            border-radius: 24px;
        }

        .slider:before {
            position: absolute;
            content: "";
            height: 16px;
            width: 16px;
            left: 4px;
            bottom: 4px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
        }

        input:checked + .slider {
            background-color: var(--success);
        }

        input:checked + .slider:before {
            transform: translateX(26px);
        }

        .switch-label {
            margin-left: 10px;
            font-size: 14px;
            color: var(--secondary);
            vertical-align: middle;
        }

        /* Button Styles */
        .btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 8px 16px;
            border-radius: 5px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            border: none;
        }

        .btn-primary {
            background-color: var(--primary);
            color: var(--white);
        }

        .btn-primary:hover {
            background-color: #4a7de8;
            box-shadow: 0 3px 10px rgba(90, 141, 238, 0.3);
        }

        .btn-outline-primary {
            background-color: transparent;
            color: var(--primary);
            border: 1px solid var(--primary);
        }

        .btn-outline-primary:hover {
            background-color: rgba(90, 141, 238, 0.1);
        }

        .btn-icon {
            margin-right: 5px;
        }

        /* Step Progress */
        .step-progress {
            display: flex;
            justify-content: space-between;
            margin-bottom: 30px;
            position: relative;
        }

        .step-progress::before {
            content: "";
            position: absolute;
            top: 50%;
            left: 0;
            right: 0;
            height: 2px;
            background-color: #eee;
            z-index: 1;
            transform: translateY(-50%);
        }

        .step-progress-bar {
            position: absolute;
            top: 50%;
            left: 0;
            height: 2px;
            background-color: var(--primary);
            z-index: 2;
            transform: translateY(-50%);
            transition: all 0.3s ease;
        }

        .step {
            position: relative;
            z-index: 3;
            text-align: center;
            width: 100%;
        }

        .step-number {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: #eee;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 10px;
            font-weight: 600;
            color: var(--secondary);
            transition: all 0.3s ease;
        }

        .step.active .step-number {
            background-color: var(--primary);
            color: var(--white);
        }

        .step.completed .step-number {
            background-color: var(--success);
            color: var(--white);
        }

        .step-title {
            font-size: 13px;
            color: var(--light);
            font-weight: 500;
        }

        .step.active .step-title {
            color: var(--primary);
        }

        .step.completed .step-title {
            color: var(--success);
        }

        /* Step Content */
        .step-content {
            display: none;
        }

        .step-content.active {
            display: block;
        }

        /* Navigation Buttons */
        .step-actions {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
        }

        /* Variation Styles */
        .variation-item {
            background-color: #f9fafb;
            border-radius: 5px;
            padding: 15px;
            margin-bottom: 15px;
        }

        .variation-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .variation-title {
            font-weight: 600;
            color: var(--dark);
        }

        .remove-variation {
            color: var(--danger);
            cursor: pointer;
        }

         /* Add this to your existing styles */
        .file-upload-wrapper {
            margin-bottom: 20px;
        }
        
        .file-upload-label {
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
            font-weight: 500;
            color: var(--dark);
        }
        
        .file-upload-required:after {
            content: " *";
            color: var(--danger);
        }
        
        .file-upload-box {
            border: 2px dashed #ddd;
            border-radius: 5px;
            padding: 20px;
            text-align: center;
            background-color: #f9fafb;
            transition: all 0.3s ease;
        }
        
        .file-upload-box:hover {
            border-color: var(--primary);
            background-color: rgba(90, 141, 238, 0.05);
        }
        
        .file-upload-icon {
            font-size: 36px;
            color: var(--light);
            margin-bottom: 10px;
        }
        
        .file-upload-text {
            font-size: 14px;
            color: var(--secondary);
            margin-bottom: 5px;
        }
        
        .file-upload-hint {
            font-size: 12px;
            color: var(--light);
        }
        
        .file-input {
            display: none;
        }
        
        .file-name {
            margin-top: 10px;
            font-size: 13px;
            color: var(--secondary);
        }
        
        /* Validation error styles */
        .error-message {
            color: var(--danger);
            font-size: 12px;
            margin-top: 5px;
            display: none;
        }
        
        .has-error .form-control,
        .has-error .file-upload-box {
            border-color: var(--danger);
        }
        
        .has-error .error-message {
            display: block;
        }

        /* Responsive Styles */
        @media (max-width: 992px) {
            .sidebar {
                transform: translateX(-100%);
            }
            .main-content {
                margin-left: 0;
            }
        }
    </style>
  
    <div class="card">
        <div class="card-header" style="background-color:black;">
            <div class="card-title" style="color:white">Add New Product</div>
        </div>
        <div class="card-body">
            <!-- Step Progress -->
            <div class="step-progress">
                <div class="step-progress-bar" style="width: 16.66%;"></div>
                <div class="step active" data-step="1">
                    <div class="step-number">1</div>
                    <div class="step-title">Vital Info</div>
                </div>
                <div class="step" data-step="2">
                    <div class="step-number">2</div>
                    <div class="step-title">Name & Desc</div>
                </div>
                <div class="step" data-step="3">
                    <div class="step-number">3</div>
                    <div class="step-title">Product Info</div>
                </div>
                <div class="step" data-step="4">
                    <div class="step-number">4</div>
                    <div class="step-title">Media</div>
                </div>
                <div class="step" data-step="5">
                    <div class="step-number">5</div>
                    <div class="step-title">Variations</div>
                </div>
                <div class="step" data-step="6">
                    <div class="step-number">6</div>
                    <div class="step-title">Price & Publish</div>
                </div>
            </div>

            <!-- Step 1: Vital Information -->
            <div class="step-content active" data-step="1">
                <div class="form-row">
                    <div class="form-col">
                        <div class="form-group">
                            <label class="form-label">Product Code</label>
                            <asp:TextBox ID="txtProductCode" runat="server" CssClass="form-control" placeholder="ProductID"></asp:TextBox>
                        </div>
                    </div>
                    <div class="form-col">
                        <div class="form-group">
                            <label class="form-label">Category *</label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control" AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged" required>
                                <asp:ListItem Value="0">-- Select Category --</asp:ListItem>
                            </asp:DropDownList>
                            <div class="error-message">Please select a category</div>
                        </div>
                    </div>
                    <div class="form-col">
                        <div class="form-group">
                            <label class="form-label">SubCategory</label>
                            <asp:DropDownList ID="ddlSubCategory" runat="server" CssClass="form-control">
                                <asp:ListItem Value="0">-- Select SubCategory --</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
                

                <div class="form-group">
                    <label class="form-label">Brand *</label>
                    <asp:TextBox ID="txtBrand" runat="server" CssClass="form-control" placeholder="Enter brand name" required></asp:TextBox>
                    <div class="error-message">Please enter a brand name</div>
                </div>

                <div class="form-group">
                    <label class="form-label">Tags</label>
                    <asp:TextBox ID="txtTags" runat="server" CssClass="form-control" placeholder="Add tags separated by commas"></asp:TextBox>
                </div>
            </div>

            <!-- Step 2: Name and Description -->
            <div class="step-content" data-step="2">
                <div class="form-group">
                    <label class="form-label">Product Name *</label>
                    <asp:TextBox ID="txtProductName" runat="server" CssClass="form-control" placeholder="Enter product name" required></asp:TextBox>
                    <div class="error-message">Please enter a product name</div>
                </div>

                <div class="form-group">
                    <label class="form-label">Short Description *</label>
                    <asp:TextBox ID="txtShortDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Brief description that appears in product listings" required></asp:TextBox>
                    <div class="error-message">Please enter a short description</div>
                </div>

                <div class="form-group">
                    <label class="form-label">Full Description *</label>
                    <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="5" placeholder="Detailed product description" required></asp:TextBox>
                    <div class="error-message">Please enter a full description</div>
                </div>
            </div>

            <!-- Step 3: Product Information -->
            <div class="step-content" data-step="3">
                <div class="form-row">
                    <div class="form-col">
                        <div class="form-group">
                            <label class="form-label">SKU *</label>
                            <asp:TextBox ID="txtSKU" runat="server" CssClass="form-control" placeholder="Enter SKU" required></asp:TextBox>
                            <div class="error-message">Please enter a SKU</div>
                        </div>
                    </div>
                    <div class="form-col">
                        <div class="form-group">
                            <label class="form-label">Barcode</label>
                            <asp:TextBox ID="txtBarcode" runat="server" CssClass="form-control" placeholder="Enter barcode"></asp:TextBox>
                        </div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-col">
                        <div class="form-group">
                            <label class="form-label">Weight (kg)</label>
                            <asp:TextBox ID="txtWeight" runat="server" CssClass="form-control" placeholder="Enter weight" TextMode="Number" step="0.01"></asp:TextBox>
                        </div>
                    </div>
                    <div class="form-col">
                        <div class="form-group">
                            <label class="form-label">Dimensions (cm)</label>
                            <div style="display: flex; gap: 10px;">
                                <asp:TextBox ID="txtLength" runat="server" CssClass="form-control" placeholder="Length" TextMode="Number"></asp:TextBox>
                                <asp:TextBox ID="txtWidth" runat="server" CssClass="form-control" placeholder="Width" TextMode="Number"></asp:TextBox>
                                <asp:TextBox ID="txtHeight" runat="server" CssClass="form-control" placeholder="Height" TextMode="Number"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Step 4: Images and Videos - Updated with proper labels and styling -->
            <div class="step-content" data-step="4">
                <div class="form-group">
                    <label class="file-upload-label file-upload-required">Main Product Image</label>
                    <div class="file-upload-wrapper">
                        <div class="file-upload-box" id="mainImageUploadBox">
                            <div class="file-upload-icon">
                                <i class="fas fa-cloud-upload-alt"></i>
                            </div>
                            <div class="file-upload-text">Click to upload main product image</div>
                            <div class="file-upload-hint">Recommended size: 800x800px (JPG, PNG, GIF)</div>
                            <asp:FileUpload ID="fileMainImage" runat="server" CssClass="file-input" onchange="updateFileName(this, 'mainImageFileName')" />
                            <div class="file-name" id="mainImageFileName">No file selected</div>
                        </div>
                        <div class="error-message">Please upload a main product image</div>
                    </div>
                </div>

                <div class="form-group">
                    <label class="file-upload-label">Product Gallery Images</label>
                    <div class="file-upload-wrapper">
                        <div class="file-upload-box" id="galleryImagesUploadBox">
                            <div class="file-upload-icon">
                                <i class="fas fa-cloud-upload-alt"></i>
                            </div>
                            <div class="file-upload-text">Click to upload multiple gallery images</div>
                            <div class="file-upload-hint">Recommended size: 800x800px (JPG, PNG, GIF)</div>
                            <asp:FileUpload ID="fileGalleryImages" runat="server" CssClass="file-input" AllowMultiple="true" onchange="updateFileNames(this, 'galleryImagesFileNames')" />
                            <div class="file-name" id="galleryImagesFileNames">No files selected</div>
                            <asp:Image ID="imgPreview" runat="server" CssClass="image-preview" Visible="false" />
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Product Video URL</label>
                    <asp:TextBox ID="txtVideoUrl" runat="server" CssClass="form-control" placeholder="Enter YouTube or Vimeo URL"></asp:TextBox>
                </div>
            </div>

            <!-- Step 5: Variations -->
            <div class="step-content" data-step="5">
                <div class="form-group">
                    <label class="form-label">Color</label>
                    <asp:TextBox ID="txtColor" runat="server" CssClass="form-control" placeholder="Enter color options (comma separated)"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label class="form-label">Size</label>
                    <asp:TextBox ID="txtSize" runat="server" CssClass="form-control" placeholder="Enter size options (comma separated)"></asp:TextBox>
                </div>
            </div>

            <!-- Step 6: Price and Publish -->
            <div class="step-content" data-step="6">
                <div class="form-row">
                    <div class="form-col">
                        <div class="form-group">
                            <label class="form-label">Price *</label>
                            <asp:TextBox ID="txtPrice" runat="server" CssClass="form-control" placeholder="Enter price" TextMode="Number" step="0.01" required></asp:TextBox>
                            <div class="error-message">Please enter a valid price</div>
                        </div>
                    </div>
                    <div class="form-col">
                        <div class="form-group">
                            <label class="form-label">Compare at Price</label>
                            <asp:TextBox ID="txtCompareAtPrice" runat="server" CssClass="form-control" placeholder="Original price for discount" TextMode="Number" step="0.01"></asp:TextBox>
                        </div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-col">
                        <div class="form-group">
                            <label class="form-label">Cost per item</label>
                            <asp:TextBox ID="txtCostPerItem" runat="server" CssClass="form-control" placeholder="Product cost for profit calculation" TextMode="Number" step="0.01"></asp:TextBox>
                        </div>
                    </div>
                    <div class="form-col">
                        <div class="form-group">
                            <label class="form-label">Tax Class</label>
                            <asp:DropDownList ID="ddlTaxClass" runat="server" CssClass="form-control">
                                <asp:ListItem Value="">Default tax class</asp:ListItem>
                                <asp:ListItem Value="taxable">Taxable goods</asp:ListItem>
                                <asp:ListItem Value="non-taxable">Non-taxable goods</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-col">
                        <div class="form-group">
                            <label class="form-label">Stock Quantity *</label>
                            <asp:TextBox ID="txtQuantity" runat="server" CssClass="form-control" placeholder="Enter quantity" TextMode="Number" required></asp:TextBox>
                            <div class="error-message">Please enter a valid quantity</div>
                        </div>
                    </div>
                    <div class="form-col">
                        <div class="form-group">
                            <label class="form-label">Stock Status</label>
                            <asp:DropDownList ID="ddlStockStatus" runat="server" CssClass="form-control">
                                <asp:ListItem Value="in_stock">In Stock</asp:ListItem>
                                <asp:ListItem Value="out_of_stock">Out of Stock</asp:ListItem>
                                <asp:ListItem Value="on_backorder">On Backorder</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label class="form-label">Publish Status</label>
                    <div>
                        <label class="form-switch">
                            <asp:CheckBox ID="cbPublishStatus" runat="server" Checked="true" />
                            <span class="slider"></span>
                        </label>
                        <span class="switch-label">Published</span>
                    </div>
                </div>
            </div>

            <!-- Navigation Buttons -->
            <div class="step-actions">
                <button type="button" class="btn btn-outline-primary prev-step" disabled>
                    <i class="fas fa-arrow-left btn-icon"></i>
                    Previous
                </button>
                <button type="button" class="btn btn-primary next-step">
                    Next
                    <i class="fas fa-arrow-right btn-icon"></i>
                </button>
                <asp:Button ID="btnPublishProduct" runat="server" CssClass="btn btn-success publish-product" 
                    Text="Publish Product" OnClick="btnPublishProduct_Click" style="display: none;" />
            </div>
        </div>
    </div>
</asp:Content>