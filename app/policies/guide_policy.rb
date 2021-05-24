class GuidePolicy < ApplicationPolicy
  # Guide must not have been discarded (with "discard" gem), or else user must own it
  def show?
    record.kept? || (record.owned_by?(user) || record.authored_by?(user))
  end

  # User must be signed in and own a guide (or be its author) to view it
  def view?
    record.owned_by?(user) || record.authored_by?(user)
  end

  def edit?
    update?
  end

  def update?
    record.authored_by?(user)
  end

  # Only the author of a guide can destroy, archive or restore from archive
  def destroy?
    record.authored_by?(user)
  end

  # Guide cannot be archived if already archived
  def archive?
    destroy? && record.kept?
  end

  # Guide cannot be restored unless it has been archived
  def restore?
    destroy? && record.discarded?
  end
end