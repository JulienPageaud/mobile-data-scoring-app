class Bank < ApplicationRecord
  has_many :loans
  has_many :users, through: :loans
  has_many :payments, through: :loans
  has_many :bank_users

  validates :name, presence: true, uniqueness: true

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

  def total_users_count
    users.count
  end

  # Returns all the customers with pending loan applications
  def pending_customers
    users.joins(:loans).where("loans.status" => "Application Pending")
  end

  # Returns all the customers with live loans
  def live_customers
    users.joins(:loans).where("loans.status" => ["Application Accepted", "Loan Outstanding"])
  end

  def customers_count
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

    total_score / customers_count
  end

  # Returns an array with frequency of customer in credit score brackets (75, 80, 85... etc.)

  def credit_score_distribution_pending
    results = { 0.98 => 0, 0.96 => 0, 0.94 => 0, 0.92 => 0, 0.90 => 0, 0.88 => 0, 0.86 => 0, 0.84 => 0, 0.82 => 0, 0.8 => 0}
    pending_customers.each do |customer|
      results.keys.each do |k|
        if customer.credit_score.to_f > k
          results[k] += 1
          break
        end
      end
    end
    return results.values.reverse
  end

  def credit_score_distribution_live
    results = { 0.98 => 0, 0.96 => 0, 0.94 => 0, 0.92 => 0, 0.90 => 0, 0.88 => 0, 0.86 => 0, 0.84 => 0, 0.82 => 0, 0.8 => 0}
    live_customers.each do |customer|
      results.keys.each do |k|
        if customer.credit_score.to_f > k
          results[k] += 1
          break
        end
      end
    end
    return results.values.reverse
  end

  def applications_accepted
    loans.where(status: ["Application Accepted", "Loan Outstanding"]).where(updated_at: DateTime.now - 7.day..DateTime.now).count
  end

  def applications_declined
    loans.where(status: "Application Declined").where(updated_at: DateTime.now - 7.day..DateTime.now).count
  end

  def applications_accepted
    loans.where(status: ["Application Accepted", "Loan Outstanding"]).where(updated_at: DateTime.now - 7.day..DateTime.now).count
  end

  def applications_declined
    loans.where(status: "Application Declined").where(updated_at: DateTime.now - 7.day..DateTime.now).count
  end

  # Pie Chart Percentage Methods
  def sixty_plus
    users.where(date_of_birth: (Time.now - 100.year)..(Time.now - 61.year)).count.to_f / User.count.to_f  * 100
  end

  def fifty_sixty
    users.where(date_of_birth: (Time.now - 60.year)..(Time.now - 51.year)).count.to_f / users.count.to_f  * 100
  end

  def fourty_fifty
    users.where(date_of_birth: (Time.now - 50.year)..(Time.now - 41.year)).count.to_f / users.count.to_f  * 100
  end

  def thirty_fourty
    users.where(date_of_birth: (Time.now - 40.year)..(Time.now - 31.year)).count.to_f / users.count.to_f  * 100
  end

  def twenty_thirty
    users.where(date_of_birth: (Time.now - 30.year)..(Time.now - 23.year)).count.to_f / users.count.to_f  * 100
  end

  def eigthteen_twenty
    users.where(date_of_birth: (Time.now - 22.year)..(Time.now - 18.year)).count.to_f / User.count.to_f  * 100
  end
end
