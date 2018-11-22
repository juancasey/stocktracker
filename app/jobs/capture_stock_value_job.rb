class CaptureStockValueJob < ApplicationJob
  queue_as :default

  @@error_hash = Hash.new(0)

  class Status
    # Use getters/setters because we should probably move this to a cache or DB
    @@status = :idle
    @@paused = false

    def self.status
      @@status
    end
    def self.status=(val)
      @@status = val
    end

    def self.paused
      @@paused
    end
    def self.paused=(val)
      @@paused = val
    end
  end

  def perform(cancellable = true)
    # Don't start if we are cancelled
    return if (cancellable && is_cancelled)

    CaptureStockValueJob::Status.status = :running

    # Get a distinct list of all symbols tracked by users
    symbols = StockTicker.distinct.pluck(:symbol)

    # Parameters required for making the service call
    url = Rails.configuration.x.stock_query.url
    function = Rails.configuration.x.stock_query.function
    interval = Rails.configuration.x.stock_query.interval
    apikey = Rails.configuration.x.stock_query.apikey

    # Just one friendly error for now, could customize the error based on what happened later
    friendly_error = "The system was unable to retrieve the stock value at this time";

    # Keep a list of retrieved stock values so we can send alerts
    stock_capture = StockCapture.new({ run_at: Time.now.utc, success_count: 0, error_count: 0 })
    stock_values = Array.new

    # For each symbol make a call to the API and retrieve the latest stock data
    symbols.each do |symbol|
      begin
        # We can bail out part way through the retrieval process
        return if (cancellable && is_cancelled)        

        response = RestClient.get url, {params: {function: function, symbol: symbol, interval: interval, apikey: apikey}}
        if ((200..207).include?(response.code))
          result = JSON.parse response.body
          # If the service provided data for the current symbol make a StockValue with the details
          if (result['Error Message'].nil? && result['Note'].nil?)
            timeseries = result["Time Series (#{interval})"]
            key = timeseries.keys[0]            
            timestamp = ActiveSupport::TimeZone["EST"].parse(key)
            v = timeseries[key]
            stock_capture.stock_values.build({symbol: symbol, timestamp: timestamp, open: v['1. open'], high: v['2. high'], low: v['3. low'], close: v['4. close'], volume: v['5. volume'] })            
            stock_capture.success_count += 1
          else
            message = result['Error Message'].nil? ? result['Note'] : result['Error Message'];
            stock_error(stock_capture, symbol, message, friendly_error)
          end
        else
          stock_error(stock_capture, symbol,"Unexpected HTTP response #{response.code}",friendly_error)
        end        
      rescue => ex
        stock_error(stock_capture, symbol,ex.message,friendly_error)
      end      
    end
    
    # Last chance to bail out
    return if (cancellable && is_cancelled)

    # Save all retrieved stock values / errors
    CaptureStockValueJob::Status.status = :saving
    stock_capture.save
    CaptureStockValueJob::Status.status = :idle

    # Send threshold notifications
    StockValueThresholdJob.perform_later(stock_capture.id)
  end

  def is_cancelled
    cancelled = CaptureStockValueJob::Status.paused
    if (cancelled)
      CaptureStockValueJob::Status.status = :aborted
    end
    return cancelled
  end

  # Create a new stock value with the error that occurred
  def stock_error(stock_capture, symbol, message, friendly_message)
    error_id = get_error_code(message, friendly_message)
    stock_capture.stock_values.build({symbol: symbol, stock_value_error_id: error_id})
    stock_capture.error_count += 1
  end

  # Get the error code for a message, add it to the database if it doesn't already exist
  # Maintians @@error_hash so we don't have to hit the database every time an error occurss
  def get_error_code(message, friendly_message)
    if (@@error_hash.count == 0)
      StockValueError.all.each do |error|
        @@error_hash[error.message] = error.id
      end
    end
    if (!@@error_hash.key?(message))
      error = StockValueError.where(message: message).first
      if (error.nil?)
        error = StockValueError.new({message: message, friendly_message: friendly_message})
        error.save
      end
      @@error_hash[error.message] = error.id
    end

    @@error_hash[message]
  end
end
