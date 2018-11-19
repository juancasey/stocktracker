class AlertMailer < ApplicationMailer
    default from: 'alerts@localhost'

    def stock_value_alert_email
        @user = params[:user]
        @ticker = params[:ticker]
        @value = params[:value]
        mail(to: @user.email, subject: 'Stock Value Alert')        
    end
end