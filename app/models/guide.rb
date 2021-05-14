class Guide < ApplicationRecord
  belongs_to :user
  validates :title,
            presence: true,
            uniqueness: true,
            length: {
              minimum: 5,
              maximum: 120,
            }
  validates :description, length: { maximum: 1200 }

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
