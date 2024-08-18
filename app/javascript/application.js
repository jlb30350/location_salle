// app/javascript/application.js

// Rails UJS et Turbo configuration
//= require rails-ujs

//= require_tree .

import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false

// Fonction pour ajouter une confirmation avant la déconnexion
document.addEventListener("turbo:load", () => {
  const logoutLinks = document.querySelectorAll("a[data-turbo-method='delete']");
  
  logoutLinks.forEach(link => {
    link.addEventListener("click", (e) => {
      if (confirm("Êtes-vous sûr de vouloir vous déconnecter ?")) {
        e.preventDefault();
        
        const form = document.createElement("form");
        form.method = "POST";
        form.action = link.href;

        const methodInput = document.createElement("input");
        methodInput.type = "hidden";
        methodInput.name = "_method";
        methodInput.value = "delete";

        form.appendChild(methodInput);
        document.body.appendChild(form);
        form.submit();
      }
    });
  });
});
