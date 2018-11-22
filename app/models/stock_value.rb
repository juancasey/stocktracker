class StockValue < ApplicationRecord
    belongs_to :stock_value_error, optional: true
    belongs_to :stock_capture
end