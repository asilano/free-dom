class SignUpMailer < ApplicationMailer
  def welcome
    @user = params[:user]
    mail(to: @user.email, subject: 'Welcome to FreeDom!')
  end

  def new_user
    @user = params[:user]
    mail(to: Rails.configuration.x.admin_email, subject: 'New user at FreeDom!')
  end
end
