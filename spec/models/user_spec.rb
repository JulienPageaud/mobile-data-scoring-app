require 'rails_helper'

describe User do

  it "has a valid factory" do
    expect(FactoryGirl.build(:user)).to be_valid
  end

  context "a new user" do
    subject { FactoryGirl.build(:user) }


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

    it "must enter a title" do
      subject.title = nil
      expect(subject).to_not be_valid
    end

    it "must enter a first name" do
      subject.first_name = nil
      expect(subject).to_not be_valid
    end

    it "must enter a last name" do
      subject.last_name = nil
      expect(subject).to_not be_valid
    end

    it "must enter an address" do
      subject.address = nil
      expect(subject).to_not be_valid
    end

    it "must enter a city" do
      subject.city = nil
      expect(subject).to_not be_valid
    end

    it "must enter a postcode" do
      subject.postcode = nil
      expect(subject).to_not be_valid
    end

    it "must enter their employment" do
      subject.employment = nil
      expect(subject).to_not be_valid
    end

    it "must enter their date of birth" do
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

  it "has many loans" do
    expect(User.reflect_on_association(:loans).macro).to eql(:has_many)
  end

  it "has many notifications" do
    expect(User.reflect_on_association(:notifications).macro).to eql(:has_many)
  end

  describe '#full_name ' do
    it "returns a user's full name" do
      subject.first_name = 'John'
      subject.last_name = 'Smith'
      expect(subject.full_name).to eql("John Smith")
    end
  end
end
