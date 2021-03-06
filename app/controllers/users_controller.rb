class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin, only: [:new, :create, :index]

    def index
        @users = User.all
    end

    def create
        newuser = params[:user];
        if (User.invite!(:email => newuser[:email], :role => newuser[:role].to_i))
            redirect_to new_user_path, alert: "User #{newuser[:email]} created successfully"
        else
            redirect_to new_user_path, alert: "Failed to create user #{newuser[:email]}"
        end
    end
end