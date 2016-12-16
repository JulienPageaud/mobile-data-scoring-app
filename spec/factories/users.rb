require 'faker'

FactoryGirl.define do
  factory :user do |f|
    f.mobile_number { '+27' + '7' + ('%010d' % rand(10 ** 9)).to_s }
    f.password { Faker::Internet.password(6) }

    trait :with_details do
      title { ['mr', 'mrs', 'ms'].sample }
      first_name { Faker::Name.first_name }
      last_name { Faker::Name.last_name }
      address { Faker::Address.street_address }
      city { Faker::Address.city }
      postcode { Faker::Address.postcode }
      employment { Faker::Company.profession }
      date_of_birth { Faker::Date.between(65.years.ago, 18.years.ago) }
    end

    trait :with_email do
      email { Faker::Internet.free_email }
    end

    trait :details_complete do
      details_completed { true }
    end
  end
end
