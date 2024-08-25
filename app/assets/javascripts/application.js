// Importation de Rails UJS et démarrage
//= require jquery
//= require rails-ujs
//= require activestorage
//= require lightbox
//= require_tree .

// Démarrage de Rails UJS et ActiveStorage
Rails.start();
startActiveStorage();

// Turbo configuration
Turbo.session.drive = false; // Désactiver Turbo pour certaines pages si nécessaire

// Initialisation de Lightbox avec des options
function initializeLightbox() {
  Lightbox.option({
    'resizeDuration': 200,
    'wrapAround': true
  });
}

// Gestion des événements de chargement Turbo
document.addEventListener("turbo:load", () => {
  initializeLightbox();
  setupLogoutLinks();
});

// Gestion des événements tactiles avec `passive: true`
document.addEventListener('touchmove', (e) => {
  // Logique pour l'événement 'touchmove'
}, { passive: true });

document.addEventListener('touchstart', (e) => {
  // Logique pour l'événement 'touchstart'
}, { passive: true });

// Configuration des liens de déconnexion avec confirmation
function setupLogoutLinks() {
  const logoutLinks = document.querySelectorAll("a[data-turbo-method='delete']");
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

// Gestion de la soumission de réservation avec sélection de dates
document.addEventListener('DOMContentLoaded', function () {
  let firstDate = null;
  let lastDate = null;

  document.querySelectorAll('.available-day').forEach(function(button) {
    button.addEventListener('click', function() {
      const selectedDate = this.getAttribute('data-date');
      console.log('Date sélectionnée :', selectedDate);

      if (!firstDate) {
        firstDate = selectedDate;
        this.classList.add('btn-primary');
        console.log('Date de début sélectionnée :', firstDate);
      } else if (!lastDate) {
        lastDate = selectedDate;
        this.classList.add('btn-primary');
        console.log('Date de fin sélectionnée :', lastDate);

        // Soumettre la réservation après avoir sélectionné la deuxième date
        submitReservation(firstDate, lastDate);
      }
    });
  });

  function submitReservation(startDate, endDate) {
    console.log('Soumission de la réservation avec les dates :', startDate, endDate);

    // Envoyer la demande de réservation avec les dates sélectionnées
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/create_reservation';  // Assurez-vous que cette URL correspond à votre route

    const csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    const csrfInput = document.createElement('input');
    csrfInput.type = 'hidden';
    csrfInput.name = 'authenticity_token';
    csrfInput.value = csrfToken;
    form.appendChild(csrfInput);

    const startDateInput = document.createElement('input');
    startDateInput.type = 'hidden';
    startDateInput.name = 'start_date';
    startDateInput.value = startDate;
    form.appendChild(startDateInput);

    const endDateInput = document.createElement('input');
    endDateInput.type = 'hidden';
    endDateInput.name = 'end_date';
    endDateInput.value = endDate;
    form.appendChild(endDateInput);

    document.body.appendChild(form);
    form.submit();
  }
});
