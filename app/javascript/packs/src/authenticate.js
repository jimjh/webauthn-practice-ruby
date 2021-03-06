import { get } from "@github/webauthn-json";

async function submitForm(form) {
  // TODO validation
  const userName = form.elements['name'].value;
  const csrfToken = form.elements['authenticity_token'].value;

  const options = await fetch('/authenticate_options?user_name=' + userName, {
    method: 'GET',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
  }).then(r => r.json());

  const assertion = await get({ publicKey: options });

  await fetch('/authenticate', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-CSRF-Token': csrfToken
    },
    body: JSON.stringify({
      user_name: userName,
      assertion: assertion
    })
  });
};

(function () {
  let form = document.getElementById('login');
  form.addEventListener('submit', (event) => {
    event.preventDefault();
    submitForm(form);
  });
})();