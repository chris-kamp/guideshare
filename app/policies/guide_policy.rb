class GuidePolicy < ApplicationPolicy
  def index?
    true
  end

  # Guide must not have been discarded (with "discard" gem), or else user must own it
  def show?
    record.kept? || (user && user.owns?(record))
  end

  # User must be signed in and own a guide (or be its author) to view it
  def view?
    user && (user.owns?(record) || user.author?(record))
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
end