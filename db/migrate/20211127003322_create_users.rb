class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: false do |t|
      t.string :id, limit: 64, comment: 'submitted by user'
      t.text :name, limit: 256, comment: 'unique user name, as per webauthn spec'
      t.text :display_name, limit: 256, comment: 'as per webauthn spec'

      t.timestamps
    end
  end
end
