class CreateStockValueErrors < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_value_errors do |t|
      t.text :message

      t.timestamps
    end
  end
end
