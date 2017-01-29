class UsersController < ApplicationController

  # Authentication is on user not bank_user in this case
  skip_before_action :authenticate_bank_user!

  before_action :set_user_and_latest_loan, only: [:show, :profile, :status]
  before_action :set_user, only: [:edit, :update, :share]

  def show
    authorize @user
    if @latest_loan.present?
      @loan_is_live = @latest_loan.live?
    else
      @loan_is_live = false
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    # Checks if user email has been changed
    @user.email = params[:user][:email]
    send_email = @user.email_changed?
    # @user.photo_id = params[:user][:photo_id]
    if @user.update(user_params) && @user.errors.messages[:photo_id].blank?
      UserMailer.email_has_changed(@user).deliver_later if send_email
      redirect_to user_path(@user)
    else
      render :edit, user: @user
    end
  end

  def status
    authorize @user
    @user.notifications.each { |n| n.update(read: true)} if @user.notifications.present?
    @rating = @user.badges.last.name.gsub(/-medal$/, '').capitalize
    # Used for the progress bar on status page
    if @latest_loan.present?
      @loan_is_live = @latest_loan.live?
      case @latest_loan.status
      when "Application Pending" then @status_id = 1
      when "Application Accepted" then @status_id = 2
      when "Loan Outstanding"
        @status_id = 3
        @delayed = @latest_loan.any_delayed_payment?
        @missed = @latest_loan.any_missed_payment?
      when "Loan Repaid" then @status_id = 4
      end
    else
      @status_id = 0
      @loan_is_live = false
    end
  end

  def profile
    authorize @user
  end

  def share
    authorize @user
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def set_user_and_latest_loan
    @user = User.find(params[:id])
    @latest_loan = @user.loans.last
  end

  def user_params
    params.require(:user).permit(:mobile_number, :title, :email,
      :first_name, :last_name, :address, :city, :postcode,
      :employment, :date_of_birth, :photo_id,
      :photo_id_cache, :details_completed)
  end

  def user_photo_id_changed?
    if params[:user][:photo_id].present?
      @user.photo_id = params[:user][:photo_id]
      return true
    else
      return false
    end
  end
end
