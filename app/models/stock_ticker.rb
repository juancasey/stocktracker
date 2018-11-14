class StockTicker < ApplicationRecord
  belongs_to :stock_list
  has_many :stock_values, :primary_key => :symbol, :foreign_key => :symbol

  def symbol=(value)    
    super(value.nil? ? nil : value.upcase)
  end
end