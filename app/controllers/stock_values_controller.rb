class StockValuesController < ApplicationController
    def index        
    end

    def run
        CaptureStockSchedulerJob.perform_later
        redirect_to stock_values_path, alert: 'Running fetch of stock values'
    end

    def pause
        CaptureStockValueJob::Status.paused = true
        redirect_to stock_values_path, alert: 'Pausing fetch of stock values'
    end

    def resume
        CaptureStockValueJob::Status.paused = false
        redirect_to stock_values_path, alert: 'Resuming fetch of stock values'
    end
end
