# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { 'Fulano' }
    sequence :email do |s|
      "user#{s}@managementduty.com"
    end
    password { '123456' }
    role { 'Company_Administrator' }
  end
  trait :invited_by do
    invited_by { FactoryBot.create(:admin) }
  end

end
