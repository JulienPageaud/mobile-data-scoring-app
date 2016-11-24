# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.destroy_all

counter = 1

6.times do
  User.create( email: "user#{counter}@gmail.com", password: "123456",
    mobile_number: "#{counter}", gender: "male", first_name: "Spider",
    last_name: "Man", address: "8 Spidey Road", city: "New York",
    postcode: "#{counter}", employment: "Superhero", details_completed: true)
  counter += 1
end

Loan.create( user_id: 2, status: "Application Pending", category: "personal", purpose: "Medical Expenses",
  description: "I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... ",
  interest_rate: 15, start_date: nil, final_date: nil, requested_amount_cents: 50000,
  proposed_amount_cents: nil, agreed_amount_cents: nil, duration_months: 3)
Loan.create( user_id: 3, status: "Application Accepted", category: "personal", purpose: "Medical Expenses",
  description: "I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... ",
  interest_rate: 15, start_date: nil, final_date: nil, requested_amount_cents: 50000,
  proposed_amount_cents: 50000, agreed_amount_cents: nil, duration_months: 3)
Loan.create( user_id: 4, status: "Loan Outstanding", category: "personal", purpose: "Medical Expenses",
  description: "I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... ",
  interest_rate: 15, start_date: nil, final_date: nil, requested_amount_cents: 50000,
  proposed_amount_cents: 50000, agreed_amount_cents: 50000, duration_months: 3)
Loan.create( user_id: 5, status: "Application Declined", category: "personal", purpose: "Medical Expenses",
  description: "I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... ",
  interest_rate: 15, start_date: nil, final_date: nil, requested_amount_cents: 50000,
  proposed_amount_cents: nil, agreed_amount_cents: nil, duration_months: 3)
Loan.create( user_id: 6, status: "Loan Repaid", category: "personal", purpose: "Medical Expenses",
  description: "I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... I need this loan for spider things... ",
  interest_rate: 15, start_date: nil, final_date: nil, requested_amount_cents: 50000,
  proposed_amount_cents: 50000, agreed_amount_cents: 50000, duration_months: 3)


User.all.each do |user|

