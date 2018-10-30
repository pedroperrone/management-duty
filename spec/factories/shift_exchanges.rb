# frozen_string_literal: true

FactoryBot.define do
  factory :shift_exchange do
    trait :with_shifts do
      given_up_shift { FactoryBot.create(:shift, :with_user) }
      requested_shift { FactoryBot.create(:shift, :with_user) }
    end

    trait :pending_admin_approval do
      pending_user_approval { false }
      approved_by_user { true }
      pending_admin_approval { true }
    end

    trait :pending_user_approval do
      pending_user_approval { true }
    end

    trait :refused_by_user do
      pending_user_approval { false }
      approved_by_user { false }
    end
  end
end
