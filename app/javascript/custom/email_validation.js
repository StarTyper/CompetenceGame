// used on the share game form
// document.addEventListener('DOMContentLoaded', function() {
//   const form = document.getElementById('share-game-form');
//   const emailInput = document.getElementById('recipient_email');
//   const emailError = document.getElementById('email-error');
//   const submitButton = document.getElementById('share-submit-btn');

//   function validateEmail(email) {
//     const re = /\S+@\S+\.\S+/;
//     return re.test(email);
//   }

//   function showError() {
//     emailError.style.display = 'block';
//     emailInput.classList.add('is-invalid');
//   }

//   function hideError() {
//     emailError.style.display = 'none';
//     emailInput.classList.remove('is-invalid');
//   }

//   emailInput.addEventListener('input', function() {
//     if (validateEmail(this.value)) {
//       hideError();
//       submitButton.disabled = false;
//     } else {
//       showError();
//       submitButton.disabled = true;
//     }
//   });

//   form.addEventListener('submit', function(event) {
//     if (!validateEmail(emailInput.value)) {
//       event.preventDefault();
//       showError();
//     }
//   });
// });
