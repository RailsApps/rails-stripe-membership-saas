require 'spec_helper'

describe "Config Variables" do

  describe "STRIPE_API_KEY" do

    it "should not be nil" do
      Stripe.api_key.should_not be_nil,
        "Your STRIPE_API_KEY is not set, Please refer to the 'Configure the Stripe Initializer' section of the README"
    end

  end

  describe "STRIPE_PUBLIC_KEY" do

    it "should not be nil" do
      STRIPE_PUBLIC_KEY.should_not be_nil,
        "Your STRIPE_PUBLIC_KEY is not set, Please refer to the 'Configure the Stripe Initializer' section of the README"
    end

  end

end
