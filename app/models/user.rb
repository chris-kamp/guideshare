class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  validates :username, presence: true, uniqueness: true
  has_many :guides, dependent: :destroy
  has_many :user_guides, dependent: :destroy
  has_many :owned_guides, through: :user_guides, source: :guide
end
