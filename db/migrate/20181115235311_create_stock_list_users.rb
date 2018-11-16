class CreateStockListUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :stock_list_users do |t|
      t.bigint :stock_list_id
      t.bigint :user_id

      t.timestamps
    end
  end
end
