class MailingListSignupJob < ActiveJob::Base

  def perform(user)
    logger.info "signing up #{user.email}"
    user.subscribe
  end

end
