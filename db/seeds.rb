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

Loan.create( user_id: 1, status: , category: "personal", purpose)


User.all.each do |user|

