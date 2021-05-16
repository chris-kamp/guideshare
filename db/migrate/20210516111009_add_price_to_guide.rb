class AddPriceToGuide < ActiveRecord::Migration[6.1]
  def change
    add_column :guides, :price, :decimal, default: 0.0
  end
end
