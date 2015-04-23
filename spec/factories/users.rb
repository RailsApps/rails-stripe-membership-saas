FactoryGirl.define do
  factory :user do
    email "test@example.com"
    password "please123"

    trait :admin do
      role 'admin'
    end

  end
end