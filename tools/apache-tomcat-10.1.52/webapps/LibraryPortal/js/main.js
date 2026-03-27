/* ========================================
   The Archive Co. Library - Main JavaScript
   ======================================== */

document.addEventListener('DOMContentLoaded', function() {
  initTopbarClock();
  initTableSearch();
  initModals();
  initTabButtons();
  initGenreFilters();
  initPieChart();
  autoHideAlerts();
});

/* --- Topbar Clock --- */
function initTopbarClock() {
  const timeEl = document.getElementById('topbar-time');
  const dateEl = document.getElementById('topbar-date');
  if (!timeEl) return;

  function update() {
    const now = new Date();
    timeEl.textContent = now.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true });
    if (dateEl) {
      dateEl.textContent = now.toLocaleDateString('en-US', { month: 'short', day: '2-digit', year: 'numeric' });
    }
  }
  update();
  setInterval(update, 30000);
}

/* --- Table Search --- */
function initTableSearch() {
  const searchInputs = document.querySelectorAll('.search-input');
  searchInputs.forEach(function(input) {
    input.addEventListener('input', function() {
      const query = this.value.toLowerCase();
      const tableId = this.getAttribute('data-table');
      const table = document.getElementById(tableId);
      if (!table) return;

      const rows = table.querySelectorAll('tbody tr');
      rows.forEach(function(row) {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(query) ? '' : 'none';
      });
    });
  });
}

/* --- Modal System --- */
function initModals() {
  // Close modal on overlay click
  document.querySelectorAll('.modal-overlay').forEach(function(overlay) {
    overlay.addEventListener('click', function(e) {
      if (e.target === overlay) {
        closeModal(overlay.id);
      }
    });
  });

  // Close buttons
  document.querySelectorAll('.modal-close').forEach(function(btn) {
    btn.addEventListener('click', function() {
      const overlay = btn.closest('.modal-overlay');
      if (overlay) closeModal(overlay.id);
    });
  });

  // Cancel buttons
  document.querySelectorAll('.btn-cancel').forEach(function(btn) {
    btn.addEventListener('click', function() {
      const overlay = btn.closest('.modal-overlay');
      if (overlay) closeModal(overlay.id);
    });
  });
}

function openModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) {
    modal.classList.add('active');
    document.body.style.overflow = 'hidden';
  }
}

function closeModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) {
    modal.classList.remove('active');
    document.body.style.overflow = '';
  }
}

/* --- Tab Buttons --- */
function initTabButtons() {
  document.querySelectorAll('.tab-btn').forEach(function(btn) {
    btn.addEventListener('click', function() {
      const group = this.getAttribute('data-tab-group');
      const target = this.getAttribute('data-tab-target');

      // Deactivate all tabs in group
      document.querySelectorAll('.tab-btn[data-tab-group="' + group + '"]').forEach(function(t) {
        t.classList.remove('active');
      });
      this.classList.add('active');

      // Show/hide panels
      document.querySelectorAll('.tab-panel[data-tab-group="' + group + '"]').forEach(function(panel) {
        panel.classList.add('hidden');
      });
      var targetPanel = document.getElementById(target);
      if (targetPanel) targetPanel.classList.remove('hidden');
    });
  });
}

/* --- Genre Filters --- */
function initGenreFilters() {
  document.querySelectorAll('.genre-pill').forEach(function(pill) {
    pill.addEventListener('click', function() {
      const isActive = this.classList.contains('active');
      document.querySelectorAll('.genre-pill').forEach(function(p) { p.classList.remove('active'); });

      if (!isActive) {
        this.classList.add('active');
        filterBooksByGenre(this.getAttribute('data-genre'));
      } else {
        filterBooksByGenre('all');
      }
    });
  });
}

function filterBooksByGenre(genre) {
  document.querySelectorAll('.book-card').forEach(function(card) {
    if (genre === 'all' || card.getAttribute('data-genre') === genre) {
      card.style.display = '';
    } else {
      card.style.display = 'none';
    }
  });
}

/* --- Pie Chart --- */
function initPieChart() {
  const canvas = document.getElementById('pieChart');
  if (!canvas) return;

  const ctx = canvas.getContext('2d');
  const borrowed = parseInt(canvas.getAttribute('data-borrowed') || '0');
  const returned = parseInt(canvas.getAttribute('data-returned') || '0');
  const total = borrowed + returned || 1;

  const centerX = canvas.width / 2;
  const centerY = canvas.height / 2;
  const radius = Math.min(centerX, centerY) - 10;

  // Draw slices
  const slices = [
    { value: borrowed, color: '#1a1a1a' },
    { value: returned, color: '#666666' }
  ];

  let startAngle = -Math.PI / 2;
  slices.forEach(function(slice) {
    const sliceAngle = (slice.value / total) * 2 * Math.PI;
    ctx.beginPath();
    ctx.moveTo(centerX, centerY);
    ctx.arc(centerX, centerY, radius, startAngle, startAngle + sliceAngle);
    ctx.closePath();
    ctx.fillStyle = slice.color;
    ctx.fill();
    startAngle += sliceAngle;
  });

  // Center hole for donut effect
  ctx.beginPath();
  ctx.arc(centerX, centerY, radius * 0.4, 0, 2 * Math.PI);
  ctx.fillStyle = '#ffffff';
  ctx.fill();
}

/* --- Auto-hide alerts --- */
function autoHideAlerts() {
  document.querySelectorAll('.alert').forEach(function(alert) {
    setTimeout(function() {
      alert.style.opacity = '0';
      alert.style.transition = 'opacity 0.5s';
      setTimeout(function() { alert.remove(); }, 500);
    }, 4000);
  });
}

/* --- Toast Notifications --- */
function showToast(message, type) {
  type = type || 'success';
  const toast = document.createElement('div');
  toast.className = 'toast toast-' + type;
  toast.textContent = message;
  document.body.appendChild(toast);
  setTimeout(function() {
    toast.style.opacity = '0';
    toast.style.transition = 'opacity 0.5s';
    setTimeout(function() { toast.remove(); }, 500);
  }, 3000);
}

/* --- Form Helpers --- */
function populateEditForm(modalId, data) {
  const modal = document.getElementById(modalId);
  if (!modal) return;

  Object.keys(data).forEach(function(key) {
    const input = modal.querySelector('[name="' + key + '"]');
    if (input) input.value = data[key];
  });

  openModal(modalId);
}

/* --- Delete Confirmation --- */
var pendingDeleteUrl = '';

function confirmDelete(url) {
  pendingDeleteUrl = url;
  openModal('deleteModal');
}

function executeDelete() {
  if (pendingDeleteUrl) {
    window.location.href = pendingDeleteUrl;
  }
}

/* --- Borrow View Popup --- */
function viewBorrowDetails(borrowId) {
  openModal('borrowViewModal-' + borrowId);
}
