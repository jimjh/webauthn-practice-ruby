class CreateCredentials < ActiveRecord::Migration[6.1]
  def change
    create_table :credentials do |t|
      # generated credential's ID, at most 1023 bytes as per RFC (1364 after base64 encoding)
      t.binary :credential_id, limit: 1364, null: false
      # generated credential's public key (base64-encoded)
      t.binary :credential_public_key, null: false
      # how many times the authenticator says the credential was used
      t.integer :sign_count, null: false
      # a 128-bit integer indicating the type and vendor of the authenticator
      t.string :aaguid, limit: 32
      t.references :user, null: false, foreign_key: true

      t.timestamps

      t.index ["credential_id"], name: "index_credentials_on_credential_id"
    end
  end
end
