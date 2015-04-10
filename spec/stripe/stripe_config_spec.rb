require 'rails_helper'

describe "Config Variables" do

  describe "STRIPE_API_KEY" do
    # this tests env variables against config/secrets.yml
    ## which gets the real variables from config/local_env.yml
    ### important : config/local_env.yml must be registered in ./.gitignore file to protect your secret data.
    it "a stripe api key is set" do
    expect(Stripe.api_key).to eq(Rails.application.secrets.stripe_api_key),
        "Your STRIPE_API_KEY is not set, Please refer to the 'Configure the Stripe Initializer' section of the README"
    end
  end

  describe "STRIPE_PUBLISHABLE_KEY" do
    it "a stripe publishable key is set" do
      expect(ENV['STRIPE_PUBLISHABLE_KEY']).to eq(Rails.application.secrets.stripe_publishable_key),
        "Your STRIPE_PUBLISHABLE_KEY is not set, Please refer to the 'Configure the Stripe Initializer' section of the README"
    end
  end

end