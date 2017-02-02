class DecreaseDefaultCreditScore < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :credit_score, :string, default: "0.90"
  end
end
