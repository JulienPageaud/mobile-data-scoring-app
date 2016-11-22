class Loan < ApplicationRecord
  belongs_to :bank
  belongs_to :user
  has_many :payments

  monetize :requested_amount_cents
  monetize :proposed_amount_cents
  monetize :agreed_amount_cents

  validates :requested_amount, presence: true
  validates :category, presence: true
  validates :purpose, presence: true
  validates :description, presence: true, length: { minimum: 100,
    too_short: "You need to exceed %{count} characters in your description" }


  def next_payment_date
    payments.where('due_date < ?', DateTime.now).first
  end

  def self.good_loans
    all.joins(:payments).where("payment.due_date <  #{DateTime.now}").where("payments.paid" => true)
  end

  def remaining_capital
    payments_total = 0
    payments.each do |payment|
      payments_total += payment.amount_cents if payment.paid == true
    end
    return agreed_amount_cents - payments_total
  end
end
