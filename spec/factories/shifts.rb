# frozen_string_literal: true

FactoryBot.define do
  factory :shift do
    starts_at { Time.now }
    ends_at { Time.now + 8.hour }
  end
  trait :with_user do
    user { FactoryBot.create(:user, :invited_by) }
  end
  trait :inactive do
    active { false }
  end
  trait :short do
    starts_at { Time.now }
    ends_at { Time.now + 1.hour }
  end
end
