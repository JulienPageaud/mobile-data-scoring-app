class TwilioController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_bank_user!

  def confirm_loan

    message_body = params["Body"]
    user = User.find_by_mobile_number(params["From"])
    user = User.find_by_mobile_number("00447990740467")

    if message_body.downcase.include?("confirm")
      user.confirm_loan
    elsif message_body.downcase.include?("decline")
      user.decline_loan
    else
      #user.error_text
    end
  end

end
