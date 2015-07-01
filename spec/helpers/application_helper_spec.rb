RSpec.describe ApplicationHelper, type: :helper do
  describe "#page_title" do
    it "returns the default title" do
      visit '/'
      expect(page.title).to eq "Rails Stripe Membership"
    end
  end
end