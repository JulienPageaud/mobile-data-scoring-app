class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_bank_user!

  include SmsSender

  def sms_entry_point
    @user = User.find_by_mobile_number(params["From"])
    case params["Body"].upcase
    when "LOAN" then sign_up
    when "DETAILS" then complete_details
    when "APPLY" then apply_for_loan
    when "CONFIRM" then confirm_loan(@user)
    when "DECLINE" then decline_loan(@user)
    else #send failure sms
      puts "RESPONSE NOT UNDERSTOOOOOOOOOOOD"
    end
  end

  protected

  def sign_up
    generated_password = Devise.friendly_token.first(6)
    user = User.new(mobile_number: params["From"],
                    password: generated_password)
    if user.save
      SmsSender.sign_up(user, generated_password)
    else
      SmsSender.already_signed_up(user)
    end
  end

  def complete_details
    # not sure how this will work exactly...
    puts "USER SHOULD COMPLETE THEIR DETAILS"
  end

  def apply_for_loan
    # similar to complete_details sections
    puts "USER SHOULD ENTER THEIR LOAN DETAILS"
  end

  def confirm_loan(user)
    user.loans.last.accept(accept_loan_params(user))
    SmsSender.confirm_loan(user, user.loans.last)
  end

  def decline_loan(user)
    user.loans.last.decline
    SmsSender.decline_loan(user)
  end

  def other_sms(user)
    user.other_sms
  end

  def accept_loan_params(user)
    loan = user.loans.last
    return {  agreed_amount: loan.proposed_amount,
              start_date: DateTime.now,
              final_date: (DateTime.now + loan.duration_months.month)
    }
  end

  def sign_up_params
    params.permit("From", "Body")
  end
end
