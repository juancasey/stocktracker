class StockListUsersController < ApplicationController
    def create
        @stock_list = StockList.find(params[:stock_list_id])
        authorize
        
        email = stock_list_user_params[:email]
        user = User.where(email: email).first        

        # Error if user cannot be found or user is current_user
        if (user.nil?)
            redirect_to edit_stock_list_path(@stock_list), alert: "User not found: #{email}" and return
        elsif (user.id == current_user.id)
            redirect_to edit_stock_list_path(@stock_list), alert: "Stock lists cannot be shared with their owner" and return
        end
        
        # Error if list already shared with user
        shared = StockListUser.where(user_id: user.id).where(stock_list_id: @stock_list.id).first
        if (!shared.nil?)
            redirect_to edit_stock_list_path(@stock_list), alert: "The stock list is already shared with #{email}" and return
        end
        
        # Add the target user to stock_list_users
        stock_list_user = @stock_list.stock_list_users.create({stock_list_id: @stock_list.id, user_id: user.id})
        redirect_to edit_stock_list_path(@stock_list)
    end
    
    def destroy
        @stock_list_user = StockListUser.find(params[:id])
        @stock_list = @stock_list_user.stock_list
        authorize

        @stock_list_user.destroy
        redirect_to edit_stock_list_path(@stock_list)
    end
    
    private
        def authorize
            if (@stock_list.user_id != current_user.id)
                redirect_to root_path, alert: 'Permission denied'
            end
        end

        def stock_list_user_params
            params.require(:stock_list_user).permit(:stock_list_id, :email)
        end
end
