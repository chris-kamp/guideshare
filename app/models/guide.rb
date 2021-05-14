class Guide < ApplicationRecord
  belongs_to :user
  validates :title, presence: true

  # Returns the guide's description if not empty, or else "no description provided"
  def description_text
    return description && !description.strip.empty? ? description : "No description provided"
  end
end
