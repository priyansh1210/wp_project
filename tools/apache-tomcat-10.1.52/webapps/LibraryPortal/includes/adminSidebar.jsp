<%-- Admin Sidebar Include --%>
<nav class="sidebar">
    <div class="sidebar-logo">
        <img src="img/logo-white.svg?v=12" class="logo-icon" alt="The Archive Co.">
        <div class="logo-text">The Archive Co.</div>
    </div>
    <div class="sidebar-nav">
        <a href="adminDashboard.jsp" class="${param.page == 'dashboard' ? 'active' : ''}">
            <img src="img/icon-dashboard.svg" class="nav-icon-img" alt="Dashboard"><span>Dashboard</span>
        </a>
        <a href="adminCatalog.jsp" class="${param.page == 'catalog' ? 'active' : ''}">
            <img src="img/icon-catalog.svg" class="nav-icon-img" alt="Catalog"><span>Catalog</span>
        </a>
        <a href="adminBooks.jsp" class="${param.page == 'books' ? 'active' : ''}">
            <img src="img/icon-books.svg" class="nav-icon-img" alt="Books"><span>Books</span>
        </a>
        <a href="adminUsers.jsp" class="${param.page == 'users' ? 'active' : ''}">
            <img src="img/icon-users.svg" class="nav-icon-img" alt="Users"><span>Users</span>
        </a>
        <a href="adminBranches.jsp" class="${param.page == 'branches' ? 'active' : ''}">
            <img src="img/icon-branches.svg" class="nav-icon-img" alt="Branches"><span>Branches</span>
        </a>
    </div>
    <div class="sidebar-logout">
        <a href="LogoutServlet">
            <img src="img/icon-logout.svg" class="nav-icon-img" alt="Logout"><span>Log Out</span>
        </a>
    </div>
</nav>
