class Guide < ApplicationRecord
  belongs_to :user
  validates :title, presence: true

  # Returns true if the guide has a description that is not empty or comprised only of whitespace
  def has_description?
    return description && !description.strip.empty?
  end
end
