class Guide < ApplicationRecord
  belongs_to :user
  has_one_attached :guide_file

  validates :title,
            presence: true,
            uniqueness: true,
            length: {
              minimum: 5,
              maximum: 120,
            }
  validates :description, length: { maximum: 1200 }

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
end
