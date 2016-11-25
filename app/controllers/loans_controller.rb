class LoansController < ApplicationController
  skip_before_action :authenticate_bank_user!
  skip_before_action :authenticate_user!
  before_action :set_loan, only: [:update, :accept]

  def index
    if current_bank_user.present?
      @loans = policy_scope(Loan)
      @missed_payment_loans = current_bank_user.bank.loans.missed_payment_loans
      @delayed_payment_loans = current_bank_user.bank.loans.delayed_payment_loans
      render 'bank_users/index'
    end
  end

  def new
    @loan = current_user.loans.build
    authorize @loan
  end

  def create
    @loan = current_user.loans.build(loan_params)
    authorize @loan

    if @loan.save
      @loan.status = "Application Pending"
      @loan.save
      redirect_to user_path(current_user), notice: 'Loan application was successfully created.'
    else
      render :new
    end
  end

  def show
    if current_bank_user
      @loan = Loan.find(params[:id])
      authorize @loan
      render 'bank_users/show'
    end
  end

  def edit
  end

  def update
    if params[:loan][:status] == "Application Accepted" || params[:loan][:status] == "Application Declined"
      authorize @loan
      if @loan.update(loan_bank_params)
        @loan.create_payments_proposed
        redirect_to bank_user_loans_path
      else
        render :show
      end
    elsif params[loan: :agreed_amount_cents] || params[loan: :status] == "Loan Outstanding"
      # WILL/JULIEN YOU CAN PUT YOUR UPDATE CODE HERE
    end
  end

  def accept
    authorize @loan
    @loan.status = "Loan Outstanding"
    @loan.update(accept_loan_params)
    @loan.update_payments_to_agreed_amount
    redirect_to user_status_path(current_user)
  end

  private

  def loan_params
    params.require(:loan).permit(:requested_amount, :category, :purpose, :description, :bank_id)
  end

  def accept_loan_params
    params.require(:loan).permit(:agreed_amount, :start_date, :final_date)
  end

  def loan_bank_params
    params.require(:loan).permit(:status, :proposed_amount, :decline_reason, :final_date)
  end

  def pundit_user
    if user_signed_in?
      current_user
    elsif bank_user_signed_in?
      current_bank_user
    end
  end

  def set_loan
    @loan = Loan.find(params[:id])
  end
end
