class UsersController < ApplicationController
    before_action :authorize_admin, only: [:new, :create]

    def create        
        newuser = params[:user];
        user = User.new({ :email => newuser[:email], :password => newuser[:password], :role => newuser[:role].to_i })
        #user = User.new sign_up_params
        if (user.save)
            redirect_to new_user_path, alert: "User #{user.email} created successfully"
        else
            raise 'Unable to save user'
        end
    end
end