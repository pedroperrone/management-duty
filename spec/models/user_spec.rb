# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:role) }
  end

  describe 'scopes' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:shift_one) { FactoryBot.create(:shift, :inactive, user: user) }
    let!(:shift_two) { FactoryBot.create(:shift, user: user) }

    it 'should contain only active shifts' do
      expect(user.shifts).to include(shift_two)
      expect(user.shifts).not_to include(shift_one)
    end
  end
end
