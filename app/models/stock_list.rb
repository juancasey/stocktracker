class StockList < ApplicationRecord
  belongs_to :user
  has_many :stock_tickers, dependent: :destroy
end