class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :content_url
      t.text :caption
      t.integer :status
      t.timestamps
    end
  end
end
