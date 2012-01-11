class UserMailer < ActionMailer::Base
  default :from => 'Free-Dom <chowlett09+free-dom@gmail.com>'

  def password_reset(user, new_pass)
    @user = user
    @new_pass = new_pass
    
    mail :subject => 'free-dom password reset',
         :to => user.email
  end

  def announce(user, text, options = {})
    @user = user
    @text = text
    
    mail :subject => options[:subject] || "free-dom Announcement",
         :to => user.email
  end
  
end
