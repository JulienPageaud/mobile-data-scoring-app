class Notification < ApplicationRecord
  belongs_to :user

  scope :unread, -> { where(read: false) }

  after_create :trigger_sms

  @@client = Twilio::REST::Client.new(ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN'])

  def trigger_sms
    @loan = user.loans.last
    if user.loans.last.status == "Application Accepted"
      sms_message = "Congratulations! Your loan has been accepted.
                     You qualify for up to
                     #{ActionController::Base.helpers.humanized_money_with_symbol(@loan.proposed_amount)}
                     You can reply 'confirm' or 'decline' to this message, or log in
                     to the website to see the full details and confirm your loan.
                     "
      sms_message.squish!
    elsif user.loans.last.status == "Application Declined"
      sms_message = "We are sorry to inform you that your loan application has
                     been declined for the following reason: #{@loan.decline_reason}.\
                     Please visit the Stride website for more details"
      sms_message.squish!
    end
    send_text_notification(user.mobile_number, sms_message)
  end

  def self.send_sms(mobile_number, body)
    @@client.messages.create(
      from: ENV['TWILIO_NUMBER'],
      to: mobile_number,
      body: body)
  end

  private

  def send_text_notification(mobile_number, sms_message)
    twilio_number = ENV['TWILIO_NUMBER']

    @@client.messages.create(
      from: twilio_number,
      to: mobile_number,
      body: sms_message)
  end
end
