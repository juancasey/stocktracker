class AddErrorToStockValue < ActiveRecord::Migration[5.2]
  def change
    add_column :stock_values, :stock_value_error_id, :bigint
  end
end
