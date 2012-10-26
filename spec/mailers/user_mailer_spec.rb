require "spec_helper"

describe UserMailer do
  describe '#expire_mail' do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.expire_email(user) }

    it "has the correct user email" do
      mail.to.should == [user.email]
    end

    it "has the correct senders email" do
      mail.from.should == ["notifications@example.com"]
    end

    it "has the correct subject" do
      mail.subject.should == "Subscription Cancelled"
    end

  end
end
