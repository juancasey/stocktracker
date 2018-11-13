class CaptureStockValueJob < ApplicationJob
  queue_as :default

  def perform(*args)    
    symbols = StockTicker.distinct.pluck(:symbol)

    url = 'https://www.alphavantage.co/query'
    function = 'TIME_SERIES_INTRADAY'
    interval = '1min'
    apikey = '1GCARTDKFWV02E4C'

    symbols.each do |symbol|
      response = RestClient.get url, {params: {function: function, symbol: symbol, interval: interval, apikey: apikey}}
      if (response.code == 200)
        result = JSON.parse response.body
        if (result['Error Message'].nil?)
          timestamp = result['Time Series (1min)'].first[0]
          v = result['Time Series (1min)'].first[1]
          stockvalue = StockValue.new({symbol: symbol, timestamp: timestamp, open: v['1. open'], high: v['2. high'], low: v['3. low'], close: v['4. close'], volume: v['5. volume'] })
          saved = stockvalue.save
        end
      else
        # do something here
      end
    end
  end
end
