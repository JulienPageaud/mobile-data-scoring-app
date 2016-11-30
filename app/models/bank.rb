class Bank < ApplicationRecord
  has_many :loans
  has_many :users, through: :loans
  has_many :payments, through: :loans
  has_many :bank_users

  def net_balance_sheet
    balance = 0
    loans.where(status: "Loan Outstanding").each do |loan|
      balance += loan.remaining_capital
    end
    loans.where(status: "Application Accepted").each do |loan|
      balance -= loan.proposed_amount
    end
    return balance
  end

  def pending_response
    loans.where(status: "Application Pending").count
  end

  def pending_repayment
    loans.where(status: "Loan Outstanding").count
  end

  def total_users
    users.count
  end

  def customers
    users.joins(:loans).where("loans.status" => ["Application Accepted", "Loan Outstanding"]).count
  end

  def average_score_of_pending_customers
    total_credit_score = 0
    users.joins(:loans).where("loans.status" => "Application Pending").each do |user|
      total_credit_score += user.credit_score.to_f
    end

    total_credit_score / users.joins(:loans).where("loans.status" => "Application Pending").count
  end

  def average_score_of_active_customers
    total_score = 0
      users.joins(:loans).where("loans.status" => ["Application Accepted", "Loan Outstanding"]).each do |user|
        total_score += user.credit_score.to_f
      end

    total_score / customers
  end

  def applications_accepted
    loans.where(status: ["Application Accepted", "Loan Outstanding"]).where(updated_at: DateTime.now - 7.day..DateTime.now).count
  end

  def applications_declined
    loans.where(status: "Application Declined").where(updated_at: DateTime.now - 7.day..DateTime.now).count
  end
end
