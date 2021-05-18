class CreateGuideTags < ActiveRecord::Migration[6.1]
  def change
    create_table :guide_tags do |t|
      t.references :tag, null: false, foreign_key: true
      t.references :guide, null: false, foreign_key: true

      t.timestamps
    end
  end
end
