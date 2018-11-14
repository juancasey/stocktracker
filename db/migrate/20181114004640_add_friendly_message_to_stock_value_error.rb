class AddFriendlyMessageToStockValueError < ActiveRecord::Migration[5.2]
  def change
    add_column :stock_value_errors, :friendly_message, :text
  end
end
