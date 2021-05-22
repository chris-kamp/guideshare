class User < ApplicationRecord
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :username, presence: true, uniqueness: true
  has_many :guides, dependent: :destroy
  has_many :user_guides, dependent: :destroy
  has_many :owned_guides, through: :user_guides, source: :guide
  has_many :reviews, dependent: :destroy
  has_many :reviewed_guides, through: :reviews, source: :guide
  has_one :cart, required: true, dependent: :destroy

  accepts_nested_attributes_for :cart

  # Returns true if the user owns the passed guide
  def owns?(guide)
    owned_guides.exists?(guide.id)
  end

  # Returns true if the user is the author of the passed guide
  def author?(guide)
    guides.exists?(guide.id)
  end

  # Returns true if the user has already posted a review of the passed guide
  def reviewed?(guide)
    reviewed_guides.exists?(guide.id)
  end
  
  # Returns the user's review of the passed guide, or nil if none exists
  def review(guide)
    reviews.find_by_guide_id(guide.id)
  end

  # Returns true if the passed guide is in the user's shopping cart, or false otherwise
  def in_cart?(guide)
    return cart.guides.exists?(guide.id)
  end
end
