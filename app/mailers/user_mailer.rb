class UserMailer < ActionMailer::Base
  AdminAddr = 'chowlett09+free-dom@gmail.com'
  default :from => "Free-Dom <#{AdminAddr}>"

  def password_reset(user, new_pass)
    @user = user
    @new_pass = new_pass

    mail :subject => 'free-dom password reset',
         :to => user.email
  end

  def announce(user, text, options = {})
    @user = user
    @text = text
    @override = options[:override]

    mail :subject => options[:subject] || "free-dom Announcement",
         :to => user.email
  end

  def registered(user)
    @user = user

    mail :subject => 'Registration successful at free-dom',
         :to => user.email
  end

  def report_registered(user)
    @new_user = user

    mail :subject => 'New user at free-dom',
         :to => AdminAddr
  end
end
