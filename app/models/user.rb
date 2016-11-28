class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :omniauthable, omniauth_providers: [:facebook],
         authentication_keys: [:mobile_number]
  has_many :loans
  has_many :notifications, dependent: :destroy

  def email_required?
    false
  end

  def email_changed?
    false
  end

  # def self.find_for_facebook_oauth(auth)
  #   user_params = auth.to_h.slice(:provider, :uid)
  #   user_params.merge! auth.info.slice(:email, :first_name, :last_name)
  #   user_params[:token] = auth.credentials.token
  #   user_params[:token_expiry] = Time.at(auth.credentials.expires_at)

  #   user = User.where(provider: auth.provider, uid: auth.uid).first
  #   user ||= User.where(email: auth.info.email).first # User did a regular sign up in the past.
  #   if user
  #     user.update(user_params)
  #   else
  #     user = User.new(user_params)
  #     user.password = Devise.friendly_token[0,20]  # Fake password for validation
  #     user.save
  #   end

  #   return user
  # end

  def update_with_facebook(auth)
    user_params = auth.to_h.slice(:provider, :uid)
    user_params.merge! auth.info.slice(:email, :first_name, :last_name)
    # user_params[:facebook_picture_url] = auth.info.image
    user_params[:token] = auth.credentials.token
    user_params[:token_expiry] = Time.at(auth.credentials.expires_at)
    self.update(user_params)
  end


  # SMS MESSAGE METHODS

  def confirm_loan
    body = "Thank you for confirming your loan\
            (amount: #{ActionController::Base.helpers.humanized_money_with_symbol(loans.last.agreed_amount)}).
            Your e-wallet will be credited shortly!
            Your next payment:
            #{ActionController::Base.helpers.humanized_money_with_symbol(loans.last.next_payment.amount)} on #{loans.last.next_payment.due_date.strftime("%e %b %Y")}"
    Notification.send_sms(mobile_number, body.squish)
  end

  def decline_loan
    body = "You have chosen to decline your loan.
            We hope you will consider reapplying in the future"
    Notification.send_sms(mobile_number, body.squish)
  end

  def other_sms
    case loans.last.status
    when "Application Pending"
      body = "Your loan application is still under review. We will
            get back to you as soon as the bank has processed your application. "
    when "Application Accepted"
      body = "We are sorry, we didn't understand your response. Please
              reply to use with the word 'confirm' or 'decline' to finalize
              your loan."
    when "Application Declined"
      body = "We understand that having your application declined is frustrating.
              Please contact our support team who can help you improve your chances
              of being accepted in the future."
    when "Loan Outstanding"
      body = "We are not currently expecting any communication from you.
              Your next payment details:
              #{ActionController::Base.helpers.humanized_money_with_symbol(loans.last.try(next_payment).try(amount))}
              on #{loans.last.try(next_payment).try(due_date).try(strftime("%e %b %Y"))}
              We will remind you one week before your payment date."
    end
    Notification.send_sms(mobile_number, body.squish)
  end
end
