// used on the share game form

// Check if URL matches pattern first
const currentPagePath = window.location.pathname;
const targetPattern = /^\/games\/\d+\/share_form$/;

if (targetPattern.test(currentPagePath)) {
  document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('share-game-form');
    const emailInput = document.getElementById('recipient_email');
    const emailError = document.getElementById('email-error');
    const submitButton = document.getElementById('share-submit-btn');

    if (!emailInput || !form || !submitButton) {
      console.error('Required element(s) missing');
      return; // Exit if any element is missing
    }

    let debounceTimeout;

    // Validate email format
    function validateEmail(email) {
      const re = /\S+@\S+\.\S+/;
      return re.test(email);
    }

    // Show error message
    function showError(message = 'Please enter a valid email address.') {
      if (emailError) {
        emailError.textContent = message;
        emailError.style.display = 'block';
        emailError.setAttribute('aria-hidden', 'false');
      }
      emailInput.classList.add('is-invalid');
      emailInput.setAttribute('aria-invalid', 'true');
      submitButton.disabled = true;
    }

    // Hide error message
    function hideError() {
      if (emailError) {
        emailError.style.display = 'none';
        emailError.setAttribute('aria-hidden', 'true');
      }
      emailInput.classList.remove('is-invalid');
      emailInput.setAttribute('aria-invalid', 'false');
    }

    // Initialize form state
    function initializeForm() {
      if (!validateEmail(emailInput.value)) {
        showError();
      } else {
        hideError();
      }
    }

    // Add input listener with debounce
    function handleInput() {
      clearTimeout(debounceTimeout);
      debounceTimeout = setTimeout(() => {
        if (validateEmail(emailInput.value)) {
          hideError();
          submitButton.disabled = false;
        } else {
          showError();
        }
      }, 300);
    }

    // Initial validation
    initializeForm();

    // Event listeners
    emailInput.addEventListener('input', handleInput);
    form.addEventListener('submit', function(event) {
      if (!validateEmail(emailInput.value)) {
        event.preventDefault();
        showError();
        emailInput.focus();
      }
    });
  });
}
