class CreateCartGuides < ActiveRecord::Migration[6.1]
  def change
    create_table :cart_guides do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :guide, null: false, foreign_key: true

      t.timestamps
    end
  end
end
