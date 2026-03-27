<%-- Member Topbar Include --%>
<header class="topbar">
    <div class="topbar-left">
        <div class="topbar-avatar"><img src="img/icon-avatar.svg" alt="User" style="width:20px;height:20px;filter:invert(1)"></div>
        <div class="topbar-info">
            <div class="topbar-name"><%= session.getAttribute("memberName") %></div>
            <div class="topbar-role">Member</div>
        </div>
    </div>
    <div class="topbar-right">
        <div class="topbar-time">
            <div class="time-value" id="topbar-time"></div>
            <div id="topbar-date"></div>
        </div>
        <button class="topbar-settings" onclick="openModal('credentialsModal')"><img src="img/icon-gear.svg" alt="Settings" style="width:18px;height:18px"></button>
    </div>
</header>
