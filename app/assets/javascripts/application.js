//= require jquery
//= require rails-ujs
//= require activestorage
//= require_tree 

if (typeof jQuery === 'undefined') {
  console.error("jQuery is not loaded. Please ensure jQuery is included.");
} else {
  console.log("jQuery is loaded correctly.");
}

// Gestion des dates sélectionnées dans le calendrier
function setupDateSelection() {
  let startDate = null;
  let endDate = null;

  console.log("Initialisation de la sélection de dates...");

  const reservationSection = document.getElementById('reservation-section');
  if (!reservationSection) {
    console.error("L'élément avec l'ID 'reservation-section' n'existe pas.");
    return;
  }

  document.querySelectorAll('.available-day').forEach(function(button) {
    button.addEventListener('click', function() {
      const selectedDate = this.getAttribute('data-date');
      console.log("Date sélectionnée :", selectedDate);

      if (!startDate || (startDate && endDate)) {
        // Réinitialiser si une plage de dates a déjà été sélectionnée
        startDate = selectedDate;
        endDate = null;
        document.querySelectorAll('.available-day').forEach(btn => {
          btn.classList.remove('btn-primary');
          btn.classList.add('btn-success');
        });
        this.classList.add('btn-primary');
        this.classList.remove('btn-success');
        console.log("Start date:", startDate);
      } else if (!endDate && selectedDate > startDate) {
        endDate = selectedDate;
        this.classList.add('btn-primary');
        this.classList.remove('btn-success');
        console.log("End date:", endDate);

        // Récupération de l'ID de la salle depuis la section réservation
        const roomId = document.getElementById('reservation-section').dataset.roomId;
        console.log("Redirection avec Start date:", startDate, "End date:", endDate);

        // Redirection avec les dates sélectionnées dans l'URL
        window.location.href = `/rooms/${roomId}/bookings/new?start_date=${startDate}&end_date=${endDate}`;
      }
    });
  });
}

// Gestion des sélecteurs de date et heure dans le formulaire
function setupDateTimeSelectors() {
  const dateInput = document.getElementById('date-select');
  const timeInput = document.getElementById('time-select');

  if (dateInput && timeInput) {
    console.log("Les champs 'date-select' et 'time-select' sont présents.");

    const handleInputChange = () => {
      const selectedDate = dateInput.value;
      const selectedTime = timeInput.value;
      console.log("Date sélectionnée :", selectedDate);
      console.log("Heure sélectionnée :", selectedTime);
      fetchFormWithTimeSlots(selectedDate, selectedTime);
    };

    dateInput.addEventListener('change', handleInputChange);
    timeInput.addEventListener('change', handleInputChange);
  } else {
    console.error("Les champs 'date-select' ou 'time-select' sont manquants dans le DOM.");
  }
}

// Fonction pour récupérer les créneaux horaires selon la date et l'heure sélectionnée
function fetchFormWithTimeSlots(date, time) {
  if (!date || !time) return;

  fetch(`/get_time_slots?date=${date}&time=${time}`, {
    method: 'GET',
    headers: {
      'X-Requested-With': 'XMLHttpRequest'
    }
  })
  .then(response => response.text())
  .then(html => {
    document.getElementById('form-container').innerHTML = html;
  })
  .catch(error => console.error('Erreur:', error));
}

// Initialisation du script après le chargement du DOM
document.addEventListener('DOMContentLoaded', function() {
  setupDateSelection();
  setupDateTimeSelectors();
});
