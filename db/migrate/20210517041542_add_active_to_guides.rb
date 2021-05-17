class AddActiveToGuides < ActiveRecord::Migration[6.1]
  def change
    add_column :guides, :active, :boolean, default: true
  end
end
