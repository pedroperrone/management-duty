FactoryBot.define do
  factory :shift_exchange do
    trait :with_shifts do
      given_up_shift { FactoryBot.create(:shift, :with_user) }
      requested_shift { FactoryBot.create(:shift, :with_user) }
    end
  end
end
