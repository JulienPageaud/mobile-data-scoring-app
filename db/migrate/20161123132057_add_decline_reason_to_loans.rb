class AddDeclineReasonToLoans < ActiveRecord::Migration[5.0]
  def change
    add_column :loans, :decline_reason, :string
  end
end
