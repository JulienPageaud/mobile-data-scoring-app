require 'rails_helper'

describe User do


  context "a new user" do
    subject { FactoryGirl.build(:user) }

    it "has a valid factory" do
      expect(subject).to be_valid
    end

    it "is invalid without a mobile number" do
      subject.mobile_number = nil
      expect(subject).to_not be_valid
    end

    it "is invalid without a password" do
      subject.password = nil
      expect(subject).to_not be_valid
    end

    it "has a unique mobile number" do
      user1 = subject
      user1.save
      user2 = subject.dup
      expect(user2).to_not be_valid
    end
  end

  context "a user completing their details" do
    subject { FactoryGirl.build_stubbed(:user, :with_details)}

    it "has a valid factory" do
      expect(subject).to be_valid
    end

    it "requires a title on update" do
      subject.title = nil
      expect(subject).to_not be_valid
    end

    it "requires a first name on update" do
      subject.first_name = nil
      expect(subject).to_not be_valid
    end

    it "requires a last name on update" do
      subject.last_name = nil
      expect(subject).to_not be_valid
    end

    it "requires an address on update" do
      subject.address = nil
      expect(subject).to_not be_valid
    end

    it "requires a city on update" do
      subject.city = nil
      expect(subject).to_not be_valid
    end

    it "requires a postcode on update" do
      subject.postcode = nil
      expect(subject).to_not be_valid
    end

    it "requires employment details on update" do
      subject.employment = nil
      expect(subject).to_not be_valid
    end

    it "requires a date of birth on update" do
      subject.date_of_birth = nil
      expect(subject).to_not be_valid
    end
  end

  context "with an email address" do
    subject { FactoryGirl.build_stubbed(:user, :with_details, :with_email) }

    it "cannot delete their email" do
      subject.email = nil
      expect(subject).to_not be_valid
    end
  end

  it "returns a user's full name as a string" do
    subject.first_name = 'John'
    subject.last_name = 'Smith'
    expect(subject.full_name).to eql("John Smith")
  end


end
