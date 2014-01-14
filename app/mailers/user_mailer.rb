class UserMailer < ActionMailer::Base
  default :from => ENV['ADMIN_EMAIL']
  
  def expire_email(user)
    mail(:to => user.email, :subject => "Subscription Cancelled")
  end

  def verify_email(user)
    @user = user
    mail(:to => user.email, :subject => "Please Verify Your #{user.roles.first.name.capitalize} Membership on the #{ENV['TYPE']} Dashboard from #{ENV['NAME']}")
  end
end