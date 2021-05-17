class GuidePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  # User must be signed in and own a guide to view it
  def view?
    user && user.owns?(record)
  end

  def new?
    true
  end

  def create?
    true
  end

  def edit?
    update?
  end

  def update?
    user && user.author?(record)
  end

  def destroy?
    user && user.author?(record)
  end

  def purchase?
    true
  end

  def success?
    true
  end

  def cancel?
    true
  end

  def owned?
    true
  end
end