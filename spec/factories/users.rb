FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "testuser#{n}" }
    password { "password123" }
  end
end
