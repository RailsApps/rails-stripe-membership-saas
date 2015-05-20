describe "Stripe Config Variables" do

  describe "STRIPE_API_KEY" do
    it "a STRIPE_API_KEY is set in env" do
      expect(ENV['STRIPE_API_KEY']).to eq(ENV.fetch("STRIPE_API_KEY")),
        "Your STRIPE_API_KEY is not set, 
         Please refer to the 'Configure the Stripe Initializer' section of the README"
    end
  end

  describe "STRIPE_PUBLISHABLE_KEY" do
    it "a STRIPE_PUBLISHABLE_KEY is set in env" do
      expect(ENV['STRIPE_PUBLISHABLE_KEY']).to eq(ENV.fetch("STRIPE_PUBLISHABLE_KEY")),
        "Your STRIPE_PUBLISHABLE_KEY is not set, 
         Please refer to the 'Configure the Stripe Initializer' section of the README"
    end
  end

end