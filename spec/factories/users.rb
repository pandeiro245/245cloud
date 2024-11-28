FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    sign_in_count { 0 }
    name { 'Test User' }

    # SNS関連の属性
    facebook_id { nil }
    discord_id { nil }
    twitter_id { nil }
    token { nil }
  end
end
