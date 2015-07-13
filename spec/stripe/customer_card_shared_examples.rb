shared_examples "Multiple Customer Cards" do

  before { StripeMock.start }
  after { StripeMock.stop }

  it "handles multiple cards", live: true do
    tok1 = Stripe::Token.retrieve stripe_helper.generate_card_token number: "4242424242424242"
    tok2 = Stripe::Token.retrieve stripe_helper.generate_card_token number: "4012888888881881"
    customer = Stripe::Customer.create(email: 'alice@bob.com', card: tok1.id)
    default_source = customer.sources.first
    customer.sources.create(card: tok2.id)
    customer = Stripe::Customer.retrieve(customer.id)
    customer.sources { include[]=total_count }
    expect(customer.sources.total_count).to eq(2)
    expect(customer.default_source).to eq default_source.id
  end

  it "gives the same two card numbers the same fingerprints", live: true do
    tok1 = Stripe::Token.retrieve stripe_helper.generate_card_token number: "4242424242424242"
    tok2 = Stripe::Token.retrieve stripe_helper.generate_card_token number: "4242424242424242"
    customer = Stripe::Customer.create(:email: 'alice@bob.com', card: tok1.id)
    customer = Stripe::Customer.retrieve(customer.id)
    card = customer.sources.find do |existing_card|
      existing_card.fingerprint == tok2.card.fingerprint
    end
    expect(card).to_not be_nil
  end

  it "gives different card numbers different fingerprints", live: true do
    tok1 = Stripe::Token.retrieve stripe_helper.generate_card_token number: "4242424242424242"
    tok2 = Stripe::Token.retrieve stripe_helper.generate_card_token number: "4012888888881881"
    customer = Stripe::Customer.create(email: 'alice@bob.com', card: tok1.id)
    customer = Stripe::Customer.retrieve(customer.id)
    card = customer.sources.find do |existing_card|
      existing_card.fingerprint == tok2.card.fingerprint
    end
    expect(card).to be_nil
  end
end
