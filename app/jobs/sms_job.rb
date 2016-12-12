class SmsJob < ApplicationJob
  queue_as :default

  include SmsSender

  def perform(mobile_number, body)
    # Notification.send_sms(mobile_number, body)
    SmsSender.send_sms(mobile_number, body)
  end
end
