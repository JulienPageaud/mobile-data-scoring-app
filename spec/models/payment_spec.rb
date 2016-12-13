require 'rails_helper'

RSpec.describe Payment, type: :model do
  it 'has an amount'

  it 'has a due date'

  describe '#missed_payment?' do
    it 'returns true if payment is unpaid and passed its due date'
  end
end
