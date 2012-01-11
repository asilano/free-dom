require File.dirname(__FILE__) + '/../test_helper'

class UserMailerTest < ActionMailer::TestCase
  should "send password reset email" do
    user = Factory(:user)
    new_pass = "new_pass"
    email = UserMailer.password_reset(user, new_pass).deliver
    assert_same_elements [user.email], email.to
    assert_equal 'free-dom password reset', email.subject
    assert_match(/new password.*recommend you change.*New Password: #{new_pass}/m, email.encoded)
  end

  should "send announcement email" do
    user = Factory(:user)
    news = "Something happened"
    email = UserMailer.announce(user, news).deliver
    assert_same_elements [user.email], email.to
    assert_equal 'free-dom Announcement', email.subject
    assert_match(/#{user.name}.*#{news}/m, email.encoded)
  end
  
  should "send announcement email with specified subject" do
    user = Factory(:user)
    subj = "Funky events!"
    news = "Something happened"
    email = UserMailer.announce(user, news, :subject => subj).deliver
    assert_same_elements [user.email], email.to
    assert_equal subj, email.subject
    assert_match(/#{user.name}.*#{news}/m, email.encoded)
  end
  
end
