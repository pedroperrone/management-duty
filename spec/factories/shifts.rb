# frozen_string_literal: true

FactoryBot.define do
  factory :shift do
    starts_at { Time.now }
    ends_at { Time.now + 8.hour }
  end
  trait :with_user do
    user { FactoryBot.create(:user) }
  end
end
