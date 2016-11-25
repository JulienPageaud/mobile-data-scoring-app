class AddDefaultInterestRateToLoans < ActiveRecord::Migration[5.0]
  def change
    change_column :loans, :interest_rate, :integer, default: 15
  end
end
