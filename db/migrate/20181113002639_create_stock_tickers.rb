class CreateStockTickers < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_tickers do |t|
      t.string :symbol
      t.string :name
      t.references :stock_list, foreign_key: true

      t.timestamps
    end
  end
end
