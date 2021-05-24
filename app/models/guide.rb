class Guide < ApplicationRecord
  # Include "discard" gem functionality to permit "soft deletion" of guides
  # (because "deleted" guides should remain accessible by users who have already purchased them)
  include Discard::Model

  belongs_to :user
  has_one_attached :guide_file
  has_many :user_guides, dependent: :destroy
  has_many :owners, through: :user_guides, source: :user
  has_many :guide_tags, dependent: :destroy
  has_many :tags, through: :guide_tags
  has_many :reviews, dependent: :destroy
  has_many :cart_guides, dependent: :destroy

  validates :title,
            presence: true,
            uniqueness: true,
            length: {
              minimum: 5,
              maximum: 120,
            }
  validates :description, length: { maximum: 1200 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 100 }

  # Use active_storage_validations gem to validate attachments. Guide file must be a PDF < 2mb.
  validates :guide_file,
            attached: true,
            content_type: {
              in: 'application/pdf',
              message: 'must be a PDF file',
            },
            size: {
              less_than: 2.megabytes,
              message: 'must be less than 2 megabytes in size',
            }

  # Selects all guides whose titles match a query using case-insensitive wildcard search
  scope :title_matches_query, ->(query) { where("title ILIKE ?", "%#{query}%") }
  # Selects all distinct guides whose tags include ANY of a given array of tag ids
  scope :has_any_tag, ->(tag_ids) { joins(:tags).where("tags.id IN (?)", tag_ids).distinct }
  # Selects all guides whose tags include ALL of a given array of tag ids
  scope :has_all_tags, ->(tag_ids) { joins(:tags).where("tags.id IN (?)", tag_ids).group("guides.id").having("COUNT(guides.id) >= ?", tag_ids.count) }
  # Selects guides published by a given user
  scope :published_by, ->(user) { where(user: user) }
  # Selects guides in a given shopping cart
  scope :in_cart, ->(cart) { joins(:cart_guides).where("cart_guides.cart_id = ?", cart.id) }

  # Get the number of pages in the attached PDF via a Cloudinary API call.
  def get_page_count
    Cloudinary::Api.resource(guide_file.key, :pages => true)['pages'].to_i
  end

  # Returns true if the passed user owns a copy of the guide
  def owned_by?(owner)
    return owner && owners.exists?(owner.id)
  end

  # Get the username of the user who created the guide
  def author_name
    return user.username
  end

  # Returns true if the guide was authored by the given user
  def authored_by?(user_obj)
    return user == user_obj
  end

  # Returns true if guide has been purchased by any user
  def has_owners?
    return owners.exists?
  end

  # Returns the number of users who have purchased the guide
  def owners_count
    return owners.count
  end

  # Returns true if the guide has a price of zero, otherwise false
  def free?
    return price.zero?
  end

  # Returns the average rating for a guide, or "Not yet rated" if no reviews exist
  def rating
    return reviews.exists? ? reviews.average(:rating) : nil
  end
end
