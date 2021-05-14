class CreateGuides < ActiveRecord::Migration[6.1]
  def change
    create_table :guides do |t|
      t.string :title, null: false
      t.text :description
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
