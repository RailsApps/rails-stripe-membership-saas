FactoryGirl.define do
  factory :plan do
    name 'Silver'
    stripe_id 'silver'
    amount 900
    interval 'month'
  end
end