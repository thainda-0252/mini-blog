class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :email, index: { unique: true }
      t.string :bio
      t.string :password_digest, null: false
      t.timestamps
    end
  end
end
