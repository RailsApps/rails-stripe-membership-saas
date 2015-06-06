describe "Config Variables" do

  describe "STRIPE_API_KEY" do
    # this tests env variables against config/secrets.yml which reads from your env variables $ `env`
    it "a STRIPE_API_KEY is set" do
      expect(ENV['STRIPE_API_KEY']).to eq(Rails.application.secrets.stripe_api_key),
        "Your STRIPE_API_KEY is not set, Please refer to the 'Configure the Stripe Initializer' section of the README"
    end
  end

  describe "STRIPE_PUBLISHABLE_KEY" do
    it "a STRIPE_PUBLISHING_KEY is set" do
      expect(ENV['STRIPE_PUBLISHABLE_KEY']).to eq(Rails.application.secrets.stripe_publishable_key),
        "Your STRIPE_PUBLISHABLE_KEY is not set, Please refer to the 'Configure the Stripe Initializer' section of the README"
    end
  end

end
