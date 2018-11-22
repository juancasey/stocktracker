class StockCapturesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin
  
  def index
    @stock_captures = StockCapture.all.order(id: :desc)
  end
end