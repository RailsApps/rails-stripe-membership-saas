class User < ActiveRecord::Base
  enum role: [:user, :admin, :silver, :gold, :platinum]
  after_initialize :set_default_role, :if => :new_record?
  after_initialize :set_default_plan, :if => :new_record?
  # after_create :sign_up_for_mailing_list

  belongs_to :plan
  validates_associated :plan

  def set_default_role
    self.role ||= :user
  end

  def set_default_plan
    self.plan ||= Plan.last
  end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def sign_up_for_mailing_list
    MailingListSignupJob.perform_later(self)
  end

  def subscribe
    mailchimp = Gibbon::Request.new(api_key: Rails.application.secrets.mailchimp_api_key)
    list_id = Rails.application.secrets.mailchimp_list_id
    result = mailchimp.lists(list_id).members.create(
      body: {
        email_address: self.email,
        status: 'subscribed'
    })
    Rails.logger.info("Subscribed #{self.email} to MailChimp") if result
  end

end
