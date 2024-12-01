FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    sign_in_count { 0 }
    name { 'Test User' }
  end
end
