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

  def author?(guide)
    guides.exists?(guide.id)
  end

  def reviewed?(guide)
    reviewed_guides.exists?(guide.id)
  end
  
  def review(guide)
    reviews.find_by_guide_id(guide.id)
  end
end
