class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.datetime :due_date
      t.boolean :paid
      t.datetime :paid_date
      t.references :loan, foreign_key: true

      t.timestamps
    end
  end
end
