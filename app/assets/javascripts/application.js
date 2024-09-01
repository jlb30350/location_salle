//= require jquery
//= require rails-ujs
//= require activestorage
//= require_tree .

if (typeof jQuery === 'undefined') {
  console.error("jQuery is not loaded. Please ensure jQuery is included.");
} else {
  console.log("jQuery is loaded correctly.");
}

// Initialisation de Lightbox
function initializeLightbox() {
  if (typeof Lightbox !== 'undefined') {
    Lightbox.option({
      'resizeDuration': 200,
      'wrapAround': true,
      'previousImage': '/path/to/lightbox/prev.png',
      'nextImage': '/path/to/lightbox/next.png',
      'closeImage': '/path/to/lightbox/close.png',
      'loadingImage': '/path/to/lightbox/loading.gif'
    });
  }
}

// Configuration des liens de déconnexion avec confirmation
function setupLogoutLinks() {
  const logoutLinks = document.querySelectorAll("a[data-method='delete']");
  logoutLinks.forEach(link => {
    link.addEventListener("click", (e) => {
      if (!confirm("Êtes-vous sûr de vouloir vous déconnecter ?")) {
        e.preventDefault();
      } else {
        submitDeleteForm(link.href);
      }
    });
  });
}

// Soumission d'un formulaire de déconnexion via POST avec le token CSRF
function submitDeleteForm(action) {
  const form = document.createElement("form");
  form.method = "POST";
  form.action = action;

  const methodInput = document.createElement("input");
  methodInput.type = "hidden";
  methodInput.name = "_method";
  methodInput.value = "delete";

  const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
  const csrfInput = document.createElement("input");
  csrfInput.type = "hidden";
  csrfInput.name = "authenticity_token";
  csrfInput.value = csrfToken;

  form.appendChild(methodInput);
  form.appendChild(csrfInput);
  document.body.appendChild(form);
  form.submit();
}

// Fonction pour initialiser la sélection de dates
function setupDateSelection() {
  let startDate = null;
  let endDate = null;

  document.querySelectorAll('.available-day').forEach(function(button) {
    button.addEventListener('click', function() {
      const selectedDate = this.getAttribute('data-date');
      console.log("Date sélectionnée :", selectedDate);

      if (!startDate) {
        startDate = selectedDate;
        this.classList.add('btn-primary');
        this.classList.remove('btn-success');
      } else if (!endDate) {
        endDate = selectedDate;
        this.classList.add('btn-primary');
        this.classList.remove('btn-success');

        const reservationSection = document.getElementById('reservation-section');
        if (reservationSection) {
          const roomId = reservationSection.dataset.roomId;
          window.location.href = `/rooms/${roomId}/bookings/new?start_date=${startDate}&end_date=${endDate}`;
        } else {
          console.error("L'élément avec l'ID 'reservation-section' n'existe pas.");
        }
      }
    });
  });
}

// Initialisation après le chargement de la page
document.addEventListener("DOMContentLoaded", function() {
  console.log("DOM chargé - Initialisation du calendrier");
  initializeLightbox();
  setupLogoutLinks();
  setupDateSelection();  // Initialisation de la sélection de dates

  const calendarEl = document.getElementById('calendar');
  
  if (calendarEl) {
    const roomId = calendarEl.dataset.roomId;

    // Initialisation du calendrier (vous pouvez remplacer cette partie par le code d'initialisation de votre calendrier si vous utilisez une bibliothèque spécifique)
    Calendar.prototype.initialRender = function () {
      var _this = this;

      if (!this.el) {
          console.error("Element 'el' is undefined or null. Ensure that 'el' is properly initialized.");
          return;
      }

      var el = this.el;  // Utilisation de l'élément natif

      // Ajout de la classe 'fc' sans jQuery
      el.classList.add('fc');

      // Délégation des événements pour les liens de navigation
      el.addEventListener('click', function (ev) {
          if (ev.target.matches('a[data-goto]')) {
              var anchorEl = ev.target;
              var gotoOptions = JSON.parse(anchorEl.getAttribute('data-goto'));  // Parse manuellement le JSON
              var date = _this.moment(gotoOptions.date);
              var viewType = gotoOptions.type;

              // Propriété comme "navLinkDayClick". Peut être une chaîne ou une fonction
              var customAction = _this.view.opt('navLink' + util_1.capitaliseFirstLetter(viewType) + 'Click');
              if (typeof customAction === 'function') {
                  customAction(date, ev);  // Appelle la fonction de personnalisation
              } else {
                  if (typeof customAction === 'string') {
                      viewType = customAction;
                  }
                  _this.zoomTo(date, viewType);  // Effectue un zoom sur la vue appropriée
              }
          }
      }, false);
    };
  }
});
