class UpdateCreditScoreToHigherValueDefaultUsers < ActiveRecord::Migration[5.0]
  def change
    change_column :users, :credit_score, :string, default: 0.98
  end
end
