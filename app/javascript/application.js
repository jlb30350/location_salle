// app/javascript/application.js



//= require_tree .
// Rails UJS et Turbo configuration
//= require rails-ujs
//= require_tree .

import { Turbo } from "@hotwired/turbo-rails";
Turbo.session.drive = false;

document.addEventListener("turbo:load", () => {
  const logoutLinks = document.querySelectorAll("a[data-turbo-method='delete']");

  logoutLinks.forEach(link => {
    link.addEventListener("click", (e) => {
      if (confirm("Êtes-vous sûr de vouloir vous déconnecter ?")) {
        e.preventDefault();

        const form = document.createElement("form");
        form.method = "POST";  // Utiliser POST, pas GET
        form.action = link.href;

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
    });
  });
});
