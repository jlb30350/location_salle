//= require rails-ujs
//= require activestorage
//= require_tree

// Initialisation de Lightbox
function initializeLightbox() {
  if (typeof Lightbox !== 'undefined') {
    Lightbox.option({
      'resizeDuration': 200,
      'wrapAround': true,
      'previousImage': '<%= asset_path("lightbox/prev.png") %>',
      'nextImage': '<%= asset_path("lightbox/next.png") %>',
      'closeImage': '<%= asset_path("lightbox/close.png") %>',
      'loadingImage': '<%= asset_path("lightbox/loading.gif") %>'
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
        e.preventDefault();
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

// Gestion de la sélection de dates pour les réservations
function setupDateSelection() {
  console.log("Initialisation de la sélection de dates"); // Aide au débogage
  let startDate = null;
  let endDate = null;

  // Assurez-vous que `.available-day` correspond aux jours disponibles dans votre HTML
  document.querySelectorAll('.available-day').forEach(function(button) {
    button.addEventListener('click', function(event) {
      event.preventDefault();
      console.log("Date sélectionnée :", this.dataset.date); // Aide au débogage

      const selectedDate = this.dataset.date;

      if (!startDate) {
        // Première sélection : début de la réservation
        startDate = selectedDate;
        this.classList.add('btn-primary');
        this.classList.remove('btn-success');
      } else if (!endDate) {
        // Deuxième sélection : fin de la réservation
        endDate = selectedDate;
        this.classList.add('btn-primary');
        this.classList.remove('btn-success');

        // Redirection vers la page de création de réservation
        const roomId = document.getElementById('reservation-section').dataset.roomId;
        const url = `/rooms/${roomId}/bookings/new?start_date=${startDate}&end_date=${endDate}`;
        window.location.href = url;
      }
    });
  });
}

// Vérifiez si les éléments .available-day existent dans le DOM après le chargement complet du DOM
document.addEventListener("DOMContentLoaded", function() {
  console.log("DOM chargé");

  initializeLightbox();
  setupLogoutLinks();
  setupDateSelection(); // Initialisation de la sélection de dates
});
