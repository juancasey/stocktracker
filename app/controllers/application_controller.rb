class ApplicationController < ActionController::Base

    protected

    def authorize_admin
        return unless (current_user.nil? || !current_user.admin?)
        redirect_to root_path, alert: 'Admins only!'
    end
end