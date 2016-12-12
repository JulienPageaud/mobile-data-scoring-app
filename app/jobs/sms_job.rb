class SmsJob < ApplicationJob
  queue_as :default

  def perform(mobile_number, body)
    Notification.send_sms(mobile_number, body)
  end
end
