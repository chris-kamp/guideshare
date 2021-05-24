class ReviewPolicy < ApplicationPolicy
  def new?
    create?
  end

  # Authorize creation of review only if valid guide id provided and user owns that guide
  def create?
    Guide.exists?(record.guide_id) && record.guide.owned_by?(user)
  end
  
  def edit?
    update?
  end

  # Authorize update only if review belongs to user
  def update?
    record.user == user
  end

  # Only the author of a review can delete it
  def destroy?
    record.user == user
  end
end