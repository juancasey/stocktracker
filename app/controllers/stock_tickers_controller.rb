class StockTickersController < ApplicationController
    before_action :authenticate_user!

    def create
        @stock_list = StockList.find(params[:stock_list_id])
        authorize
        
        stock_ticker = @stock_list.stock_tickers.create(stock_ticker_params)
        redirect_to edit_stock_list_path(@stock_list)
    end

    def destroy
        @stock_ticker = StockTicker.find(params[:id])
        @stock_list = @stock_ticker.stock_list
        authorize

        @stock_ticker.destroy
        redirect_to edit_stock_list_path(@stock_list)
    end
    
    private
        def authorize
            if (@stock_list.user_id != current_user.id)
                redirect_to root_path, alert: 'Permission denied'
            end
        end

        def stock_ticker_params
            params.require(:stock_ticker).permit(:symbol, :name)
        end
end