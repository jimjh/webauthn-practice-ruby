require 'securerandom'
require 'digest'
require 'base64'

class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    # retrieve signed challenge
    challenge = cookies.signed[:challenge]
    # verify credential and challenge
    webauthn_credential = WebAuthn::Credential.from_create(params)
    webauthn_credential.verify(challenge) 
    # create credential and user
    user_id = name_to_id params[:userName]
    user = User.new(id: user_id, name: params[:userName], display_name: params[:displayName])
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

  def hash_user_id
    # Returns a deterministic 64-byte user ID from given user name.

    user_name = params[:user_name]
    display_name = params[:display_name]
    # convert to 64-byte string (having a index-able and printable user ID is valuable)
    user_id = name_to_id user_name
    options = WebAuthn::Credential.options_for_create(
      user: { id: user_id, name: user_name, display_name: display_name },
    )
    # store in signed cookie for later verification
    cookies.signed[:challenge] = {
      value: options.challenge,
      expires: 6.hours,
      httponly: true,
      secure: true,
      samesite: 'strict'
    }
    render json: options
  end

  def sign_in
    # renders login form
  end

  def credentials
    # returns credential IDs to request
    user_id = name_to_id params[:user_name]
    user = User.find(user_id)
    options = WebAuthn::Credential.options_for_get(allow: user.credentials.map { |c| c.credential_id })
    # store in signed cookie for later verification
    cookies.signed[:challenge] = {
      value: options.challenge,
      expires: 6.hours,
      httponly: true,
      secure: true,
      samesite: 'strict'
    }
    render json: options
  end

  def authenticate
    user_id = name_to_id params[:userName]
    user = User.find(user_id)
    webauthn_credential = WebAuthn::Credential.from_get(params)
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
end
