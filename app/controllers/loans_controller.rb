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
      redirect_to user_path(@loan), notice: 'Loan application was successfully created.'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if params[loan: {:status}] == "Application Approved" || params[loan: {:status}] == "Application Declined"
      authorize @loan
      if @loan.update(loan_bank_params)
      redirect_to bank_user_loans_path
      else
      render :show
      end
    elsif params[loan: {:agreed_amount_cents}] || params[loan: {:status}] == "Loan Outstanding"
      # WILL/JULIEN YOU CAN PUT YOUR UPDATE CODE HERE
    end
  end

  private

  def loan_params
    params.require(:loan).permit(:requested_amount_cents, :category, :purpose, :description)
  end

  def loan_bank_params
    params.require(:loan).permit(:status, :proposed_amount_cents, :decline_reason, :final_date)
  end

  def pundit_user
    if user_signed_in?
      current_user
    elsif bank_user_signed_in?
      current_bank_user
    end
  end
end
