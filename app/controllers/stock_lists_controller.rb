class StockListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stock_list, only: [:show, :edit, :update, :destroy]  

  # GET /stock_lists
  def index
    if (current_user.admin?)
      @stock_lists = StockList.all.order(:user_id, :name)
    else
      @stock_lists = StockList.where(user: current_user).order(:name)
    end
  end

  # GET /stock_lists/1
  def show
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

    respond_to do |format|
      if @stock_list.save
        format.html { redirect_to @stock_list, notice: 'Stock list was successfully created.' }
        format.json { render :show, status: :created, location: @stock_list }
      else
        format.html { render :new }
        format.json { render json: @stock_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stock_lists/1
  def update
    respond_to do |format|
      if @stock_list.update(stock_list_params)
        format.html { redirect_to @stock_list, notice: 'Stock list was successfully updated.' }
        format.json { render :show, status: :ok, location: @stock_list }
      else
        format.html { render :edit }
        format.json { render json: @stock_list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stock_lists/1
  def destroy
    @stock_list.destroy
    respond_to do |format|
      format.html { redirect_to stock_lists_url, notice: 'Stock list was successfully destroyed.' }
      format.json { head :no_content }
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
end
