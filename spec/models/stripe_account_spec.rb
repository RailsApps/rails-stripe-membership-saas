require 'spec_helper'

describe StripeAccount do

  describe "#stripe_params" do
    it "returns a hash of params for stripe" do
      user = FactoryGirl.create(:user, email: "test@example.com")
      user.stub_chain(:roles, :first, :name).and_return("Silver")
      StripeAccount.new(user).stripe_params.should == {
        :email=>"test@example.com",
        :description=>"Test User",
        :card=>nil,
        :plan=>"Silver"
      }
    end
  end

  describe "#cancel_customer" do
    before do
      user = FactoryGirl.create(:user, email: "test@example.com", customer_id: '12345')
      @account = StripeAccount.new(user)
      @customer = double(:customer, deleted: deleted)
      @customer.stub_chain("subscription.status").and_return("active")
      Stripe::Customer.stub(:retrieve).and_return(@customer)
    end

    context "with a deleted customer" do
      let(:deleted) { true }
      it "returns nil" do
        @account.cancel_customer.should be_nil
      end
    end

    context "with a found customer" do
      let(:deleted) { false }
      it "cancels the customer" do
        expect{@customer.to_recieve(:cancel_subscription)}
        @account.cancel_customer
      end
    end
  end

  describe ".cancel" do
    before do
      @user = FactoryGirl.create(:user, email: "test@example.com", customer_id: '12345')
      customer = double(:customer, deleted: true)
      Stripe::Customer.stub(:retrieve).and_return(customer)
    end

    it "deletes the user from the database" do
      expect{ StripeAccount.cancel(@user) }.to change{ User.count }.by(-1)
    end
  end

  describe '#create_customer' do

    context 'with stripe token not present' do
      it "raises an error if stripe token is not present" do
        user = double(:user, stripe_token: '')
        expect{StripeAccount.create(user)}.to raise_error
      end
    end

    context 'with stripe token present' do
      let(:stripe_account) { StripeAccount.new(user) }
      let(:user) do
        FactoryGirl.create(:user,
                           email: "test@example.com",
                           stripe_token: '54321',
                           name: 'tester',
                           coupon: coupon)
      end
      before do
        successful_stripe_response = StripeHelper::Response.new("success")
        Stripe::Customer.stub(:create).and_return(successful_stripe_response)
        role = FactoryGirl.create(:role, name: "silver")
        user.add_role(role.name)
      end

      context 'user without a coupon' do
        let(:coupon) {""}
        it "creates a user without coupon" do
          stripe_account.should_receive(:create_customer_without_coupon)
          stripe_account.create_customer
        end
      end

      context 'user with a coupon' do
        let(:coupon) {"free-month"}
        it "creates a user without coupon" do
          stripe_account.should_receive(:create_customer_with_coupon)
          stripe_account.create_customer
        end
      end
    end

    describe 'create_customer_without_coupon' do
      let(:user) do
        FactoryGirl.create(:user,
                           email: "test@example.com",
                           stripe_token: '54321',
                           name: 'tester',
                           coupon: '')
      end
      before do
        successful_stripe_response = StripeHelper::Response.new("success")
        Stripe::Customer.stub(:create).and_return(successful_stripe_response)
        role = FactoryGirl.create(:role, name: "silver")
        user.add_role(role.name)
      end
      let(:stripe_account) { StripeAccount.new(user) }

      it "stores a users stripe information" do
        stripe_account.create_customer_without_coupon
        user.customer_id.should eq("youAreSuccessful")
        user.last_4_digits.should eq("4242")
        user.stripe_token.should be_nil
      end
    end
  end
end
