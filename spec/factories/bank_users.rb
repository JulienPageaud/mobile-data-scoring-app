FactoryGirl.define do
  factory :bank_user do |bu|
    bu.association :bank
    bu.email { "fnbemployee@firstnational.com" }
    bu.password { "ilovemoney" }
    bu.first_name { Faker::Name.first_name }
    bu.last_name { Faker::Name.last_name }
  end
end
