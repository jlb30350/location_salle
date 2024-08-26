// Importation de Rails UJS et démarrage
//= require jquery_ujs
//= require activestorage
//= require lightbox
//= require_tree .

// Importation de Rails UJS et démarrage
import Rails from "@rails/ujs";
Rails.start();

// Désactiver Turbo pour certaines pages si nécessaire
import { Turbo } from "@hotwired/turbo-rails";
Turbo.session.drive = false;

// ActiveStorage
import * as ActiveStorage from "@rails/activestorage";
ActiveStorage.start();

// Initialisation de Lightbox
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
document.addEventListener('touchmove', (e) => {}, { passive: true });
document.addEventListener('touchstart', (e) => {}, { passive: true });

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
document.addEventListener('DOMContentLoaded', function() {
  var calendar = document.getElementById('calendar');
  if (calendar) {
    calendar.addEventListener('click', function(event) {
      var target = event.target;
      if (target.classList.contains('available-date')) {
        var startDate = target.dataset.startDate;
        var endDate = target.dataset.endDate;
        window.location.href = `/rooms/${roomId}/bookings/new?start_date=${startDate}&end_date=${endDate}`;
      }
    });
  }
});

document.querySelectorAll('.available-day').forEach(function(button) {
  button.addEventListener('click', function() {
    const selectedDate = this.getAttribute('data-date');

    if (!firstDate) {
      firstDate = selectedDate;
      this.classList.add('btn-primary');
    } else if (!lastDate) {
      lastDate = selectedDate;
      this.classList.add('btn-primary');
      submitReservation(firstDate, lastDate);
    }
  });
});

function submitReservation(startDate, endDate) {
  const form = document.createElement('form');
  form.method = 'POST';
  form.action = '/create_reservation';

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
