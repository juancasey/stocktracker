class StockList < ApplicationRecord
  belongs_to :user
  has_many :stock_tickers, dependent: :destroy
  has_many :stock_list_users, dependent: :destroy
  has_many :users, :through => :stock_list_users

end