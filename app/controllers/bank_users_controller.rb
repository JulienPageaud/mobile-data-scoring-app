class BankUsersController < ApplicationController

  # Authentication is on bank_user not user in this case
  skip_before_filter :authenticate_user!

  before_action :set_loan, only: [:show, :edit, :update]

  def index
    @loans = current_bank_user.bank.loans
    @missed_payment_loans = current_bank_user.bank.loans.missed_payment_loans
    @delayed_payment_loans = current_bank_user.bank.loans.delayed_payment_loans
  end

  def show
  end

  def edit
  end

  def update
    if @loan.update(loan_params)
      redirect_to bank_user_loans
    else
      render :show
    end
  end

  def user_show
    @user = User.find(params[:id])
  end

  private

  def set_loan
    @loan = Loan.find(params[:id])
  end

  def loan_params
    params.require(:loan).permit(:status, :proposed_amount_cents)
  end
end
