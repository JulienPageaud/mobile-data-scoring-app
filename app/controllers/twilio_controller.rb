class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_bank_user!

  def sms_entry_point
    case params["Body"].upcase
    when "LOAN" then sign_up
    when "DETAILS" then complete_details
    when "APPLY" then apply_for_loan
    when "CONFIRM" then confirm_loan
    when "DECLINE" then decline_loan
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
      user.sms_sign_up(generated_password)
    else
      user.already_signed_up
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

  def confirm_loan
    message_body = params["Body"].upcase
    user = User.find_by_mobile_number(params["From"])

    if message_body.include?("CONFIRM")
      user.loans.last.accept(accept_loan_params(user))
      user.confirm_loan
    elsif message_body.include?("DECLINE")
      user.loans.last.decline
      user.decline_loan
    else
      user.other_sms
    end
  end

  private

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
