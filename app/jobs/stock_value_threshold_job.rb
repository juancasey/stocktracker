class StockValueThresholdJob < ApplicationJob
  queue_as :default

  def perform(stock_values)
    return if stock_values.nil?
    stock_values.each do |value|
      next if !value.stock_value_error_id.nil?
      StockTicker.where(symbol: value.symbol)
      .where("min_threshold >= :current_value OR max_threshold <= :current_value", {current_value: value.close })
      .each do |ticker|
        AlertMailer.with(user: ticker.stock_list.user, ticker: ticker, value: value).stock_value_alert_email.deliver_now
      end
    end
  end
end