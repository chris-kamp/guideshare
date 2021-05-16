class CreateUserGuides < ActiveRecord::Migration[6.1]
  def change
    create_table :user_guides do |t|
      t.references :user, null: false, foreign_key: true
      t.references :guide, null: false, foreign_key: true

      t.timestamps
    end
  end
end
