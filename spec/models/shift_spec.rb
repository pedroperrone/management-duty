# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'a valid shift' do
  it 'saves the shift correctly' do
    expect(new_shift.save).to be_truthy
  end
end

RSpec.shared_examples 'an invalid shift' do
  it 'should not save the shift' do
    expect { new_shift.save! }.to raise_error(ActiveRecord::RecordInvalid)
  end
end

RSpec.describe Shift, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:starts_at) }
    it { should validate_presence_of(:ends_at) }
    it { should validate_presence_of(:user) }
    it { should belong_to(:user) }
    it { should belong_to(:origin_shift) }
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
          it_should_behave_like 'a valid shift'
        end

        context 'the ininterrupt time exceeds the limit time' do
          let!(:next_shift) do
            FactoryBot.create(:shift, user: user, starts_at: Time.now + 14.hour,
                                      ends_at: Time.now + 19.hour)
          end
          it_should_behave_like 'an invalid shift'
        end
      end

      context 'another user has shifts that end when the new starts or ends' do
        let(:new_shift) do
          FactoryBot.build(
            :shift, :with_user, starts_at: previous_shift.ends_at,
                                ends_at: previous_shift.ends_at + 11.hour
          )
        end
        it_should_behave_like 'a valid shift'
      end
    end

    context 'minimum duration' do
      let(:new_shift) do
        FactoryBot.build(:shift, :with_user, starts_at: Time.now,
                                             ends_at: end_time)
      end

      context 'the shift has exactly one hour' do
        let(:end_time) { Time.now + 1.hour }
        it_should_behave_like 'a valid shift'
      end

      context 'the shift has more than one hour' do
        let(:end_time) { Time.now + 1.hour + 1.minute }
        it_should_behave_like 'a valid shift'
      end

      context 'the shift has less than one hour' do
        let(:end_time) { Time.now + 59.minute }
        it_should_behave_like 'an invalid shift'
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
          it_should_behave_like 'an invalid shift'
        end

        context 'the new shift starts after the existing starts' do
          let(:new_shift) do
            FactoryBot.build(:shift, user: user, ends_at: Time.now + 2.hour,
                                     starts_at: Time.now + 30.minute)
          end
          it_should_behave_like 'an invalid shift'
        end
      end
    end
  end

  describe 'length methods' do
    before { Timecop.freeze(Time.now) }

    let!(:user) { FactoryBot.create(:user) }
    let!(:first_shift) do
      FactoryBot.create(
        :shift, user: user, starts_at: Time.now, ends_at: Time.now + 1.hour
      )
    end

    describe '.length' do
      context 'shift exists' do
        let!(:second_shift) do
          FactoryBot.create(
            :shift, :with_user, starts_at: Time.now,
                                ends_at: Time.now + 2.hour + 30.minute
          )
        end

        it 'should return the shift length' do
          expect(first_shift.length).to equal(1.0)
          expect(second_shift.length).to equal(2.5)
        end
      end
    end

    describe '.prepended_length' do
      context 'shift has prepended shifts' do
        let!(:second_shift) do
          FactoryBot.create(:shift, user: user, starts_at: first_shift.ends_at,
                                    ends_at: first_shift.ends_at + 3.hour)
        end
        let!(:third_shift) do
          FactoryBot.create(:shift, user: user, starts_at: second_shift.ends_at,
                                    ends_at: second_shift.ends_at + 8.hour)
        end

        it 'returns the summed length of the prepended shifts' do
          expect(second_shift.prepended_length).to equal(1.0)
          expect(third_shift.prepended_length).to equal(4.0)
        end
      end

      context 'shift has no prepended shift' do
        it 'return 0' do
          expect(first_shift.prepended_length).to equal(0)
        end
      end
    end

    describe '.appended_length' do
      context 'shift has appended shifts' do
        let!(:second_shift) do
          FactoryBot.create(:shift, user: user, ends_at: first_shift.starts_at,
                                    starts_at: first_shift.starts_at - 3.hour)
        end
        let!(:third_shift) do
          FactoryBot.create(:shift, user: user, ends_at: second_shift.starts_at,
                                    starts_at: second_shift.starts_at - 5.hour)
        end

        it 'returns the summed length of the appended shifts' do
          expect(second_shift.appended_length).to equal(1.0)
          expect(third_shift.appended_length).to equal(4.0)
        end
      end

      context 'shift has no appended shift' do
        it 'return 0' do
          expect(first_shift.appended_length).to equal(0)
        end
      end
    end
  end

  describe '.contains?' do
    let!(:shift) { FactoryBot.create(:shift, :with_user) }

    before { Timecop.freeze(Time.now) }

    context 'is exactly the start time' do
      it 'should be true' do
        expect(shift.contains?(shift.starts_at)).to be_truthy
      end
    end

    context 'is exactly the end time' do
      it 'should be false' do
        expect(shift.contains?(shift.ends_at)).to be_falsey
      end
    end

    context 'is in the middle of the time' do
      it 'should be true' do
        expect(shift.contains?(shift.starts_at + 1.minute)).to be_truthy
      end
    end

    context 'is not on the time' do
      it 'should be false' do
        expect(shift.contains?(shift.starts_at - 1.hour)).to be_falsey
        expect(shift.contains?(shift.ends_at + 1.hour)).to be_falsey
      end
    end
  end
end
