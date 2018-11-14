class CaptureStockValueJob < ApplicationJob
  queue_as :default

  def perform(*args)    
    symbols = StockTicker.distinct.pluck(:symbol)

    url = 'https://www.alphavantage.co/query'
    function = 'TIME_SERIES_INTRADAY'
    interval = '1min'
    apikey = '1GCARTDKFWV02E4C'
    friendly_error = "The system was unable to retrieve the stock value at this time";

    symbols.each do |symbol|
      begin
        response = RestClient.get url, {params: {function: function, symbol: symbol, interval: interval, apikey: apikey}}
        if ((200..207).include?(response.code))
          result = JSON.parse response.body
          if (result['Error Message'].nil?)
            timestamp = result['Time Series (1min)'].first[0]
            v = result['Time Series (1min)'].first[1]
            stockvalue = StockValue.new({symbol: symbol, timestamp: timestamp, open: v['1. open'], high: v['2. high'], low: v['3. low'], close: v['4. close'], volume: v['5. volume'] })
            saved = stockvalue.save
          else
            stockvalue = stock_error(symbol,result['Error Message'],friendly_error)
          end
        else
          stockvalue = stock_error(symbol,"Unexpected HTTP response #{response.code}",friendly_error)
        end        
      rescue => ex
        stockvalue = stock_error(symbol,ex.message,friendly_error)
      end
      if (!stockvalue.nil?)
        saved = stockvalue.save
      end
    end
  end

  def stock_error(symbol, message, friendly_message)
    error_id = on_error(message, friendly_message)
    StockValue.new({symbol: symbol, stock_value_error_id: error_id})
  end

  @@error_hash = Hash.new(0)
  def on_error(message, friendly_message)
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
