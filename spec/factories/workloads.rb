FactoryBot.define do
  factory :workload do
    association :user
    music_key { '' }
    title { nil }
    artwork_url { nil }
    is_done { false }
    number { nil }
    weekly_number { nil }
    created_at { Time.current }
  end
end
