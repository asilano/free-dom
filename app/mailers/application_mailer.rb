class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.x.admin_email
  layout 'mailer'
end
