class LoansController < ApplicationController
  skip_before_action :authenticate_bank_user!
  skip_before_action :authenticate_user!
  before_action :set_loan, only: [:update, :accept]

  include SmsSender

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
    @bank = Bank.find_by_name("FNB")
    authorize @loan
  end

  def create
    @loan = current_user.loans.build(loan_params)
    authorize @loan
    if @loan.save
      @loan.update(status: "Application Pending")
      SmsSender.application_sent_sms(current_user, @loan)
      UserMailer.application_confirmation_email(user: current_user, loan: @loan).deliver_later
      redirect_to user_status_path(current_user), notice: 'Loan application was successfully created.'
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
        send_application_reviewed_notifications(@loan)
        redirect_to bank_user_loans_path
      else
        @application_id = @loan.id
        render 'bank_users/index'
      end
    # elsif params[:loan][:agreed_amount].present? || params[:loan][:status] == "Loan Outstanding"
    #   # WILL/JULIEN YOU CAN PUT YOUR UPDATE CODE HERE
    end
  end

  def accept
    authorize @loan
    @loan.accept(accept_loan_params)
    SmsSender.confirm_loan(current_user, @loan)
    redirect_to user_status_path(current_user)
  end

  def applications
    @loans = policy_scope(Loan)
    authorize Loan
    respond_to do |format|
      format.js
    end
  end

  def outstanding
    @missed_payment_loans = current_bank_user.bank.loans.missed_payment_loans
    @delayed_payment_loans = current_bank_user.bank.loans.delayed_payment_loans
    authorize Loan
    respond_to do |format|
      format.js
    end
  end

  def declined
    @loans = policy_scope(Loan)
    authorize Loan
    respond_to do |format|
      format.js
    end
  end

  def repaid
    @loans = policy_scope(Loan)
    authorize Loan
    respond_to do |format|
      format.js
    end
  end

  def portfolio
    @loans = policy_scope(Loan)
    authorize Loan

    @hash = Gmaps4rails.build_markers(Loan.all) do |loan, marker|
      marker.lat loan.user.latitude
      marker.lng loan.user.longitude
    end

    respond_to do |format|
      format.js
    end
  end

  private

  def set_loan
    @loan = Loan.find(params[:id])
  end

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

  def send_application_reviewed_notifications(loan)
    Notification.create!(user: loan.user)
    SmsSender.application_reviewed_sms(loan.user, loan)
    UserMailer.application_reviewed(user: loan.user, loan: loan).deliver_later
  end
end
