class ApplicationMailer < ActionMailer::Base
  default from: "FreeDom <#{Rails.configuration.x.admin_email}>"
  layout 'mailer'
end
