# frozen_string_literal: true

require 'rails_helper'
require 'management_duty/shift.rb'
require 'management_duty/errors/time_out_of_shift_range_error.rb'

RSpec.shared_examples 'an invalid partitioning' do
  it 'should not make the partition' do
    expect { subject.partitionate(partition_time) }
      .to raise_error(ActiveRecord::RecordInvalid)
      .and change(::Shift, :count).by(0)
    expect(shift.reload.active).to be_truthy
  end
end

describe ManagementDuty::Shift do
  subject { described_class.new(shift) }
  let!(:shift) { FactoryBot.create(:shift, :with_user) }

  before { Timecop.freeze(Time.now) }

  describe '.partitionate' do
    context 'the partition time is out of range' do
      it 'should raise error' do
        expect { subject.partitionate(shift.starts_at - 1.hour) }
          .to raise_error(ManagementDuty::Errors::TimeOutOfShiftRangeError)
      end
    end

    context 'one of the new shifts is invalid' do
      context 'the first new shift is too short' do
        let(:partition_time) { shift.starts_at + 1.minute }
        it_should_behave_like 'an invalid partitioning'
      end

      context 'the second new shift is too short' do
        let(:partition_time) { shift.ends_at - 1.minute }
        it_should_behave_like 'an invalid partitioning'
      end
    end

    context 'the new shifts are valid' do
      it 'should create two new shifts and inactivate the current one' do
        expect { subject.partitionate(shift.starts_at + 1.hour) }
          .to change(::Shift, :count).by(2)
        expect(shift.active).to be_falsey

        shifts = ::Shift.where(origin_shift: shift).order(:id)
        assert_time_equals(shifts.first.starts_at, shift.starts_at)
        assert_time_equals(shifts.first.ends_at, shift.starts_at + 1.hour)
        assert_time_equals(shifts.second.starts_at, shift.starts_at + 1.hour)
        assert_time_equals(shifts.second.ends_at, shift.ends_at)
      end
    end
  end
end
