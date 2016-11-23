class BankUserPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def show?
  end

  def edit?
  end

  def update?
    record.bank.bank_users.find(user.id) == user
  end
end
