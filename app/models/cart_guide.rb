class CartGuide < ApplicationRecord
  belongs_to :cart
  belongs_to :guide
end
