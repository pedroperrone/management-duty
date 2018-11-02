# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    name { 'Administrador da Silva' }
    sequence :email do |s|
      "admin#{s}@managementduty.com"
    end
    password { '123456' }
    sequence :company_name do |s|
      "Company#{s}"
    end
  end
end
