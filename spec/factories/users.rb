require 'faker'

FactoryGirl.define do
  factory :user do |f|
    f.mobile_number { '+27' + '7' + ('%010d' % rand(10 ** 9)).to_s }
    f.password { Faker::Internet.password(6) }

    trait :with_details do
      f.title { ['mr', 'mrs', 'ms'].sample }
      f.first_name { Faker::Name.first_name }
      f.last_name { Faker::Name.last_name }
      f.address { Faker::Address.street_address }
      f.city { Faker::Address.city }
      f.postcode { Faker::Address.postcode }
      f.employment { Faker::Company.profession }
      f.date_of_birth { Faker::Date.between(65.years.ago, 18.years.ago) }
    end

    trait :with_email do
      f.email { Faker::Internet.free_email }
    end
  end
end
