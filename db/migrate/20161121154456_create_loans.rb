class CreateLoans < ActiveRecord::Migration[5.0]
  def change
    create_table :loans do |t|
      t.string :status
      t.string :type
      t.string :purpose
      t.string :description
      t.integer :interest_rate
      t.datetime :start_date
      t.datetime :final_date
      t.references :bank, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
