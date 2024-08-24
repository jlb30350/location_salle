// Importation de Rails UJS et démarrage
import Rails from "@rails/ujs";
Rails.start();

// Démarrage d'ActiveStorage et des canaux ActionCable
import { start as startActiveStorage } from "@rails/activestorage";
import "channels";
startActiveStorage();

// Turbo configuration
import { Turbo } from "@hotwired/turbo-rails";
Turbo.session.drive = false; // Désactiver Turbo pour certaines pages si nécessaire

// Importation de Lightbox (assurez-vous que le chemin est correct)
import Lightbox from "path/to/lightbox";

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


document.addEventListener('DOMContentLoaded', function () {
  let firstDate = null;
  let lastDate = null;

  document.querySelectorAll('.available-day').forEach(function(button) {
    button.addEventListener('click', function() {
      const selectedDate = this.getAttribute('data-date');

      if (!firstDate) {
        firstDate = selectedDate;
        this.classList.add('btn-primary');
      } else if (!lastDate) {
        lastDate = selectedDate;
        this.classList.add('btn-primary');

        // Après avoir sélectionné la deuxième date, vous pouvez soumettre le formulaire
        submitReservation(firstDate, lastDate);
      }
    });
  });

  function submitReservation(startDate, endDate) {
    // Envoyer la demande de réservation avec les dates sélectionnées
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = '/path_to_reservation_creation'; // Remplacez par l'URL correcte

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


// Initialisation de Lightbox avec des options
function initializeLightbox() {
  Lightbox.option({
    'resizeDuration': 200,
    'wrapAround': true
  });
}

function checkPhotos() {
  const mainPhotoField = document.querySelector('input[name="room[main_photo]"]');
  const additionalPhotosField = document.querySelector('input[name="room[additional_photos][]"]');
  
  if (!mainPhotoField.files.length && !additionalPhotosField.files.length) {
    alert("Veuillez sélectionner au moins une photo.");
    return false;
  }
  return true;
}


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
