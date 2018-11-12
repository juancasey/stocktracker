class UsersController < ApplicationController
    before_action :authorize_admin, only: [:new, :create]

    def create
        newuser = params[:user];
        if (User.invite!(:email => newuser[:email], :role => newuser[:role].to_i))
            redirect_to new_user_path, alert: "User #{newuser[:email]} created successfully"
        else
            redirect_to new_user_path, alert: "Failed to create user #{newuser[:email]}"
        end
    end
end