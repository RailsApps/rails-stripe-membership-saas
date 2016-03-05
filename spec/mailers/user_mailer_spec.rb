describe UserMailer do
  describe '#expire_mail' do
    let(:user) { FactoryGirl.create(:user, email: 'johnny@appleseed.com') }
    let(:mail) { UserMailer.expire_email(user) }

    it "has the correct user email" do
      expect(mail.to).to eq([user.email])
    end

    it "has the correct senders email" do
      expect(mail.from).to eq(["do-not-reply@example.com"])
    end

    it "has the correct subject" do
      expect(mail.subject).to eq "Subscription Cancelled"
    end
  end
end