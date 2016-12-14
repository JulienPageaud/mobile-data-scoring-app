require 'rails_helper'

describe BankUser do
  it "has an email" do
    expect(FactoryGirl.build(:bank_user, email: nil)).to_not be_valid
  end

  it "has a password" do
    expect(FactoryGirl.build(:bank_user, password: nil)).to_not be_valid
  end

  it "has a first name" do
    expect(FactoryGirl.build(:bank_user, first_name: nil)).to_not be_valid
  end

  it "has a last name" do
    expect(FactoryGirl.build(:bank_user, last_name: nil)).to_not be_valid
  end

  describe '#full_name' do
    subject { FactoryGirl.build(:bank_user,
      first_name: 'John',
      last_name: 'Smith')}

    it 'responds to this method' do
      expect(subject).to respond_to(:full_name)
    end

    it "returns the users full name" do
      expect(subject.full_name).to eql('John Smith')
    end
  end
end
