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

  # Returns the guide's description if not empty, or else "no description provided"
  def description_text
    return(
      if description && !description.strip.empty?
        description
      else
        'No description provided'
      end
    )
  end

  # Get the number of pages in the attached PDF via a Cloudinary Admin API call.
  # Note page count is only accessible after file uploaded to Cloudinary, so can't be
  # set and stored in database using a callback on creation/update of guide object.
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

  # Returns true if guide has been purchased by any user
  def has_owners?
    return owners.exists?
  end
end
