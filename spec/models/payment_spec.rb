require 'rails_helper'

RSpec.describe Payment, type: :model do
 subject { FactoryGirl.build(:payment) }
  it 'has an amount' do
    subject.amount = nil
    expect(subject).not_to be_valid
  end

  it 'has a due date' do
    subject.due_date = nil
    expect(subject).not_to be_valid
  end

  describe '#missed_payment?' do
    it 'returns true if payment is unpaid and passed its due date'
  end
end
