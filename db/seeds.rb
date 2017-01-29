Loan.destroy_all
User.destroy_all
BankUser.destroy_all
Bank.destroy_all
bank = Bank.create!(name: "Bank")
BankUser.create!(email: "bankemployee@gmail.com", password: "ilovemoney",
  first_name: "Joel", last_name: "Banks", phone_number: '+27999785123',
  bank: bank)
BankUser.create!(email: "bankemployee@bank.com", password: "ilovemoney",
  first_name: "Jan", last_name: "Mandela", phone_number: '+27999233233',
  bank: bank)

cities_ary = ["Johannesburg", 'Cape Town', 'Durban', 'Pretoria', 'Port Elizabeth', 'Bloemfontein']

status_ary = ["Application Pending", "Application Accepted", "Loan Outstanding", "Application Declined", "Loan Repaid"]
category_ary = ["Personal", "Business"]
purpose_perso_ary = ["Medical Expenses", "School Fees", "Transportation Expenses", "Other"]
purpose_business_ary = ["New Equipment", "Inventory Purposes", "Refurbishment Work", "Liability Management", "Other"]
description_ary = ["I need to pay for a organ transplant for my son",
  "I want to buy a large amount of cooking utensils for my kitchen as the restaurant is expanding",
  "I would like to open a clothes shop as there are none in this area",
  "I want to start my own tech business and I need the money to launch my product",
  "I want to learn how to code Ruby on Rails applications at Le Wagon",
  "I'm really thirsty so I want to buy lots of beer"]
decline_reason_ary = ["Credit score too low",
  "Insufficient mobile data", "Criminal record"]

start_date_outstanding_ary = [(DateTime.now - 3.day), (DateTime.now - 1.month),
  (DateTime.now - 2.month), (DateTime.now - 15.day),
  (DateTime.now - 8.day - 1.month)]
start_date_repaid_ary = [(DateTime.now - 1.month), (DateTime.now - 2.month),
  (DateTime.now - 3.month), (DateTime.now - 20.day),
  (DateTime.now -3.day)]

# Pending Applications
41.times do
  mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(12) + 88).fdiv(100).round(2))

  category = category_ary.sample
  category == "Personal" ? purpose = purpose_perso_ary.sample : purpose = purpose_business_ary.sample
  loan = user.loans.build(category: category,
    status: "Application Pending", purpose: purpose,
    description: description_ary.sample, interest_rate: 15,
    bank: bank, requested_amount: rand(100..15000).round(-2))
  loan.save!
  loan.category == "Personal" ? loan.update(purpose: purpose_perso_ary.sample) : loan.update(purpose: purpose_business_ary.sample)
end

# Accepted Application
22.times do
  mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(10) + 90).fdiv(100).round(2))

  category = category_ary.sample
  category == "Personal" ? purpose = purpose_perso_ary.sample : purpose = purpose_business_ary.sample
  loan = user.loans.build(category: category,
    status: "Application Accepted", purpose: purpose,
    description: description_ary.sample,
    bank: bank, requested_amount: rand(100..15000).round(-2))
  loan.update!(proposed_amount: loan.requested_amount, updated_at: DateTime.now - rand(0..21).day)
  loan.category == "Personal" ? loan.update!(purpose: purpose_perso_ary.sample) : loan.update!(purpose: purpose_business_ary.sample)
  loan.create_payments_proposed
end

# Good Book Loans
92.times do
  mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(5) + 95).fdiv(100).round(2))

  category = category_ary.sample
  category == "Personal" ? purpose = purpose_perso_ary.sample : purpose = purpose_business_ary.sample
  loan = user.loans.build(category: category,
    status: "Loan Outstanding", purpose: purpose,
    description: description_ary.sample,
    bank: bank, requested_amount: rand(100..15000).round(-2))
  loan.update!(proposed_amount: loan.requested_amount, agreed_amount: loan.requested_amount,
    start_date: DateTime.now - (rand(1..21).round.day))
  loan.category == "Personal" ? loan.update!(purpose: purpose_perso_ary.sample) : loan.update!(purpose: purpose_business_ary.sample)
  loan.update!(final_date: (loan.start_date + loan.duration_months.month), updated_at: loan.start_date)
  loan.update_payments_to_agreed_amount
  loan.payments.each do |payment|
    payment.update!(paid: true) if payment.due_date < DateTime.now
  end
end

# Missed Payment Loans
2.times do
    mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(10) + 80).fdiv(100).round(2))

  category = category_ary.sample
  category == "Personal" ? purpose = purpose_perso_ary.sample : purpose = purpose_business_ary.sample
  loan = user.loans.build(category: category,
    status: "Loan Outstanding", purpose: purpose,
    description: description_ary.sample,
    bank: bank, requested_amount: rand(100..15000).round(-2))
  loan.update!(proposed_amount: loan.requested_amount, agreed_amount: loan.requested_amount,
    start_date: DateTime.now - (rand(1..2).month + (rand(8..50).round.day)))
  loan.category == "Personal" ? loan.update!(purpose: purpose_perso_ary.sample) : loan.update!(purpose: purpose_business_ary.sample)
  loan.update!(final_date: (loan.start_date + loan.duration_months.month), updated_at: loan.start_date)
  loan.update_payments_to_agreed_amount
  loan.payments.each do |payment|
    payment.update!(paid: true) if payment.due_date < DateTime.now
  end
  loan.most_recent_payment.update!(paid:false)
end

# Delayed Payment Loans
5.times do
  mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(5) + 90).fdiv(100).round(2))

  category = category_ary.sample
  category == "Personal" ? purpose = purpose_perso_ary.sample : purpose = purpose_business_ary.sample
  loan = user.loans.build(category: category,
    status: "Loan Outstanding", purpose: purpose,
    description: description_ary.sample,
    bank: bank, requested_amount: rand(100..15000).round(-2))
  loan.update!(proposed_amount: loan.requested_amount, agreed_amount: loan.requested_amount,
    start_date: DateTime.now - (1.month + (rand(1..7).round.day)))
  loan.category == "Personal" ? loan.update!(purpose: purpose_perso_ary.sample) : loan.update!(purpose: purpose_business_ary.sample)
  loan.update!(final_date: (loan.start_date + loan.duration_months.month), updated_at: loan.start_date)
  loan.update_payments_to_agreed_amount
  loan.payments.each do |payment|
    payment.update!(paid: true) if payment.due_date < DateTime.now
  end
  loan.most_recent_payment.update(paid:false)
end

# Repaid Payment Loans
20.times do
  mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(5) + 94).fdiv(100).round(2))

  category = category_ary.sample
  category == "Personal" ? purpose = purpose_perso_ary.sample : purpose = purpose_business_ary.sample
  loan = user.loans.build(category: category,
    status: "Loan Repaid", purpose: purpose,
    description: description_ary.sample,
    bank: bank, requested_amount: rand(100..15000).round(-2))
  loan.update!(proposed_amount: loan.requested_amount, agreed_amount: loan.requested_amount,
    start_date: DateTime.now - (rand(1..50).round.day))
  loan.category == "Personal" ? loan.update!(purpose: purpose_perso_ary.sample) : loan.update!(purpose: purpose_business_ary.sample)
  loan.update!(final_date: (loan.start_date + loan.duration_months.month))
  loan.update_payments_to_agreed_amount
  loan.payments.each do |payment|
    payment.update!(paid: true)
  end
end


# Declined Payment Loans
40.times do
  mobile_string = '7' + ('%010d' % rand(10 ** 9)).to_s
  user = User.create!(mobile_number: '+27' + mobile_string,
    password: 'testtest', first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name, city: cities_ary.sample,
    date_of_birth: Faker::Date.between(18.years.ago, 80.years.ago), credit_score: (rand(10) + 80).fdiv(100).round(2))

  category = category_ary.sample
  category == "Personal" ? purpose = purpose_perso_ary.sample : purpose = purpose_business_ary.sample
  loan = user.loans.build(category: category,
    status: "Application Declined", purpose: purpose,
    description: description_ary.sample,
    bank: bank, requested_amount: rand(100..15000).round(-2),
    decline_reason: decline_reason_ary.sample)
  loan.update!(created_at: DateTime.now - rand(0..19).day)
  loan.update!(final_date: loan.created_at + rand(1..5).day)
  loan.update!(updated_at: loan.final_date)
end

demo_user_1 = User.create!(
  mobile_number: '+123123', password: 'stride', first_name: 'John',
  last_name: 'Smith', city: 'Johannesburg',
  date_of_birth: Faker::Date.between(18.years.ago, 40.years.ago),
  credit_score: 97, address: '63 Plein St', postcode: '2000'
)
demo_user_2 = User.create!(
  mobile_number: '+456456', password: 'stride', first_name: 'John',
  last_name: 'Smith', city: 'Johannesburg',
  date_of_birth: Faker::Date.between(18.years.ago, 40.years.ago),
  credit_score: 97, address: '63 Plein St', postcode: '2000'
)
2.times do
  loan = demo_user_2.loans.build({
    category: 'Personal',
    status: "Loan Repaid", purpose: 'Medical Expenses',
    description: 'I would like to pay for a surgery',
    bank: bank, requested_amount: 10000
  })
  loan.update!({
    proposed_amount: loan.requested_amount,
    agreed_amount: loan.requested_amount,
    start_date: DateTime.now - 3.month, final_date: DateTime.now
  })
  loan.update_payments_to_agreed_amount
  loan.payments.each { |p| p.update(paid: true, paid_date: DateTime.now) }
end
