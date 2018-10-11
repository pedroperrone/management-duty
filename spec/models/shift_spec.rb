# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Shift, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:ends_at) }
    it { should validate_presence_of(:user) }
    it { should belong_to(:user) }
    context 'ininterrupt_time' do
      let!(:user) { FactoryBot.create(:user) }
      let!(:previous_shift) do
        FactoryBot.create(:shift, user: user, starts_at: Time.now,
                                  ends_at: Time.now + 8.hour)
      end

      before { Timecop.freeze(Time.now) }

      context 'user has shifts right after and right before' do
        let(:new_shift) do
          FactoryBot.build(:shift, user: user,
                                   starts_at: previous_shift.ends_at,
                                   ends_at: next_shift.starts_at)
        end

        context 'the ininterrupt time does not exceed the limit time' do
          let!(:next_shift) do
            FactoryBot.create(:shift, user: user, starts_at: Time.now + 13.hour,
                                      ends_at: Time.now + 16.hour)
          end
          it 'create a new shift correctly' do
            expect(new_shift.save).to be_truthy
          end
        end

        context 'the ininterrupt time exceeds the limit time' do
          let!(:next_shift) do
            FactoryBot.create(:shift, user: user, starts_at: Time.now + 14.hour,
                                      ends_at: Time.now + 19.hour)
          end
          it 'should raise an error' do
            expect { new_shift.save! }.to raise_error(
              ActiveRecord::RecordInvalid
            )
          end
        end
      end

      context 'another user has shifts that end when the new starts or ends' do
        it 'should not interfer' do
          new_shift = FactoryBot.build(
            :shift, :with_user, starts_at: previous_shift.ends_at,
                                ends_at: previous_shift.ends_at + 11.hour
          )
          expect(new_shift.save).to be_truthy
        end
      end
    end

    context 'minimum duration' do
      let(:new_shift) do
        FactoryBot.build(:shift, :with_user, starts_at: Time.now,
                                             ends_at: end_time)
      end

      context 'the shift has exactly one hour' do
        let(:end_time) { Time.now + 1.hour }
        it 'should be valid' do
          expect(new_shift.save).to be_truthy
        end
      end

      context 'the shift has more than one hour' do
        let(:end_time) { Time.now + 1.hour + 1.minute }
        it 'should be valid' do
          expect(new_shift.save).to be_truthy
        end
      end

      context 'the shift has less than one hour' do
        let(:end_time) { Time.now + 59.minute }
        it 'should not be valid' do
          expect { new_shift.save! }.to raise_error(
            ActiveRecord::RecordInvalid
          )
        end
      end
    end

    context 'overlap' do
      context 'user tries to create two shifts that occupies the same time' do
        let!(:user) { FactoryBot.create(:user) }
        let!(:first_shift) do
          FactoryBot.create(:shift, user: user, starts_at: Time.now,
                                    ends_at: Time.now + 1.hour)
        end

        context 'the new shift starts before the existing starts' do
          let(:new_shift) do
            FactoryBot.build(:shift, user: user, ends_at: Time.now + 30.minute,
                                     starts_at: Time.now - 30.minute)
          end
          it 'should raise error' do
            expect { new_shift.save! }.to raise_error(
              ActiveRecord::RecordInvalid
            )
          end
        end

        context 'the new shift starts after the existing starts' do
          let(:new_shift) do
            FactoryBot.build(:shift, user: user, ends_at: Time.now + 2.hour,
                                     starts_at: Time.now + 30.minute)
          end
          it 'should raise error' do
            expect { new_shift.save! }.to raise_error(
              ActiveRecord::RecordInvalid
            )
          end
        end
      end
    end
  end
end
