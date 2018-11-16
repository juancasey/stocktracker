class StockListUser < ApplicationRecord
    belongs_to :stock_list
    belongs_to :user
end
