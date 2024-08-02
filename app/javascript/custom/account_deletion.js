// app/javascript/custom/account_deletion.js
document.addEventListener('turbo:load', () => {
    const deleteAccountButton = document.querySelector('.delete-account-button');
    if (deleteAccountButton) {
      deleteAccountButton.addEventListener('click', (event) => {
        const confirmMessage = "Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.";
        if (!confirm(confirmMessage)) {
          event.preventDefault();
        }
      });
    }
  });