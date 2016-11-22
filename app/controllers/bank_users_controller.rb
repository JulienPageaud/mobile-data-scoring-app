class BankUsersController < ApplicationController

  # Authentication is on bank_user not user in this case
  skip_before_filter :authenticate_user!

  before_action :set_loan, only: [:show, :edit, :update]

  def index
    @loans = current_bank_user.bank.loans
  end

  def show
  end

  def edit
  end

  def update
  end

  private

  def set_loan
    @loan = Loan.find(params[:id])
  end
end
