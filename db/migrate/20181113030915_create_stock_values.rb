class CreateStockValues < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_values do |t|
      t.string :symbol
      t.datetime :timestamp
      t.decimal :open, precision: 18, scale: 4
      t.decimal :high, precision: 18, scale: 4
      t.decimal :low, precision: 18, scale: 4
      t.decimal :close, precision: 18, scale: 4
      t.integer :volume

      t.timestamps
    end
  end
end
