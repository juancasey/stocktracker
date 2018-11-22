class StockCapture < ApplicationRecord
    has_many :stock_values, dependent: :destroy
end
