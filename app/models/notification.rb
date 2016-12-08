class Notification < ApplicationRecord
  belongs_to :user

  scope :unread, -> { where(read: false) }

  after_create :trigger_sms, :trigger_email

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

  # Triggered when a bank accepts/declines a loan application
  def trigger_sms
    @loan = set_loan
    if @loan.status == "Application Accepted"
      sms_message = "Congratulations! Your loan has been accepted.
                     You qualify for up to
                     #{ActionController::Base.helpers.humanized_money_with_symbol(@loan.proposed_amount)}
                     You can reply 'confirm' or 'decline' to this message, or log in
                     to the website to see the full details and confirm your loan.
                     "
    elsif @loan.status == "Application Declined"
      sms_message = "We are sorry to inform you that your loan application has
                     been declined for the following reason: #{@loan.decline_reason}.\
                     Please visit the Stride website for more details"
    end
    send_text_notification(user.mobile_number, sms_message.squish)
  end

  def trigger_email
    @loan = set_loan
    UserMailer.application_reviewed(user: user, loan: @loan).deliver_later
  end

  private

  def send_text_notification(mobile_number, sms_message)
    begin
    @@client.messages.create(
      from: ENV['TWILIO_NUMBER'],
      to: mobile_number,
      body: sms_message)
    rescue Twilio::REST::RequestError => e
      puts e.message
    end
  end

  def set_loan
    @loan = user.loans.last
  end
end
