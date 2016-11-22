class LoansController < ApplicationController
  skip_before_filter :authenticate_bank_user!

  def index
  end

  def new
    @loan = Loan.new
  end

  def create
    @loan = current_user.loans.build(loan_params)
    @loan.user_id = params[:user_id]

    if @loan.save
      redirect_to user_loan_path(current_user, @loan), notice: 'Loan application was successfully created.'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  private

  def loan_params
    params.require(:loan).permit(:requested_amount_cents, :category, :purpose, :description)
  end
end
