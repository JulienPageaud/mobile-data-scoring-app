require 'faker'

FactoryGirl.define do
  factory :user do |f|
    f.mobile_number { '+27' + '7' + ('%010d' % rand(10 ** 9)).to_s }
    f.password { Faker::Internet.password(6) }
  end
end
