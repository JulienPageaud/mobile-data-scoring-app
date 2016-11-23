class AddDurationMonthsToLoans < ActiveRecord::Migration[5.0]
  def change
    add_column :loans, :duration_months, :integer, default: 3
  end
end
