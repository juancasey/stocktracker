class CreateStockCaptures < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_captures do |t|
      t.integer :error_count
      t.integer :success_count            
      t.datetime :run_at
      t.text :message      

      t.timestamps
    end
  end
end
