class StockValuesController < ApplicationController
    def index
        
    end

    def run
        CaptureStockSchedulerJob.perform_later
        redirect_to stock_values_path, alert: 'Running fetch of stock values'
    end
end
