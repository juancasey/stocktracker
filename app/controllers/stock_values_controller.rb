class StockValuesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin

    def index
    end

    def run
        CaptureStockValueJob.perform_later false # false to ignore bail outs if we're paused       
        redirect_to stock_values_path, alert: 'Running fetch of stock values'
    end

    def pause
        if (!CaptureStockValueJob::Status.paused)   
            CaptureStockValueJob::Status.paused = true
            CaptureStockSchedulerJob.pause
            redirect_to stock_values_path, alert: 'Paused fetching of stock values'
        else
            redirect_to stock_values_path, alert: "Unable to pause, fetching already paused"
        end
    end

    def resume
        if (CaptureStockValueJob::Status.paused)            
            CaptureStockValueJob::Status.paused = false
            CaptureStockSchedulerJob.schedule
            redirect_to stock_values_path, alert: 'Resumed fetching of stock values'
        else
            redirect_to stock_values_path, alert: "Unable to resume, fetching is not paused"
        end
    end
end
