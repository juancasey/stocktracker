class StockValueThresholdJob < ApplicationJob
  queue_as :default

  def perform(*args)
    stock_values = args[0]
    stock_values.each do |value|
      StockTicker.where(symbol: value.symbol)
      .where("min_threshold >= :current_value OR max_threshold <= :current_value", {current_value: value.close })
      .each do |ticker|
        AlertMailer.with(user: ticker.stock_list.user, ticker: ticker, value: value).stock_value_alert_email.deliver_now
      end
    end
  end
end
