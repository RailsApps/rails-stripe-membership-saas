class Visitor < ActiveRecord::Base
  validates_presence_of :email
  validates_format_of :email, :with => /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i
  after_create :subscribe
    
  def subscribe
    begin
      mailchimp = Gibbon::API.new(Rails.application.secrets.mailchimp_api_key)
      result = mailchimp.lists.subscribe({
        :id => Rails.application.secrets.mailchimp_list_id,
#PRODO  :email => {:email => self.email},  # 20150123 added below for test purposes, restore this line before next push to production
        :email => {:email => "testables@goodworksonearth.org"},
        :double_optin => false,
        :update_existing => true,
        :send_welcome => true
      })
      Rails.logger.info("Subscribed #{self.email} to MailChimp") if result
    rescue Gibbon::MailChimpError => e
    #return redirect_to root_path, :flash => { error: e.message }
    return ('/visitors/new'), :flash => { error: e.message }
    end
  end

end
    