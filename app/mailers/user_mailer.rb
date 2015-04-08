class UserMailer < ActionMailer::Base
  default :from => "do-not-reply@example.com"

  def expire_email(user)
    mail(:to => user.email, :subject => "Subscription Cancelled")
  end
end
