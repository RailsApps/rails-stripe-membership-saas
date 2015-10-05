require 'stripe_mock'
include Warden::Test::Helpers
Warden.test_mode!

describe 'Card API for Recipients' do
  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  context 'retrieval and deletion with recipients', live: true do
    let!(:recipient) { Stripe::Recipient.create(name: 'Test Recipient', type: 'individual') }
    let!(:card_token) { stripe_helper.generate_card_token(number: '4000056655665556') }
    let!(:card) { recipient.cards.create(card: card_token) }

    it 'can retrieve all recipient cards' do
      retrieved = recipient.cards.all
      expect(retrieved.count).to eq 1
    end

    it 'deletes a recipient card' do
      card.delete
      retrieved_cus = Stripe::Recipient.retrieve(recipient.id)
      expect(retrieved_cus.cards.data).to be_empty
    end

    it 'deletes a recipient card then set the default_card to nil' do
      card.delete
      retrieved_cus = Stripe::Recipient.retrieve(recipient.id)
      expect(retrieved_cus.default_card).to be_nil
    end

    it 'creates/returns a card when using recipient.cards.create given a card token' do
      recipient = Stripe::Recipient.create(id: 'test_recipient_sub')
      card_token = stripe_helper.generate_card_token(
        last4: '4242',
        exp_month: 11,
        exp_year: 2019
      )
      card = recipient.cards.create(card: card_token)
      expect(card.recipient).to eq 'test_recipient_sub'
      expect(card.last4).to eq '4242'
      expect(card.exp_month).to eq 11
      expect(card.exp_year).to eq 2019

      recipient = Stripe::Recipient.retrieve('test_recipient_sub')
      expect(recipient.cards.count).to eq 1
      card = recipient.cards.data.first
      expect(card.recipient).to eq 'test_recipient_sub'
      expect(card.last4).to eq '4242'
      expect(card.exp_month).to eq 11
      expect(card.exp_year).to eq 2019
    end

    it 'creates/returns a card when using recipient.cards.create given card params' do
      recipient = Stripe::Recipient.create(id: 'test_recipient_sub')
      card = recipient.cards.create(card: {
        number: '4000056655665556',
        exp_month: '6',
        exp_year: '2026',
        cvc: '123'
      })
      expect(card.recipient).to eq('test_recipient_sub')
      expect(card.last4).to eq '5556'
      expect(card.exp_month).to eq 6
      expect(card.exp_year).to eq 2026

      recipient = Stripe::Recipient.retrieve('test_recipient_sub')
      expect(recipient.cards.count).to eq 1
      card = recipient.cards.data.first
      expect(card.recipient).to eq 'test_recipient_sub'
      expect(card.last4).to eq '5556'
      expect(card.exp_month).to eq 6
      expect(card.exp_year).to eq 2026
    end

    context 'deletion when the recipient has two cards' do
      let!(:card_token_2) { stripe_helper.generate_card_token(number: '5200828282828210') }
      let!(:card_2) { recipient.cards.create(card: card_token_2) }

      it 'has just one card anymore' do
        card.delete
        retrieved_rec = Stripe::Recipient.retrieve(recipient.id)
        expect(retrieved_rec.cards.data.count).to eq 1
        expect(retrieved_rec.cards.data.first.id).to eq card_2.id
      end

      it 'sets the default_card id to the last card remaining id' do
        card.delete
        retrieved_rec = Stripe::Recipient.retrieve(recipient.id)
        expect(retrieved_rec.default_card).to eq card_2.id
      end
    end
  end
end
