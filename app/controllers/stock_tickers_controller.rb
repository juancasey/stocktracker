class StockTickersController < ApplicationController
    before_action :authenticate_user!

    def create
        @stock_list = StockList.find(params[:stock_list_id])
        stock_ticker = @stock_list.stock_tickers.create(stock_ticker_params)
        redirect_to edit_stock_list_path(@stock_list)
    end
    
    private
        def stock_ticker_params
            params.require(:stock_ticker).permit(:symbol, :name)
        end
end