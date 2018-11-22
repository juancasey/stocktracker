class StockListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stock_list, only: [:show, :chart, :edit, :update, :destroy]
  before_action only: [:show, :chart] do check_user_is_authorized(true) end
  before_action only: [:edit, :update, :destroy] do check_user_is_authorized(false) end

  # GET /stock_lists
  def index
    if (current_user.admin?)
      # Get all stock lists (with those belonging to the current user first)
      @stock_lists = StockList.includes(:user).all.
        order("CASE WHEN user_id = #{current_user.id} THEN 1 ELSE 2 END", 'users.email', :name)
    else
      # Get only stock lists belonging to the current user
      @stock_lists = StockList.includes(:user)
        .joins(:user)
        .joins(:stock_list_users)
        .where({ stock_list_users: { user_id: current_user.id }})
        .order("CASE WHEN stock_lists.user_id = #{current_user.id} THEN 1 ELSE 2 END", 'users.email', :name)      
    end
  end

  # GET /stock_lists/1
  def show    
    
  end

  def chart
    # Get the date range for our last ten captures
    captures = StockCapture.all.order(run_at: :desc).limit(5)
    run_at_from = captures.pluck(:run_at).last
    run_at_to = captures.pluck(:run_at).first

    # Retrieve the required data
    data = @stock_list.stock_tickers.joins(:stock_values).joins(:stock_values => :stock_capture)      
      .where({ stock_captures: { run_at: run_at_from..run_at_to }})
      .select(:run_at, :symbol, :close)

    # Pivot the data to match the graphing format
    pivoted = PivotTable::Grid.new do |g|
      g.source_data  = data
      g.column_name  = :symbol
      g.row_name     = :run_at
      g.value_name   = :close
    end.build

    # Map the pivoted data into a simple array we can send to the client
    array = pivoted.rows.map do |row|
      row.data.map { |r| r.close.nil? ? nil : r.close.to_f }
      .unshift(row.header.try(:in_time_zone, 'Eastern Time (US & Canada)').try(:strftime, "%F %H:%M"))
    end.unshift(['Run At'] + pivoted.column_headers)

    @chart_data = JSON.generate(array)
  end

  # GET /stock_lists/new
  def new
    @stock_list = StockList.new
  end

  # GET /stock_lists/1/edit
  def edit
  end

  # POST /stock_lists
  def create
    @stock_list = StockList.new(stock_list_params)
    @stock_list.user_id = current_user.id
    @stock_list.stock_list_users.build({user_id: current_user.id})

    respond_to do |format|
      if @stock_list.save
        format.html { redirect_to edit_stock_list_path(@stock_list), notice: 'Stock list was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /stock_lists/1
  def update
    respond_to do |format|
      if @stock_list.update(stock_list_params)
        format.html { redirect_to @stock_list, notice: 'Stock list was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /stock_lists/1
  def destroy
    @stock_list.destroy
    respond_to do |format|
      format.html { redirect_to stock_lists_url, notice: 'Stock list was successfully deleted.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock_list
      @stock_list = StockList.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_list_params
      params.require(:stock_list).permit(:name, :description, :user_id)
    end

    def user_is_authorized(allow_admin)
      admin_permission = allow_admin && current_user.admin?;      
      return (!current_user.nil? && (@stock_list.user_id == current_user.id || admin_permission))
    end

    def check_user_is_authorized(allow_admin)
      return unless !user_is_authorized(allow_admin)
      redirect_to root_path, alert: 'Permission denied'
    end

    helper_method :user_is_authorized
end