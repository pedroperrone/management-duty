require 'rails_helper'
require 'management_duty/shift.rb'
require 'management_duty/errors/time_out_of_shift_range_error.rb'

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
        it 'should not make the partition' do
          expect { subject.partitionate(shift.starts_at + 1.minute) }
            .to raise_error(ActiveRecord::RecordInvalid)
            .and change(::Shift, :count).by(0)
            expect(shift.reload.active).to be_truthy
        end
      end

      context 'the second new shift is too short' do
        it 'should not make the partition' do
          expect { subject.partitionate(shift.ends_at - 1.minute) }
            .to raise_error(ActiveRecord::RecordInvalid)
            .and change(::Shift, :count).by(0)
          expect(shift.reload.active).to be_truthy
        end
      end
    end

    context 'the new shifts are valid' do
      it 'should create two new shifts and inactivate the current one' do
        expect { subject.partitionate(shift.starts_at + 1.hour) }
          .to change(::Shift, :count).by(2)
        expect(shift.active).to be_falsey

        shifts = ::Shift.where(origin_shift: shift).order(:id)
        expect(shifts.first.starts_at).to eq(shift.starts_at)
        expect(shifts.first.ends_at).to eq(shift.starts_at + 1.hour)
        expect(shifts.second.starts_at).to eq(shift.starts_at + 1.hour)
        expect(shifts.second.ends_at).to eq(shift.ends_at)
      end
    end
  end
end
