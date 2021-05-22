class GuidePolicy < ApplicationPolicy
  # Guide must not have been discarded (with "discard" gem), or else user must own it
  def show?
    record.kept? || (user.owns?(record) || user.author?(record))
  end

  # User must be signed in and own a guide (or be its author) to view it
  def view?
    user.owns?(record) || user.author?(record)
  end

  def edit?
    update?
  end

  def update?
    user.author?(record)
  end

  # Only the author of a guide can destroy, archive or restore from archive
  def destroy?
    user.author?(record)
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