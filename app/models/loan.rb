class Loan < ApplicationRecord
  belongs_to :bank, optional: true
  belongs_to :user
  has_many :payments, dependent: :destroy

  monetize :requested_amount_cents
  monetize :proposed_amount_cents
  monetize :agreed_amount_cents

  validates :bank_id, presence: true
  validates :user_id, presence: true
  validates :requested_amount, presence: true,
              numericality: { less_than_or_equal_to: 15000, greater_than: 0 }
  validates :category, presence: true
  validates :purpose, presence: true
  validates :description, presence: true,
              length: { minimum: 20,
              too_short: "You need to exceed %{count} characters in your description" }
  validate :when_declining_a_loan, on: :update

  ## PAYMENT METHODS

  # Retrieve the next payment which is due
  def next_payment
    payments.where('due_date > ?', DateTime.now).first
  end

  # Retrieve the most recent payment which has passed it's due date
  def most_recent_payment
    payments.where('due_date < ?', DateTime.now).last
  end

  def amount_owed
    amount = 0
    payments.each do |payment|
      amount += payment.amount unless payment.paid
    end
    return amount
  end

  def amount_overdue
    amount_overdue = 0
    payments.each do |p|
      if p.due_date < DateTime.now && p.paid == false
        amount_overdue += p.amount
      end
    end
    amount_overdue
  end

  # Calculate the remaining capital on the loan
  def remaining_capital
    payments_total = 0
    payments.each do |payment|
      payments_total += payment.amount if payment.paid == true
    end
    payments.to_a.reduce(0) { |sum, p| sum += p.amount } - payments_total
  end

  # Calculate the total repaid capital
  def total_capital_repaid
    sum = Money.new(0)
    payments.each do |payment|
      sum += payment.amount if payment.paid == true
    end
    return sum
  end

  # Total loan capital to be repaid
  def total_capital
    payments.reduce(0) { |sum, p| sum += p.amount }
  end

  ## LOAN FILTERS

  # Finds loans which have no missed/delayed payments
  def self.good_loans
    result = order(start_date: :desc).where(status: "Loan Outstanding").reject { |loan| Loan.missed_payment_loans.include?(loan) }
    result.reject { |loan| Loan.delayed_payment_loans.include?(loan)}
  end

  # Finds loans which have missed payments (due_date + 7 days)
  def self.missed_payment_loans
    order(start_date: :desc).where(status: "Loan Outstanding").joins(:payments).where('payments.due_date < ?', (DateTime.now.end_of_day - 7.day)).where(payments: { paid: false })
  end

  # Finds loans which have delayed payments (less than 7 days since due date)
  def self.delayed_payment_loans
    result = order(start_date: :desc).where(status: "Loan Outstanding").joins(:payments).where(payments: {due_date: DateTime.now.end_of_day - 7.day..DateTime.now.end_of_day}).where(payments: { paid: false })
    result.select { |loan| loan unless missed_payment_loans.include?(loan) }
  end


  # This method is used to create the payments which are shown to the user before confirming/accepting the loan
  def create_payments_proposed
    payment_amount = ((proposed_amount.amount * (1 + interest_rate.fdiv(100))) / duration_months) * 100

    counter = 1
    duration_months.times do
      payment = payments.build(amount_cents: payment_amount, due_date: (DateTime.now.end_of_day + counter.month)) # DateTime.now used as start_date will be set later
      payment.save
      counter += 1
    end
  end

  # This method is used to create the final payments based on the agreed amount which is entered by the user
  # Old payments are destroyed and replaced by new ones based on this new amount
  def update_payments_to_agreed_amount
    payments.destroy_all

    payment_amount = ((agreed_amount.amount * (1 + interest_rate.fdiv(100))) / duration_months) * 100
    counter = 1
    duration_months.times do
      payment = payments.build(amount_cents: payment_amount, due_date: (start_date.end_of_day + counter.month))
      payment.save
      counter += 1
    end
  end

  ## OUTSTANDING LOAN CLASSIFICATION METHODS
  def loan_classification
    if status == "Loan Outstanding" && most_recent_payment.present?
      if Loan.missed_payment_loans.include?(self)
        "Missed Payment"
      elsif Loan.delayed_payment_loans.include?(self)
        "Delayed Payment"
      else
        "Good Book"
      end
    elsif status == "Loan Outstanding"
      "Good Book"
    end
  end

  def accept(arguments)
    update(status: "Loan Outstanding")
    update(arguments)
    update_payments_to_agreed_amount
  end

  protected

  def when_declining_a_loan
    if status_was == "Application Pending" && status == "Application Declined"
      errors.add(:decline_reason, "Please enter a reason for declining the application") if decline_reason.blank?
    end
  end
end
