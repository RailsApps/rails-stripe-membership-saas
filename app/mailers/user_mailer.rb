class UserMailer < ActionMailer::Base
  default :from => "notifications@example.com"

  def expire_email(user)
      mail(:to => user.email, :subject => "Subscription Cancelled")
  end
  
  def thanks_email(user)
      mail(:to => user.email, :subject => "Thank You for your subscription support")
  end
  
end