require 'spec_helper'

describe "Config Variables" do

  describe "STRIPE_API_KEY" do

    it "should be set" do
      Stripe.api_key.should_not eq("Your_Stripe_API_key"),
        "Your STRIPE_API_KEY is not set, Please refer to the 'Configure the Stripe Initializer' section of the README"
    end

  end

  describe "STRIPE_PUBLIC_KEY" do

    it "should be set" do
      STRIPE_PUBLIC_KEY.should_not eq("Your_Stripe_Public_Key"),
        "Your STRIPE_PUBLIC_KEY is not set, Please refer to the 'Configure the Stripe Initializer' section of the README"
    end

  end

end
