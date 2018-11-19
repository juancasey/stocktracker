class AddMinThresholdMaxThresholdToStockTickers < ActiveRecord::Migration[5.2]
  def change
    add_column :stock_tickers, :min_threshold, :decimal, precision: 18, scale: 4
    add_column :stock_tickers, :max_threshold, :decimal, precision: 18, scale: 4
  end
end
