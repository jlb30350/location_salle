// app/javascript/application.js 

//= require_tree .
// Rails UJS and Turbo configuration
//= require rails-ujs
//= require_tree .

import { Turbo } from "@hotwired/turbo-rails";
import Lightbox from "path/to/lightbox";

Turbo.session.drive = false;

document.addEventListener("turbo:load", () => {
  initializeLightbox();
  setupLogoutLinks();
});

document.addEventListener('touchmove', function(e) {
  // Votre logique ici
}, { passive: true });


element.addEventListener('touchstart', function(e) {
  // Votre logique ici
}, { passive: true });



function initializeLightbox() {
  Lightbox.option({
    'resizeDuration': 200,
    'wrapAround': true
  });
}

function setupLogoutLinks() {
  const logoutLinks = document.querySelectorAll("a[data-turbo-method='delete']");
  logoutLinks.forEach(link => {
    link.addEventListener("click", (e) => {
      if (confirm("Êtes-vous sûr de vouloir vous déconnecter ?")) {
        e.preventDefault();
        submitDeleteForm(link.href);
      }
    });
  });
}

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


