class Notification < ApplicationRecord
  belongs_to :user

  scope :unread, -> { where(read: false) }

  after_create :trigger_email

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

  private

  # Triggered when a bank accepts/declines a loan application
  def trigger_email
    @loan = set_loan
    UserMailer.application_reviewed(user: user, loan: @loan).deliver_later
  end


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
