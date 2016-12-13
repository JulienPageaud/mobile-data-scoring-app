require 'rails_helper'

describe User do

  it "has a valid factory" do
    expect(FactoryGirl.build(:user)).to be_valid
  end

  it "is invalid without a mobile_number" do
    expect(FactoryGirl.build(:user, mobile_number: nil)).to_not be_valid
  end

  it "is invalid without a password" do
    expect(FactoryGirl.build(:user, password: nil)).to_not be_valid
  end

  it "returns a user's full name as a string" do
    john_smith = User.create!(
      mobile_number: '+27123123123',
      password: '123123', first_name: 'john',
      last_name: 'smith'
    )
    expect(john_smith.full_name).to eql("John Smith")
  end
end
