class Visitor < ActiveRecord::Base
  validates_presence_of :email
  validates :email, format: /.+@.+\..+/i
  # ^^^^ rubocop format preference
  # validates_format_of :email, with: /.+@.+\..+/i
  # ^^^^ https://davidcel.is/posts/stop-validating-email-addresses-with-regex/
  # validates_format_of :email, :with => /\A[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}\z/i
  after_create :subscribe

  def visitor_subscribe
    begin
      mailchimp = Gibbon::Request.new(api_key: Rails.application.secrets.mailchimp_api_key)
      list_id = Rails.application.secrets.mailchimp_list_id
      result = mailchimp.lists(list_id).members.create(
        body: {
          email_address: self.email,
          status: 'subscribed'
        })
      Rails.logger.info("Subscribed #{self.email} to MailChimp") if result
    rescue Gibbon::MailChimpError => e
      return ('/visitors/new'), flash: { error: e.message }
    end
  end
end
