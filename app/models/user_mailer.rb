class UserMailer < ActionMailer::Base
  

  def password_reset(user, new_pass)
    subject    'free-dom password reset'
    recipients user.email
    from       'Free-Dom <chowlett09+free-dom@gmail.com>'
    sent_on    Time.now
    body       :user => user, :new_pass => new_pass
  end

  def announce(user, text, options = {})
    subject    options[:subject] || "free-dom Announcement"
    recipients user.email
    from       'Free-Dom <chowlett09+free-dom@gmail.com>'
    sent_on    Time.now
    body       :user => user, :body => text
  end
  
end
