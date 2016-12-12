class Notification < ApplicationRecord
  belongs_to :user

  scope :unread, -> { where(read: false) }
end
