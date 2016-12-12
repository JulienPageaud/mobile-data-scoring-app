require 'sms_sender'

class SmsJob < ApplicationJob
  queue_as :default

  def perform(mobile_number, body)
    SmsSender.send_sms(mobile_number, body)
  end
end
