class LoanPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.class == BankUser
        scope.where(bank: user.bank)
      elsif user.class == User
        scope.where(user: user)
      end
    end
  end

  def create?
    record.user == user
  end

  def show?
    loan_user_or_bank_user?
  end

  def update?
    loan_user_or_bank_user?
  end

  private

  def loan_user_or_bank_user?
    if user.class == BankUser
      record.bank == user.bank
    elsif user.class == User
      record.user == user
    end
  end
end