class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_guides, dependent: :destroy
  has_many :guides, through: :cart_guides

  def total
    return guides.sum(&:price)
  end
end
