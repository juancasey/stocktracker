class AddStockCaptureIdToStockValues < ActiveRecord::Migration[5.2]
  def change
    add_reference :stock_values, :stock_capture, index: true    
  end
end