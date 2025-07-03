
<%--




<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Next_ae.Admin.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- Aurora Theme CSS -->
    <link href="../assets/css/aurora.css" rel="stylesheet" />
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <!-- Feather Icons -->
    <script src="https://cdn.jsdelivr.net/npm/feather-icons/dist/feather.min.js"></script>
    
    <style>
        /* Custom styles to match Aurora theme */
        :root {
            --primary: #5e72e4;
            --secondary: #f7fafc;
            --success: #2dce89;
            --info: #11cdef;
            --warning: #fb6340;
            --danger: #f5365c;
            --light: #f8f9fa;
            --dark: #212529;
        }

        .timeline {
            position: relative;
            padding-left: 1.5rem;
        }
        
        .timeline:before {
            content: '';
            position: absolute;
            left: 0.5rem;
            top: 0;
            bottom: 0;
            width: 2px;
            background: #e9ecef;
        }
        
        .timeline-item {
            position: relative;
            padding-bottom: 1.5rem;
        }
        
        .timeline-item:last-child {
            padding-bottom: 0;
        }
        
        .timeline-badge {
            position: absolute;
            left: -1.5rem;
            width: 2.5rem;
            height: 2.5rem;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1rem;
        }
        
        .activity-time {
            font-size: 0.75rem;
            color: #6c757d;
        }
        
        .activity-details {
            margin-left: 0.5rem;
        }

         .product-img {
            width: 40px;
            height: 40px;
            object-fit: cover;
            border-radius: 50%;
        }
        
        .visitor-ip {
            font-family: monospace;
        }
        
        .visitor-time {
            font-size: 0.8rem;
            color: #6c757d;
        }
        
        .card {
            border: none;
            border-radius: 0.375rem;
            box-shadow: 0 0 2rem 0 rgba(136, 152, 170, 0.15);
            margin-bottom: 30px;
            transition: all 0.3s ease;
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 0 2rem 0 rgba(136, 152, 170, 0.3);
        }
        
        .card-header {
            background-color: transparent;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
        }
        
        .bg-gradient-primary {
            background: linear-gradient(87deg, #5e72e4 0, #825ee4 100%) !important;
        }
        
        .bg-gradient-success {
            background: linear-gradient(87deg, #2dce89 0, #2dcecc 100%) !important;
        }
        
        .bg-gradient-info {
            background: linear-gradient(87deg, #11cdef 0, #1171ef 100%) !important;
        }
        
        .bg-gradient-warning {
            background: linear-gradient(87deg, #fb6340 0, #fbb140 100%) !important;
        }
        
        .icon-shape {
            width: 48px;
            height: 48px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
        }
        
        .table-responsive {
            overflow-x: auto;
        }
    </style>
    
    <script type="text/javascript">
        function initializeCharts() {
            // Sales chart
            var salesData = JSON.parse(document.getElementById('<%= hdnSalesData.ClientID %>').value);
            var salesLabels = salesData.map(item => item.Day);
            var salesValues = salesData.map(item => item.Sales);

            var salesCtx = document.getElementById('salesChart').getContext('2d');
            var salesChart = new Chart(salesCtx, {
                type: 'line',
                data: {
                    labels: salesLabels,
                    datasets: [{
                        label: 'Daily Sales',
                        data: salesValues,
                        backgroundColor: 'rgba(94, 114, 228, 0.1)',
                        borderColor: '#5e72e4',
                        borderWidth: 2,
                        pointBackgroundColor: '#fff',
                        pointBorderColor: '#5e72e4',
                        pointHoverRadius: 5,
                        pointHoverBackgroundColor: '#5e72e4',
                        pointHoverBorderColor: '#fff',
                        pointHitRadius: 10,
                        pointBorderWidth: 2,
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    return 'Rs. ' + context.raw.toLocaleString('en-PK');
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function (value) {
                                    return 'Rs. ' + value.toLocaleString('en-PK');
                                }
                            },
                            grid: {
                                drawBorder: false,
                                color: 'rgba(0, 0, 0, 0.05)'
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            }
                        }
                    }
                }
            });

            // Category sales chart
            var categoryData = JSON.parse(document.getElementById('<%= hdnCategoryData.ClientID %>').value);
            var categoryLabels = [];
            var categoryValues = [];
            var backgroundColors = [
                '#5e72e4',
                '#2dce89',
                '#fb6340',
                '#11cdef',
                '#f5365c'
            ];

            for (var i = 0; i < categoryData.length; i++) {
                categoryLabels.push(categoryData[i].CategoryName);
                categoryValues.push(categoryData[i].CategorySales);
            }

            var categoryCtx = document.getElementById('categoryChart').getContext('2d');
            var categoryChart = new Chart(categoryCtx, {
                type: 'doughnut',
                data: {
                    labels: categoryLabels,
                    datasets: [{
                        data: categoryValues,
                        backgroundColor: backgroundColors,
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '70%',
                    plugins: {
                        legend: {
                            position: 'right',
                            labels: {
                                usePointStyle: true,
                                padding: 20
                            }
                        },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    return 'Rs. ' + context.raw.toLocaleString('en-PK');
                                }
                            }
                        }
                    }
                }
            });

            // Visitor activities chart
            var visitorData = JSON.parse(document.getElementById('<%= hdnVisitorData.ClientID %>').value);
            var visitorLabels = visitorData.map(item => item.Day);
            var visitorValues = visitorData.map(item => item.Count);

            var visitorCtx = document.getElementById('visitorChart').getContext('2d');
            var visitorChart = new Chart(visitorCtx, {
                type: 'bar',
                data: {
                    labels: visitorLabels,
                    datasets: [{
                        label: 'Visitors',
                        data: visitorValues,
                        backgroundColor: '#5e72e4',
                        borderWidth: 0,
                        borderRadius: 4
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                drawBorder: false,
                                color: 'rgba(0, 0, 0, 0.05)'
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            }
                        }
                    }
                }
            });

            feather.replace();
        }


        // Initialize charts when page loads
        document.addEventListener('DOMContentLoaded', initializeCharts);
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:HiddenField ID="hdnSalesData" runat="server" />
    <asp:HiddenField ID="hdnCategoryData" runat="server" />
      <asp:HiddenField ID="HiddenField1" runat="server" />
    <asp:HiddenField ID="HiddenField2" runat="server" />
    <asp:HiddenField ID="hdnVisitorData" runat="server" />

    <!-- Header -->
    <div class="header bg-primary pb-6">
        <div class="container-fluid">
            <div class="header-body">
                <div class="row align-items-center py-4">
                    <div class="col-lg-6 col-7">
                        <h6 class="h2 text-white d-inline-block mb-0">Dashboard</h6>
                        <nav aria-label="breadcrumb" class="d-none d-md-inline-block ml-md-4">
                            <ol class="breadcrumb breadcrumb-links breadcrumb-dark">
                                <li class="breadcrumb-item"><a href="#"><i data-feather="home"></i></a></li>
                                <li class="breadcrumb-item active" aria-current="page">Dashboard</li>
                            </ol>
                        </nav>
                    </div>
                    <div class="col-lg-6 col-5 text-right">
                        <a href="Reports.aspx" class="btn btn-sm btn-neutral">
                            <i data-feather="download" class="mr-2"></i>Generate Report
                        </a>
                    </div>
                </div>
                
                <!-- Cards -->
                <div class="row">
                    <div class="col-xl-3 col-md-6">
                        <div class="card card-stats">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col">
                                        <h5 class="card-title text-uppercase text-muted mb-0">Total Revenue</h5>
                                        <span class="h2 font-weight-bold mb-0">
                                            <asp:Label ID="lblTotalRevenue" runat="server" Text="Rs.0"></asp:Label>
                                        </span>
                                    </div>
                                    <div class="col-auto">
                                        <div class="icon icon-shape bg-gradient-red text-white rounded-circle shadow">
                                            <i data-feather="dollar-sign"></i>
                                        </div>
                                    </div>
                                </div>
                                <p class="mt-3 mb-0 text-sm">
                                    <span class="text-success mr-2"><i class="fa fa-arrow-up"></i> 3.48%</span>
                                    <span class="text-nowrap">Since last month</span>
                                </p>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6">
                        <div class="card card-stats">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col">
                                        <h5 class="card-title text-uppercase text-muted mb-0">New Users</h5>
                                        <span class="h2 font-weight-bold mb-0">
                                            <asp:Label ID="lblNewCustomers" runat="server" Text="0"></asp:Label>
                                        </span>
                                    </div>
                                    <div class="col-auto">
                                        <div class="icon icon-shape bg-gradient-orange text-white rounded-circle shadow">
                                            <i data-feather="users"></i>
                                        </div>
                                    </div>
                                </div>
                                <p class="mt-3 mb-0 text-sm">
                                    <span class="text-success mr-2"><i class="fa fa-arrow-up"></i> 12.5%</span>
                                    <span class="text-nowrap">Since last month</span>
                                </p>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6">
                        <div class="card card-stats">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col">
                                        <h5 class="card-title text-uppercase text-muted mb-0">Sales</h5>
                                        <span class="h2 font-weight-bold mb-0">
                                            <asp:Label ID="lblNewOrders" runat="server" Text="0"></asp:Label>
                                        </span>
                                    </div>
                                    <div class="col-auto">
                                        <div class="icon icon-shape bg-gradient-green text-white rounded-circle shadow">
                                            <i data-feather="shopping-cart"></i>
                                        </div>
                                    </div>
                                </div>
                                <p class="mt-3 mb-0 text-sm">
                                    <span class="text-success mr-2"><i class="fa fa-arrow-up"></i> 8.2%</span>
                                    <span class="text-nowrap">Since last month</span>
                                </p>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6">
                        <div class="card card-stats">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col">
                                        <h5 class="card-title text-uppercase text-muted mb-0">Products</h5>
                                        <span class="h2 font-weight-bold mb-0">
                                            <asp:Label ID="lblTotalProducts" runat="server" Text="0"></asp:Label>
                                        </span>
                                    </div>
                                    <div class="col-auto">
                                        <div class="icon icon-shape bg-gradient-info text-white rounded-circle shadow">
                                            <i data-feather="box"></i>
                                        </div>
                                    </div>
                                </div>
                                <p class="mt-3 mb-0 text-sm">
                                    <span class="text-success mr-2"><i class="fa fa-arrow-up"></i> 5.3%</span>
                                    <span class="text-nowrap">Since last month</span>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Page content -->
    <div class="container-fluid mt--6">
        <div class="row">
            <div class="col-xl-8">
                <div class="card">
                    <div class="card-header border-0">
                        <div class="row align-items-center">
                            <div class="col">
                                <h3 class="mb-0">Sales Overview</h3>
                            </div>
                            <div class="col text-right">
                                <a href="Reports.aspx" class="btn btn-sm btn-primary">See all</a>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="chart">
                            <canvas id="salesChart" height="350"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4">
                <div class="card">
                    <div class="card-header border-0">
                        <div class="row align-items-center">
                            <div class="col">
                                <h3 class="mb-0">Revenue Sources</h3>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="chart">
                            <canvas id="categoryChart" height="350"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-xl-6">
                <div class="card">
                    <div class="card-header border-0">
                        <div class="row align-items-center">
                            <div class="col">
                                <h3 class="mb-0">Recent Orders</h3>
                            </div>
                            <div class="col text-right">
                                <a href="Orders.aspx" class="btn btn-sm btn-primary">View all</a>
                            </div>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="table align-items-center table-flush">
                            <thead class="thead-light">
                                <tr>
                                    <th scope="col">Order #</th>
                                    <th scope="col">Customer</th>
                                    <th scope="col">Amount</th>
                                    <th scope="col">Status</th>
                                    <th scope="col"></th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptRecentOrders" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <th scope="row">
                                                <%# Eval("OrderID") %>
                                            </th>
                                            <td>
                                                <%# Eval("CustomerName") %>
                                            </td>
                                            <td>
                                                <%# FormatRupees(Convert.ToDecimal(Eval("TotalAmount"))) %>
                                            </td>
                                            <td>
                                                <span class='badge badge-dot mr-4'>
                                                    <i class='<%# GetStatusBadgeClass(Eval("Status").ToString()) %>'></i>
                                                    <%# Eval("Status") %>
                                                </span>
                                            </td>
                                            <td class="text-right">
                                                <div class="dropdown">
                                                    <a class="btn btn-sm btn-icon-only text-light" href="#" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                                        <i class="fas fa-ellipsis-v"></i>
                                                    </a>
                                                    <div class="dropdown-menu dropdown-menu-right dropdown-menu-arrow">
                                                        <a class="dropdown-item" href='Orders.aspx?orderId=<%# Eval("OrderID") %>'>View Details</a>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-xl-6">
                <div class="card">
                    <div class="card-header border-0">
                        <div class="row align-items-center">
                            <div class="col">
                                <h3 class="mb-0">Visitor Activities</h3>
                            </div>
                            <div class="col text-right">
                                <a href="Reports.aspx" class="btn btn-sm btn-primary">See all</a>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="chart">
                            <canvas id="visitorChart" height="350"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
         <div class="col-xl-8">
        <div class="card">
            <div class="card-header border-0">
                <div class="row align-items-center">
                    <div class="col">
                        <h3 class="mb-0">Top Selling Products</h3>
                    </div>
                    <div class="col text-right">
                        <a href="Products.aspx" class="btn btn-sm btn-primary">See all</a>
                    </div>
                </div>
            </div>
            <div class="table-responsive">
                <table class="table align-items-center table-flush">
                    <thead class="thead-light">
                        <tr>
                            <th scope="col">Product</th>
                            <th scope="col">Category</th>
                            <th scope="col">Sold</th>
                            <th scope="col">Revenue</th>
                            <th scope="col"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptTopProducts" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <th scope="row">
                                        <div class="media align-items-center">
                                            <a href="#" class="avatar rounded-circle mr-3">
                                                <img class="product-img" alt='<%# Eval("ProductName") %>' src='<%# GetProductImageUrl(Eval("ImageURL")) %>'>
                                            </a>
                                            <div class="media-body">
                                                <span class="mb-0 text-sm"><%# Eval("ProductName") %></span>
                                            </div>
                                        </div>
                                    </th>
                                    <td>
                                        <%# Eval("CategoryName") %>
                                    </td>
                                    <td>
                                        <%# Eval("TotalSold") %>
                                    </td>
                                    <td>
                                        <%# FormatRupees(Convert.ToDecimal(Eval("TotalRevenue"))) %>
                                    </td>
                                    <td class="text-right">
                                        <div class="dropdown">
                                            <a class="btn btn-sm btn-icon-only text-light" href="#" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                                <i class="fas fa-ellipsis-v"></i>
                                            </a>
                                            <div class="dropdown-menu dropdown-menu-right dropdown-menu-arrow">
                                                <a class="dropdown-item" href='Products.aspx?productId=<%# Eval("ProductID") %>'>View Details</a>
                                            </div>
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
      <div class="col-xl-4">
        <div class="card">
            <div class="card-header border-0">
                <div class="row align-items-center">
                    <div class="col">
                        <h3 class="mb-0">Recent Visitors</h3>
                    </div>
                    <div class="col text-right">
                        <a href="Reports.aspx" class="btn btn-sm btn-primary">See all</a>
                    </div>
                </div>
            </div>
            <div class="table-responsive">
                <table class="table align-items-center table-flush">
                    <thead class="thead-light">
                        <tr>
                            <th scope="col">IP Address</th>
                            <th scope="col">Page</th>
                            <th scope="col">Time</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptRecentVisitors" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td class="visitor-ip">
                                        <%# Eval("IPAddress") %>
                                    </td>
                                    <td>
                                        <%# Eval("PageVisited") %>
                                    </td>
                                    <td class="visitor-time">
                                        <%# FormatVisitorTime(Convert.ToDateTime(Eval("VisitTime"))) %>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="row mt-4">
        <div class="col-xl-8">
            <!-- Top Selling Products (keep existing) -->
        </div>
        
        <div class="col-xl-4">
            <div class="card">
                <div class="card-header border-0">
                    <div class="row align-items-center">
                        <div class="col">
                            <h3 class="mb-0">Recent Activities</h3>
                        </div>
                        <div class="col text-right">
                            <a href="ActivityLog.aspx" class="btn btn-sm btn-primary">View All</a>
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <div class="timeline">
                        <asp:Repeater ID="rptAdminActivities" runat="server">
                            <ItemTemplate>
                                <div class="timeline-item">
                                    <div class="timeline-badge bg-<%# GetActivityColor(Eval("ActivityType").ToString()) %>">
                                        <i data-feather="<%# GetActivityIcon(Eval("ActivityType").ToString(), Eval("EntityType").ToString()) %>"></i>
                                    </div>
                                    <div class="activity-details">
                                        <div class="d-flex justify-content-between">
                                            <h6 class="mb-0"><%# Eval("Username") %></h6>
                                            <span class="activity-time"><%# FormatVisitorTime(Convert.ToDateTime(Eval("ActivityDate"))) %></span>
                                        </div>
                                        <p class="mb-0 text-sm">
                                            <span class="text-capitalize"><%# Eval("ActivityType") %></span> 
                                            <%# Eval("EntityType") %> - 
                                            <%# FormatActivityDescription(Eval("Description"), Eval("EntityType"), Eval("EntityID")) %>
                                        </p>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </div>
        </div>
    </div>
  </div>
    </div>
</asp:Content>










--%>










<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Admin/Admin.Master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="Next_ae.Admin.Dashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- Aurora Theme CSS -->
    <link href="../assets/css/aurora.css" rel="stylesheet" />
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <!-- Feather Icons -->
    <script src="https://cdn.jsdelivr.net/npm/feather-icons/dist/feather.min.js"></script>
    
    <style>
        /* Custom styles to match Aurora theme */
        :root {
            --primary: #5e72e4;
            --secondary: #f7fafc;
            --success: #2dce89;
            --info: #11cdef;
            --warning: #fb6340;
            --danger: #f5365c;
            --light: #f8f9fa;
            --dark: #212529;
        }

        .timeline {
            position: relative;
            padding-left: 1.5rem;
        }
        
        .timeline:before {
            content: '';
            position: absolute;
            left: 0.5rem;
            top: 0;
            bottom: 0;
            width: 2px;
            background: #e9ecef;
        }
        
        .timeline-item {
            position: relative;
            padding-bottom: 1.5rem;
        }
        
        .timeline-item:last-child {
            padding-bottom: 0;
        }
        
        .timeline-badge {
            position: absolute;
            left: -1.5rem;
            width: 2.5rem;
            height: 2.5rem;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 1rem;
        }
        
        .activity-time {
            font-size: 0.75rem;
            color: #6c757d;
        }
        
        .activity-details {
            margin-left: 0.5rem;
        }

        .product-img {
            width: 40px;
            height: 40px;
            object-fit: cover;
            border-radius: 50%;
        }
        
        .visitor-ip {
            font-family: monospace;
            font-size: 0.8rem;
        }
        
        .visitor-time {
            font-size: 0.75rem;
            color: #6c757d;
            white-space: nowrap;
        }
        
        .card {
            border: none;
            border-radius: 0.5rem;
            box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
            margin-bottom: 24px;
            transition: all 0.3s ease;
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        
        .card:hover {
            transform: translateY(-5px);
            box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
        }
        
        .card-header {
            background-color: transparent;
            border-bottom: 1px solid rgba(0, 0, 0, 0.05);
            padding: 1rem 1.25rem;
        }
        
        .card-body {
            flex: 1;
            padding: 1.25rem;
        }
        
        .bg-gradient-primary {
            background: linear-gradient(87deg, #5e72e4 0, #825ee4 100%) !important;
        }
        
        .bg-gradient-success {
            background: linear-gradient(87deg, #2dce89 0, #2dcecc 100%) !important;
        }
        
        .bg-gradient-info {
            background: linear-gradient(87deg, #11cdef 0, #1171ef 100%) !important;
        }
        
        .bg-gradient-warning {
            background: linear-gradient(87deg, #fb6340 0, #fbb140 100%) !important;
        }
        
        .icon-shape {
            width: 48px;
            height: 48px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
        }
        
        .table-responsive {
            overflow-x: auto;
        }
        
        .chart-container {
            position: relative;
            height: 300px;
            min-height: 300px;
        }
        
        .stats-card .card-body {
            padding: 1rem;
        }
        
        .stats-card h5 {
            font-size: 0.8125rem;
            letter-spacing: 0.5px;
            text-transform: uppercase;
            color: #adb5bd;
            margin-bottom: 0.5rem;
        }
        
        .stats-card .h2 {
            font-weight: 600;
            margin-bottom: 0.5rem;
        }
        
        .stats-card .text-sm {
            font-size: 0.75rem;
        }
        
        /* Fixed height for visitor table */
        .visitor-table-container {
            max-height: 300px;
            overflow-y: auto;
        }
        
        /* Custom scrollbar */
        .visitor-table-container::-webkit-scrollbar {
            width: 6px;
        }
        
        .visitor-table-container::-webkit-scrollbar-track {
            background: #f1f1f1;
            border-radius: 3px;
        }
        
        .visitor-table-container::-webkit-scrollbar-thumb {
            background: #c1c1c1;
            border-radius: 3px;
        }
        
        .visitor-table-container::-webkit-scrollbar-thumb:hover {
            background: #a8a8a8;
        }
        
        /* Responsive adjustments */
        @media (max-width: 1200px) {
            .chart-container {
                height: 250px;
            }
        }
        
        @media (max-width: 992px) {
            .card-body {
                padding: 1rem;
            }
        }
        
        /* Badge styles */
        .badge-dot {
            padding-left: 0;
            padding-right: 0;
            background: transparent;
            font-weight: 400;
            font-size: 0.8125rem;
        }
        
        .badge-dot i {
            display: inline-block;
            width: 0.375rem;
            height: 0.375rem;
            border-radius: 50%;
            margin-right: 0.375rem;
        }
        
        /* Table styles */
        .table {
            width: 100%;
            margin-bottom: 0;
        }
        
        .table thead th {
            border-top: none;
            border-bottom: 1px solid #e9ecef;
            font-size: 0.75rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            font-weight: 600;
            color: #adb5bd;
            padding: 0.75rem 1.5rem;
        }
        
        .table tbody td {
            padding: 1rem 1.5rem;
            vertical-align: middle;
            border-top: 1px solid #e9ecef;
        }
        
        .table tbody tr:first-child td {
            border-top: none;
        }
    </style>
    
    <script type="text/javascript">
        function initializeCharts() {
            // Sales chart
            var salesData = JSON.parse(document.getElementById('<%= hdnSalesData.ClientID %>').value);
            var salesLabels = salesData.map(item => item.Day);
            var salesValues = salesData.map(item => item.Sales);

            var salesCtx = document.getElementById('salesChart').getContext('2d');
            var salesChart = new Chart(salesCtx, {
                type: 'line',
                data: {
                    labels: salesLabels,
                    datasets: [{
                        label: 'Daily Sales',
                        data: salesValues,
                        backgroundColor: 'rgba(94, 114, 228, 0.1)',
                        borderColor: '#5e72e4',
                        borderWidth: 2,
                        pointBackgroundColor: '#fff',
                        pointBorderColor: '#5e72e4',
                        pointHoverRadius: 5,
                        pointHoverBackgroundColor: '#5e72e4',
                        pointHoverBorderColor: '#fff',
                        pointHitRadius: 10,
                        pointBorderWidth: 2,
                        tension: 0.4,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    return 'Rs. ' + context.raw.toLocaleString('en-PK');
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                callback: function (value) {
                                    return 'Rs. ' + value.toLocaleString('en-PK');
                                }
                            },
                            grid: {
                                drawBorder: false,
                                color: 'rgba(0, 0, 0, 0.05)'
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            }
                        }
                    }
                }
            });

            // Category sales chart
            var categoryData = JSON.parse(document.getElementById('<%= hdnCategoryData.ClientID %>').value);
            var categoryLabels = [];
            var categoryValues = [];
            var backgroundColors = [
                '#5e72e4',
                '#2dce89',
                '#fb6340',
                '#11cdef',
                '#f5365c',
                '#8898aa',
                '#2d3748',
                '#f6ad55'
            ];

            for (var i = 0; i < categoryData.length; i++) {
                categoryLabels.push(categoryData[i].CategoryName);
                categoryValues.push(categoryData[i].CategorySales);
            }

            var categoryCtx = document.getElementById('categoryChart').getContext('2d');
            var categoryChart = new Chart(categoryCtx, {
                type: 'doughnut',
                data: {
                    labels: categoryLabels,
                    datasets: [{
                        data: categoryValues,
                        backgroundColor: backgroundColors,
                        borderWidth: 0,
                        hoverOffset: 10
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    cutout: '75%',
                    plugins: {
                        legend: {
                            position: 'right',
                            labels: {
                                usePointStyle: true,
                                padding: 20,
                                font: {
                                    size: 12
                                },
                                boxWidth: 10
                            }
                        },
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    var label = context.label || '';
                                    var value = context.raw || 0;
                                    var total = context.dataset.data.reduce((a, b) => a + b, 0);
                                    var percentage = Math.round((value / total) * 100);
                                    return `${label}: Rs. ${value.toLocaleString('en-PK')} (${percentage}%)`;
                                }
                            }
                        }
                    }
                }
            });

            // Visitor activities chart
            var visitorData = JSON.parse(document.getElementById('<%= hdnVisitorData.ClientID %>').value);
            var visitorLabels = visitorData.map(item => item.Day);
            var visitorValues = visitorData.map(item => item.Count);

            var visitorCtx = document.getElementById('visitorChart').getContext('2d');
            var visitorChart = new Chart(visitorCtx, {
                type: 'bar',
                data: {
                    labels: visitorLabels,
                    datasets: [{
                        label: 'Visitors',
                        data: visitorValues,
                        backgroundColor: '#5e72e4',
                        borderWidth: 0,
                        borderRadius: 4,
                        barThickness: 'flex',
                        maxBarThickness: 20
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: {
                                drawBorder: false,
                                color: 'rgba(0, 0, 0, 0.05)'
                            },
                            ticks: {
                                precision: 0
                            }
                        },
                        x: {
                            grid: {
                                display: false
                            }
                        }
                    }
                }
            });

            feather.replace();
        }

        // Initialize charts when page loads
        document.addEventListener('DOMContentLoaded', initializeCharts);
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:HiddenField ID="hdnSalesData" runat="server" />
    <asp:HiddenField ID="hdnCategoryData" runat="server" />
    <asp:HiddenField ID="hdnVisitorData" runat="server" />

    <!-- Header -->
    <div class="header bg-primary pb-6">
        <div class="container-fluid">
            <div class="header-body">
                <div class="row align-items-center py-4">
                    <div class="col-lg-6 col-7">
                        <h6 class="h2 text-white d-inline-block mb-0">Dashboard</h6>
                        <nav aria-label="breadcrumb" class="d-none d-md-inline-block ml-md-4">
                            <ol class="breadcrumb breadcrumb-links breadcrumb-dark">
                                <li class="breadcrumb-item"><a href="#"><i data-feather="home"></i></a></li>
                                <li class="breadcrumb-item active" aria-current="page">Dashboard</li>
                            </ol>
                        </nav>
                    </div>
                    <div class="col-lg-6 col-5 text-right">
                        <a href="Reports.aspx" class="btn btn-sm btn-neutral">
                            <i data-feather="download" class="mr-2"></i>Generate Report
                        </a>
                    </div>
                </div>
                
                <!-- Cards -->
                <div class="row">
                    <div class="col-xl-3 col-md-6">
                        <div class="card card-stats">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col">
                                        <h5 class="card-title text-uppercase text-muted mb-0">Total Revenue</h5>
                                        <span class="h2 font-weight-bold mb-0">
                                            <asp:Label ID="lblTotalRevenue" runat="server" Text="Rs.0"></asp:Label>
                                        </span>
                                    </div>
                                    <div class="col-auto">
                                        <div class="icon icon-shape bg-gradient-red text-white rounded-circle shadow">
                                            <i data-feather="dollar-sign"></i>
                                        </div>
                                    </div>
                                </div>
                                <p class="mt-3 mb-0 text-sm">
                                    <span class="text-success mr-2"><i class="fa fa-arrow-up"></i> 3.48%</span>
                                    <span class="text-nowrap">Since last month</span>
                                </p>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6">
                        <div class="card card-stats">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col">
                                        <h5 class="card-title text-uppercase text-muted mb-0">New Users</h5>
                                        <span class="h2 font-weight-bold mb-0">
                                            <asp:Label ID="lblNewCustomers" runat="server" Text="0"></asp:Label>
                                        </span>
                                    </div>
                                    <div class="col-auto">
                                        <div class="icon icon-shape bg-gradient-orange text-white rounded-circle shadow">
                                            <i data-feather="users"></i>
                                        </div>
                                    </div>
                                </div>
                                <p class="mt-3 mb-0 text-sm">
                                    <span class="text-success mr-2"><i class="fa fa-arrow-up"></i> 12.5%</span>
                                    <span class="text-nowrap">Since last month</span>
                                </p>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6">
                        <div class="card card-stats">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col">
                                        <h5 class="card-title text-uppercase text-muted mb-0">Sales</h5>
                                        <span class="h2 font-weight-bold mb-0">
                                            <asp:Label ID="lblNewOrders" runat="server" Text="0"></asp:Label>
                                        </span>
                                    </div>
                                    <div class="col-auto">
                                        <div class="icon icon-shape bg-gradient-green text-white rounded-circle shadow">
                                            <i data-feather="shopping-cart"></i>
                                        </div>
                                    </div>
                                </div>
                                <p class="mt-3 mb-0 text-sm">
                                    <span class="text-success mr-2"><i class="fa fa-arrow-up"></i> 8.2%</span>
                                    <span class="text-nowrap">Since last month</span>
                                </p>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6">
                        <div class="card card-stats">
                            <div class="card-body">
                                <div class="row">
                                    <div class="col">
                                        <h5 class="card-title text-uppercase text-muted mb-0">Products</h5>
                                        <span class="h2 font-weight-bold mb-0">
                                            <asp:Label ID="lblTotalProducts" runat="server" Text="0"></asp:Label>
                                        </span>
                                    </div>
                                    <div class="col-auto">
                                        <div class="icon icon-shape bg-gradient-info text-white rounded-circle shadow">
                                            <i data-feather="box"></i>
                                        </div>
                                    </div>
                                </div>
                                <p class="mt-3 mb-0 text-sm">
                                    <span class="text-success mr-2"><i class="fa fa-arrow-up"></i> 5.3%</span>
                                    <span class="text-nowrap">Since last month</span>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Page content -->
    <div class="container-fluid mt--6">
        <div class="row">
            <div class="col-xl-8">
                <div class="card">
                    <div class="card-header border-0">
                        <div class="row align-items-center">
                            <div class="col">
                                <h3 class="mb-0">Sales Overview</h3>
                            </div>
                            <div class="col text-right">
                                <a href="Reports.aspx" class="btn btn-sm btn-primary">See all</a>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="salesChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4">
                <div class="card">
                    <div class="card-header border-0">
                        <div class="row align-items-center">
                            <div class="col">
                                <h3 class="mb-0">Revenue Sources</h3>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="categoryChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-xl-6">
                <div class="card">
                    <div class="card-header border-0">
                        <div class="row align-items-center">
                            <div class="col">
                                <h3 class="mb-0">Recent Orders</h3>
                            </div>
                            <div class="col text-right">
                                <a href="Orders.aspx" class="btn btn-sm btn-primary">View all</a>
                            </div>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="table align-items-center table-flush">
                            <thead class="thead-light">
                                <tr>
                                    <th scope="col">Order #</th>
                                    <th scope="col">Customer</th>
                                    <th scope="col">Amount</th>
                                    <th scope="col">Status</th>
                                    <th scope="col"></th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptRecentOrders" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <th scope="row">
                                                <%# Eval("OrderID") %>
                                            </th>
                                            <td>
                                                <%# Eval("CustomerName") %>
                                            </td>
                                            <td>
                                                <%# FormatRupees(Convert.ToDecimal(Eval("TotalAmount"))) %>
                                            </td>
                                            <td>
                                                <span class='badge badge-dot mr-4'>
                                                    <i class='<%# GetStatusBadgeClass(Eval("Status").ToString()) %>'></i>
                                                    <%# Eval("Status") %>
                                                </span>
                                            </td>
                                            <td class="text-right">
                                                <div class="dropdown">
                                                    <a class="btn btn-sm btn-icon-only text-light" href="#" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                                        <i class="fas fa-ellipsis-v"></i>
                                                    </a>
                                                    <div class="dropdown-menu dropdown-menu-right dropdown-menu-arrow">
                                                        <a class="dropdown-item" href='Orders.aspx?orderId=<%# Eval("OrderID") %>'>View Details</a>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-xl-6">
                <div class="card">
                    <div class="card-header border-0">
                        <div class="row align-items-center">
                            <div class="col">
                                <h3 class="mb-0">Visitor Activities</h3>
                            </div>
                            <div class="col text-right">
                                <a href="Reports.aspx" class="btn btn-sm btn-primary">See all</a>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="chart-container">
                            <canvas id="visitorChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="row">
            <div class="col-xl-8">
                <div class="card">
                    <div class="card-header border-0">
                        <div class="row align-items-center">
                            <div class="col">
                                <h3 class="mb-0">Top Selling Products</h3>
                            </div>
                            <div class="col text-right">
                                <a href="Products.aspx" class="btn btn-sm btn-primary">See all</a>
                            </div>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="table align-items-center table-flush">
                            <thead class="thead-light">
                                <tr>
                                    <th scope="col">Product</th>
                                    <th scope="col">Category</th>
                                    <th scope="col">Sold</th>
                                    <th scope="col">Revenue</th>
                                    <th scope="col"></th>
                                </tr>
                            </thead>
                            <tbody>
                                <asp:Repeater ID="rptTopProducts" runat="server">
                                    <ItemTemplate>
                                        <tr>
                                            <th scope="row">
                                                <div class="media align-items-center">
                                                    <a href="#" class="avatar rounded-circle mr-3">
                                                        <img class="product-img" alt='<%# Eval("ProductName") %>' src='<%# GetProductImageUrl(Eval("ImageURL")) %>'>
                                                    </a>
                                                    <div class="media-body">
                                                        <span class="mb-0 text-sm"><%# Eval("ProductName") %></span>
                                                    </div>
                                                </div>
                                            </th>
                                            <td>
                                                <%# Eval("CategoryName") %>
                                            </td>
                                            <td>
                                                <%# Eval("TotalSold") %>
                                            </td>
                                            <td>
                                                <%# FormatRupees(Convert.ToDecimal(Eval("TotalRevenue"))) %>
                                            </td>
                                            <td class="text-right">
                                                <div class="dropdown">
                                                    <a class="btn btn-sm btn-icon-only text-light" href="#" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                                        <i class="fas fa-ellipsis-v"></i>
                                                    </a>
                                                    <div class="dropdown-menu dropdown-menu-right dropdown-menu-arrow">
                                                        <a class="dropdown-item" href='Products.aspx?productId=<%# Eval("ProductID") %>'>View Details</a>
                                                    </div>
                                                </div>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="col-xl-4">
                <div class="card">
                    <div class="card-header border-0">
                        <div class="row align-items-center">
                            <div class="col">
                                <h3 class="mb-0">Recent Visitors</h3>
                            </div>
                            <div class="col text-right">
                                <a href="Reports.aspx" class="btn btn-sm btn-primary">See all</a>
                            </div>
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="visitor-table-container">
                            <table class="table align-items-center table-flush">
                                <thead class="thead-light">
                                    <tr>
                                        <th scope="col">IP Address</th>
                                        <th scope="col">Page</th>
                                        <th scope="col">Time</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptRecentVisitors" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td class="visitor-ip">
                                                    <%# Eval("IPAddress") %>
                                                </td>
                                                <td>
                                                    <%# Eval("PageVisited") %>
                                                </td>
                                                <td class="visitor-time">
                                                    <%# FormatVisitorTime(Convert.ToDateTime(Eval("VisitTime"))) %>
                                                </td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

       <%-- <div class="row mt-4">
            <div class="col-xl-4">
                <div class="card">
                    <div class="card-header border-0">
                        <div class="row align-items-center">
                            <div class="col">
                                <h3 class="mb-0">Recent Activities</h3>
                            </div>
                            <div class="col text-right">
                                <a href="ActivityLog.aspx" class="btn btn-sm btn-primary">View All</a>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <div class="timeline">
                            <asp:Repeater ID="rptAdminActivities" runat="server">
                                <ItemTemplate>
                                    <div class="timeline-item">
                                        <div class="timeline-badge bg-<%# GetActivityColor(Eval("ActivityType").ToString()) %>">
                                            <i data-feather="<%# GetActivityIcon(Eval("ActivityType").ToString(), Eval("EntityType").ToString()) %>"></i>
                                        </div>
                                        <div class="activity-details">
                                            <div class="d-flex justify-content-between">
                                                <h6 class="mb-0"><%# Eval("Username") %></h6>
                                                <span class="activity-time"><%# FormatVisitorTime(Convert.ToDateTime(Eval("ActivityDate"))) %></span>
                                            </div>
                                            <p class="mb-0 text-sm">
                                                <span class="text-capitalize"><%# Eval("ActivityType") %></span> 
                                                <%# Eval("EntityType") %> - 
                                                <%# FormatActivityDescription(Eval("Description"), Eval("EntityType"), Eval("EntityID")) %>
                                            </p>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </div>
            </div>
        </div>--%>
    </div>
</asp:Content>