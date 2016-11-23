class UserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def show?
    record == user
  end

  def update?
    record == user
  end

  def status?
    show?
  end

  def profile?
    show?
  end

  def share?
    show?
  end
end
