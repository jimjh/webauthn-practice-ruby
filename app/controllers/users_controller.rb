require 'securerandom'
require 'digest'

class UsersController < ApplicationController

  def new
    @user = User.new
    # 16 bytes, as per https://w3c.github.io/webauthn/#sctn-cryptographic-challenges
    @challenge = SecureRandom.hex(16)
    # store in signed cookie for later verification
    cookies.signed[:challenge] = { value: @challenge, expires: 6.hours, httponly: true, secure: true, samesite: 'strict' }
  end

  def create
    # verify authenticity of challenge
    challenge = cookies.signed[:challenge]
    if params.delete(:challenge) != challenge
      raise ActionController::BadRequest.new('malformed challenge')
    end
    # verify credential and challenge
    webauthn_credential = WebAuthn::Credential.from_create(params[:publicKeyCredential])
    webauthn_credential.verify(challenge) 
    # TODO create credential and user
    # TODO @user = User.new(user_params)
  end

  def hash_user_id
    # Returns a deterministic 64-byte user ID from given user name.
    user_name = params[:user_name]
    # convert to 64-byte string (having a index-able and printable user ID is valuable)
    user_id = Digest::SHA2.hexdigest user_name
    render json: {user_id: user_id}
  end

  private
  def user_params
    params.require(:user).permit(:name, :display_name)
  end
end
