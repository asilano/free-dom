# Preview all emails at http://localhost:3000/rails/mailers/sign_up_mailer
class SignUpMailerPreview < ActionMailer::Preview
  def welcome
    SignUpMailer.with(user: User.first_or_create(email: "alan@example.com", name: "Alan")).welcome
  end

  def new_user
    SignUpMailer.with(user: User.first_or_create(email: "alan@example.com", name: "Alan")).new_user
  end
end
