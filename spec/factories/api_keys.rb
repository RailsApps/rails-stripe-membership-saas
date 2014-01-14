# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :api_key do
    access_token "MyString"
    user_id 1
  end
end
