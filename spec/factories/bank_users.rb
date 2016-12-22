FactoryGirl.define do
  factory :bank_user do |bu|
    bu.association :bank
    bu.email { "fnbemployee@firstnational.com" }
    bu.password { "ilovemoney" }
    bu.first_name { 'John' }
    bu.last_name { 'Snow' }
  end
end
