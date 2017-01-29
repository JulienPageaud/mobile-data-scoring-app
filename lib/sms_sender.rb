module SmsSender

  @@client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

  def self.send_sms(mobile_number, body)
    begin
    @@client.messages.create(
      from: ENV['TWILIO_NUMBER'],
      to: mobile_number,
      body: body)
    rescue Twilio::REST::RequestError => e
      puts e.message
    end
  end

  def self.sign_up(user, password)
    body = "Welcome to StrideWorld. Thank you for signing up with us.
            To sign in on www.strideworld.com use your mobile number
            (e.g. +27123456789) and your unique password: #{password}."
    SmsJob.perform_later(user.mobile_number, body.squish)
    body2 = "You will now need to visit www.strideworld.com/users/#{user.id} to
            give us some more details about yourself."
    SmsJob.set(wait: 20.second).perform_later(user.mobile_number, body2.squish)
  end

  def self.already_signed_up(user)
    if user.details_completed
      body = "You have already got an account with Stride. Please reply APPLY to
             apply for a new loan"
    else
      body = "You have already got an account with Stride. We require some more details
              from you before you can apply for a loan. Please reply DETAILS to complete
              these by SMS or visit www.strideworld.com/profile"
    end
    SmsJob.perform_later(user.mobile_number, body.squish)
  end

  def self.confirm_loan(user, loan)
    body = "Thank you for confirming your loan\
            (amount: #{ActionController::Base.helpers.humanized_money_with_symbol(loan.agreed_amount)}).
            Your e-wallet will be credited shortly!
            Your next payment:
            #{ActionController::Base.helpers.humanized_money_with_symbol(loan.next_payment.amount)} on #{loan.next_payment.due_date.strftime("%e %b %Y")}"
    SmsJob.perform_later(user.mobile_number, body.squish)
  end

  def self.decline_loan(user)
    body = "You have chosen to decline your loan.
            We hope you will consider reapplying in the future. Please contact
            contact@strideworld.com if you would like to leave your feedback"
    SmsJob.perform_later(user.mobile_number, body.squish)
  end

  def self.send_failure_sms(user)
    body = "We're sorry, we didn't understand your message. If you would like to
            create an account with StrideWorld then please send us the text 'LOAN'.
            You can also visit www.strideworld.com or contact us at contact@strideworld.com"
    SmsJob.perform_later(user.mobile_number, body.squish)
  end

  def self.application_sent_sms(user, loan)
    body = "Hello! Your loan application for
            #{ActionController::Base.helpers.humanized_money_with_symbol(loan.requested_amount)}
            has been sent successfully.
            You will receive another message shortly once it has been reviewed.
            Stride"
    SmsJob.perform_later(user.mobile_number, body.squish)
  end

  def self.application_reviewed_sms(user, loan)
    if loan.status == "Application Accepted"
      body = "Congratulations! Your loan has been accepted.
              You qualify for up to
              #{ActionController::Base.helpers.humanized_money_with_symbol(loan.proposed_amount)}
              You can reply 'confirm' or 'decline' to this message, or log in
              to the website to see the full details (www.strideworld.com/status)."
    elsif loan.status == "Application Declined"
      body = "We are sorry to inform you that your loan application has
              been declined for the following reason: #{loan.decline_reason}.\
              Please visit www.strideworld.com/status for more details"
    end
    SmsJob.perform_later(user.mobile_number, body.squish)
  end

  def self.other_sms(user)
    case loans.last.status
    when "Application Pending"
      body = "Your loan application is still under review. We will
              get back to you as soon as the bank has processed your application."
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
    SmsJob.perform_later(mobile_number, body.squish)
  end
end
