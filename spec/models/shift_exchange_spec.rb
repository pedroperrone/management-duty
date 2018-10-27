# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShiftExchange, type: :model do
  describe 'validations' do
    it { should belong_to(:given_up_shift) }
    it { should belong_to(:requested_shift) }
    it { should validate_presence_of(:given_up_shift) }
    it { should validate_presence_of(:requested_shift) }

    context 'shifts length' do
      context 'both shifts have the same length' do
        let(:exchange) { FactoryBot.build(:shift_exchange, :with_shifts) }

        it 'should be valid' do
          expect(exchange.save).to be_truthy
        end
      end

      context 'shifts have different lengths' do
        let(:exchange) do
          FactoryBot.build(
            :shift_exchange, :with_shifts,
            requested_shift: FactoryBot.create(:shift, :with_user, :short)
          )
        end

        it 'should not be valid' do
          expect { exchange.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end
  end
end
