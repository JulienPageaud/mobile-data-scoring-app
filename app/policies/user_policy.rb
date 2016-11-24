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

  def user_show?
    record.loans.last.bank == user.bank
  end
end
