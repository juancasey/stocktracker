class StockList < ApplicationRecord
  belongs_to :user
  has_many :stock_tickers, dependent: :destroy
  has_many :stock_list_users, dependent: :destroy
  has_many :users, :through => :stock_list_users

  def self.chart(id)
    sql = <<-SQL
    SELECT * FROM
    (SELECT        
      sc.run_at
      , st.symbol
      , sv.close
      , row_number() OVER(PARTITION BY st.symbol ORDER BY sc.run_at DESC) AS rownum
    FROM stock_lists s
    INNER JOIN stock_tickers st on st.stock_list_id = s.id
    INNER JOIN stock_values sv on sv.symbol = st.symbol
    INNER JOIN stock_captures sc on sc.id = sv.stock_capture_id
    WHERE s.id = :id
    ORDER BY sc.run_at, st.symbol) as tmp
    WHERE tmp.rownum <= :data_points
    SQL

    results = find_by_sql([sql, {id: id, data_points: 5}]).map do |row|
      { :run_at => row['run_at'], :symbol => row['symbol'], :close => row['close'], :rownum => row['rownum'] }
    end

    # Map the data into google charts format

    headers = results.map { |r| r[:symbol] }.uniq
    headers.unshift('Run At')

    hash = Hash.new { |hash,key| hash[key] = Array.new(headers.length) }
    results.each do |row|
      hash[row[:run_at]][0] = row[:run_at]
      hash[row[:run_at]][headers.index(row[:symbol])] = row[:close].to_f #to_f to avoid string encoding in JSON
    end

    array = [headers]
    hash.each { |key,values| array.push(values) }
    return array    
  end
end