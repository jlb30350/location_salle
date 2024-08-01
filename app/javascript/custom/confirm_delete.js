// app/javascript/custom/confirm_delete.js
document.addEventListener('turbo:load', () => {
    const deleteButton = document.querySelector('.delete-account-button');
    if (deleteButton) {
      deleteButton.addEventListener('click', (event) => {
        const confirmMessage = event.target.dataset.confirmMessage || "Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.";
        if (!confirm(confirmMessage)) {
          event.preventDefault();
        }
      });
    }
  });