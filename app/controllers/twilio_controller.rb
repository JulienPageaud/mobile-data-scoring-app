class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_bank_user!

  def confirm_loan
    message_body = params["Body"]
    user = User.find_by_mobile_number(params["From"])

    if message_body.downcase.include?("confirm")
      user.loans.last.accept(accept_loan_params(user))
      user.confirm_loan
    elsif message_body.downcase.include?("decline")
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
end
