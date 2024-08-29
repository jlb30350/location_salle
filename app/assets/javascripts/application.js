//= require jquery
//= require rails-ujs
//= require activestorage
//= require_tree .
//= require fullcalendar

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
    
    // Initialise le calendrier FullCalendar
    var calendar = new FullCalendar.Calendar(calendarEl, {
      initialView: 'dayGridMonth',
      events: `/rooms/${roomId}/bookings/events`, // Chemin pour récupérer les événements

      headerToolbar: {
        left: 'prev,next today',
        center: 'title',
        right: 'dayGridMonth,timeGridWeek,timeGridDay'
      },
      eventColor: '#FF0000', // Couleur par défaut pour "Réservé"
      dateClick: function(info) {
        if (!info.dateStr) return;

        const reservationSection = document.getElementById('reservation-section');
        if (reservationSection) {
          window.location.href = `/rooms/${roomId}/bookings/new?start_date=${info.dateStr}&end_date=${info.dateStr}`;
        }
      },
      eventsSet: function(events) {
        events.forEach(function(event) {
          if (event.title === 'Disponible') {
            event.setProp('backgroundColor', '#00FF00');  // Vert pour "Disponible"
            event.setProp('borderColor', '#00FF00');
          }
        });
      }
    });

    calendar.render();
  }
});
