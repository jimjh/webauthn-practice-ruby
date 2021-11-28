require 'securerandom'
require 'digest'
require 'base64'

class UsersController < ApplicationController

  # Constructs an empty user record for rendering the registration form.
  def new
    @user = User.new
  end

  # Creates a deterministic 64-byte user ID from given user name, and returns WebAuthn creation options.
  def register_options

    user_name = params[:user_name]
    display_name = params[:display_name]
    # convert to 64-byte string (having a index-able and printable user ID is valuable)
    user_id = name_to_id user_name
    options = WebAuthn::Credential.options_for_create(
      user: { id: user_id, name: user_name, display_name: display_name },
    )

    # store in signed cookie for later verification
    cookies.signed[:challenge] = challenge_cookie(options.challenge)
    render json: options
  end

  # Constructs and saves a User-Credential pair.
  def create
    # retrieve signed challenge
    challenge = cookies.signed[:challenge]
    # verify credential and challenge
    webauthn_credential = WebAuthn::Credential.from_create(params[:credential])
    webauthn_credential.verify(challenge) 
    # create credential and user
    user_id = name_to_id params[:user_name]
    user = User.new(id: user_id, name: params[:user_name], display_name: params[:display_name])
    w = webauthn_credential.response
    # interesting: this library wants you to store the base64-encoded values
    # this seems smarter than my python-impl
    user.credentials.build(
      credential_id: webauthn_credential.id,
      credential_public_key: webauthn_credential.public_key,
      sign_count: webauthn_credential.sign_count,
      aaguid: w.aaguid
    )
    render json: user.save!
  end

  # Renders login form.
  def sign_in
  end

  # Identifies credentials for given user, and returns WebAuthn authentication options.
  def authenticate_options
    # returns credential IDs to request
    user_id = name_to_id params[:user_name]
    user = User.find(user_id)
    options = WebAuthn::Credential.options_for_get(allow: user.credentials.map { |c| c.credential_id })
    # store in signed cookie for later verification
    cookies.signed[:challenge] = challenge_cookie(options.challenge)
    render json: options
  end

  def authenticate
    user_id = name_to_id params[:user_name]
    user = User.find(user_id)
    webauthn_credential = WebAuthn::Credential.from_get(params[:assertion])
    stored_credential = user.credentials.find_by(credential_id: webauthn_credential.id)
    webauthn_credential.verify(
      cookies.signed[:challenge],
      public_key: stored_credential.credential_public_key,
      sign_count: stored_credential.sign_count
    )
    # Update the stored credential sign count with the value from `webauthn_credential.sign_count`
    stored_credential.update!(sign_count: webauthn_credential.sign_count)
  end

  private
  def name_to_id(name)
    Digest::SHA2.hexdigest name
  end

  def challenge_cookie(challenge)
    return {
      value: challenge,
      expires: 6.hours,
      httponly: true,
      secure: true,
      samesite: 'strict'
    }
  end
end
