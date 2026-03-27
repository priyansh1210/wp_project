<%-- Member Sidebar Include --%>
<nav class="sidebar">
    <div class="sidebar-logo">
        <img src="img/logo-white.svg?v=12" class="logo-icon" alt="The Archive Co.">
        <div class="logo-text">The Archive Co.</div>
    </div>
    <div class="sidebar-nav">
        <a href="memberDashboard.jsp" class="${param.page == 'dashboard' ? 'active' : ''}">
            <img src="img/icon-dashboard.svg" class="nav-icon-img" alt="Dashboard"><span>Dashboard</span>
        </a>
        <a href="memberBooks.jsp" class="${param.page == 'books' ? 'active' : ''}">
            <img src="img/icon-books.svg" class="nav-icon-img" alt="Books"><span>Browse Books</span>
        </a>
        <a href="memberBorrows.jsp" class="${param.page == 'borrows' ? 'active' : ''}">
            <img src="img/icon-catalog.svg" class="nav-icon-img" alt="Borrows"><span>My Borrows</span>
        </a>
        <a href="memberProfile.jsp" class="${param.page == 'profile' ? 'active' : ''}">
            <img src="img/icon-users.svg" class="nav-icon-img" alt="Profile"><span>Profile</span>
        </a>
    </div>
    <div class="sidebar-logout">
        <a href="LogoutServlet">
            <img src="img/icon-logout.svg" class="nav-icon-img" alt="Logout"><span>Log Out</span>
        </a>
    </div>
</nav>
