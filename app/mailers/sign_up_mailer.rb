class SignUpMailer < ApplicationMailer
  def welcome
    @user = params[:user]
    mail(to: @user.email, subject: 'Welcome to FreeDom!')
  end
end
