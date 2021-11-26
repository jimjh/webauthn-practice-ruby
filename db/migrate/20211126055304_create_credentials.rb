class CreateCredentials < ActiveRecord::Migration[6.1]
  def change
    create_table :credentials do |t|
      t.binary :credential_id
      t.binary :credential_public_key
      t.integer :sign_count
      t.string :aaguid
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
