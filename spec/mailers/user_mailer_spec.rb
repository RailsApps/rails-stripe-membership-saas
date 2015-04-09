require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe '#expire_mail' do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.expire_email(user) }

    it "has the correct user email" do
      expect(mail.to).to eq([user.email])
    end

    it "has the correct senders email" do
      expect(mail.from).to eq(["notifications@example.com"])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq("Subscription Cancelled")
    end
  end

end
