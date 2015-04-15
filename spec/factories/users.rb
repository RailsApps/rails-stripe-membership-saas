FactoryGirl.define do
  factory :user do
    email "test@example.com"
    password "please123"
    password_confirmation 'please123'

  # required if the Devise Confirmable module is used
  # confirmed_at Time.now

    trait :admin do
      role 'admin'
    end

  end
end
