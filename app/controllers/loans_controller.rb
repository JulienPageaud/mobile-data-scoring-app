class LoansController < ApplicationController
  skip_before_action :authenticate_bank_user!
  skip_before_action :authenticate_user!
  before_action :set_loan, only: [:show, :update, :accept]

  include SmsSender

  def index
    @loans = policy_scope(Loan)

    if current_bank_user.present?
      @missed_payment_loans = current_bank_user.bank.loans.missed_payment_loans
      @delayed_payment_loans = current_bank_user.bank.loans.delayed_payment_loans
      render 'bank_users/index'
    else
      flash[:alert] = "You need to be signed in"
      redirect_to new_bank_user_session_path
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
      redirect_to status_user_path(current_user), notice: 'Loan application was successfully created.'
    else
      render :new
    end
  end

  def show
    if current_bank_user
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
    redirect_to status_user_path(current_user)
  end

  def applications
    authorize Loan
    loans = policy_scope(Loan)
    @pending_loans = loans.order(created_at: :desc).where(status: "Application Pending")
    @accepted_loans = loans.order(created_at: :desc).where(status: "Application Accepted")
    respond_to do |format|
      format.js
    end
  end

  def outstanding
    authorize Loan
    loans = policy_scope(Loan)
    @missed_payment_loans = loans.missed_payment_loans
    @delayed_payment_loans = loans.delayed_payment_loans
    @good_book_loans = loans.good_loans
    respond_to do |format|
      format.js
    end
  end

  def declined
    authorize Loan
    loans = policy_scope(Loan)
    @declined_loans = loans.order(created_at: :desc).where(status: "Application Declined")
    respond_to do |format|
      format.js
    end
  end

  def repaid
    authorize Loan
    loans = policy_scope(Loan)
    @repaid_loans = loans.order(created_at: :desc).where(status: "Loan Repaid")
    respond_to do |format|
      format.js
    end
  end

  def portfolio
    authorize Loan
    @loans = policy_scope(Loan)
    @bank = current_bank_user.bank
    @hash = google_maps_markers

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

  def google_maps_markers
    markers = Gmaps4rails.build_markers(Loan.all) do |loan, marker|
      marker.lat loan.user.latitude
      marker.lng loan.user.longitude
    end
    markers
  end
end
