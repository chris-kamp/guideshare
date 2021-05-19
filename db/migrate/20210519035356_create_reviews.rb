class CreateReviews < ActiveRecord::Migration[6.1]
  def change
    create_table :reviews do |t|
      t.integer :rating, null: false
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :guide, null: false, foreign_key: true

      t.timestamps
    end
  end
end
