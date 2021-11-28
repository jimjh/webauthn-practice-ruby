import { create } from "@github/webauthn-json";

async function submitForm(form) {

  // https://w3c.github.io/webauthn/#dictdef-publickeycredentialentity
  /* It is intended only for display, i.e., aiding the user in determining the difference between user accounts with
   * similar displayNames. */
  const userName = form.elements['user_name'].value;

  /* CSRF token */
  const csrfToken = form.elements['authenticity_token'].value;

  /* A human-palatable name for the user account, intended only for display. */
  const displayName = form.elements['user_display_name'].value;

  const hashURL = new URL(location.origin + '/register_options');
  hashURL.search = new URLSearchParams({ user_name: userName, display_name: displayName }).toString();
  const webauthnOptions = await fetch(hashURL, {
    method: 'GET',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
  }).then(r => r.json());

  const credential = await create({ publicKey: webauthnOptions });
  // TODO error handling

  await fetch('/users', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      'X-CSRF-Token': csrfToken
    },
    body: JSON.stringify({
      user_name: userName,
      display_name: displayName,
      credential: credential
    })
  });
  // TODO error handling

}

(function () {
  let form = document.getElementById('signup');
  form.addEventListener('submit', (event) => {
    event.preventDefault();
    submitForm(form);
  });
})();