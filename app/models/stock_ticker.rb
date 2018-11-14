class StockTicker < ApplicationRecord
  belongs_to :stock_list
  has_many :stock_values, :primary_key => :symbol, :foreign_key => :symbol
end