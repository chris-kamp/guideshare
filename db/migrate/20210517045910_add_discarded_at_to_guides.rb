class AddDiscardedAtToGuides < ActiveRecord::Migration[6.1]
  def change
    add_column :guides, :discarded_at, :datetime
    add_index :guides, :discarded_at
  end
end
