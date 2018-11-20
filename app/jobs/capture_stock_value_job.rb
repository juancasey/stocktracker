class CaptureStockValueJob < ApplicationJob
  queue_as :default

  @@error_hash = Hash.new(0)

  def perform(*args)
    # Don't start if we are cancelled
    return if is_cancelled

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
    stock_values = Array.new

    # For each symbol make a call to the API and retrieve the latest stock data
    symbols.each do |symbol|
      begin
        # We can bail out part way through the retrieval process
        return if is_cancelled

        response = RestClient.get url, {params: {function: function, symbol: symbol, interval: interval, apikey: apikey}}
        if ((200..207).include?(response.code))
          result = JSON.parse response.body
          # If the service provided data for the current symbol make a StockValue with the details
          if (result['Error Message'].nil?)
            timestamp = ActiveSupport::TimeZone["EST"].parse(result["Time Series (#{interval})"].first[0])
            v = result["Time Series (#{interval})"].first[1]
            stock_values.push StockValue.new({symbol: symbol, timestamp: timestamp, open: v['1. open'], high: v['2. high'], low: v['3. low'], close: v['4. close'], volume: v['5. volume'] })            
          else
            stock_values.push stock_error(symbol,result['Error Message'],friendly_error)
          end
        else
          stock_values.push stock_error(symbol,"Unexpected HTTP response #{response.code}",friendly_error)
        end        
      rescue => ex
        stock_values.push stock_error(symbol,ex.message,friendly_error)
      end      
    end
    
    # Last chance to bail out
    return if is_cancelled

    # Save all retrieved stock values / errors
    save_stock_values(stock_values)

    # Send threshold notifications
    StockValueThresholdJob.perform_later(stock_values)
  end

  def is_cancelled
    false
  end

  def save_stock_values(stock_values)    
    # Consider saving an atomic operation that cannot be cancelled
    StockValue.transaction do # Save in one transaction to reduce DB time
      stock_values.each do |stock_value|
        if (!stock_value.nil?)
          stock_value.save
        end
      end
    end
  end

  # Create a new stock value with the error that occurred
  def stock_error(symbol, message, friendly_message)
    error_id = get_error_code(message, friendly_message)
    StockValue.new({symbol: symbol, stock_value_error_id: error_id})
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
