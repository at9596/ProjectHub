FactoryBot.define do
  factory :user do
    name { "Abhishek" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
  end
end
