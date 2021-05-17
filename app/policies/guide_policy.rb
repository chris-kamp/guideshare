class GuidePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

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
    true
  end

  def update?
    true
  end

  def destroy?
    true
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