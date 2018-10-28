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

  describe 'scopes' do
    describe '.pending_for_user' do
      let!(:user) { FactoryBot.create(:user) }
      let!(:users_shift_one) { FactoryBot.create(:shift, user: user) }
      let!(:users_shift_two) do
        FactoryBot.create(
          :shift, user: user, starts_at: users_shift_one.ends_at + 1.minute,
                  ends_at: users_shift_one.ends_at + 8.hour + 1.minute
        )
      end
      let!(:users_shift_three) do
        FactoryBot.create(
          :shift, user: user, starts_at: users_shift_two.ends_at + 1.minute,
                  ends_at: users_shift_two.ends_at + 8.hour + 1.minute
        )
      end

      let!(:pending_approval) do
        FactoryBot.create(
          :shift_exchange, :with_shifts,
          requested_shift: users_shift_one, pending_user_approval: true
        )
      end
      let!(:refused_by_user) do
        FactoryBot.create(
          :shift_exchange, :with_shifts,
          requested_shift: users_shift_two, pending_user_approval: false,
          approved_by_user: false
        )
      end
      let!(:admin_approval_pending) do
        FactoryBot.create(
          :shift_exchange, :with_shifts,
          requested_shift: users_shift_three, pending_user_approval: false,
          approved_by_user: false, pending_admin_approval: true
        )
      end
      let!(:change_request_from_other_user) do
        FactoryBot.create(
          :shift_exchange, :with_shifts, pending_user_approval: true
        )
      end

      context 'user has pending requests' do
        it 'return user\'s pending change requests' do
          scope_result = ShiftExchange.pending_for_user(user)
          expect(scope_result).to include(pending_approval)
          expect(scope_result)
            .not_to include(refused_by_user, admin_approval_pending,
                            change_request_from_other_user)
        end
      end
    end
  end

  describe '.be_approved_by_user' do
    context 'exchange is not autoapproved' do
      let!(:user_with_different_role) do
        FactoryBot.create(:user, role: 'Superhero')
      end
      let!(:shift) { FactoryBot.create(:shift, user: user_with_different_role) }
      let!(:exchange) do
        FactoryBot.create(:shift_exchange, :with_shifts, requested_shift: shift)
      end

      it 'should update pending_user_approval for false and approved_by_user ' \
         'for true' do
        expect { exchange.be_approved_by_user }.to change(::Shift, :count).by(0)
        expect(exchange.pending_user_approval).to be_falsey
        expect(exchange.approved_by_user).to be_truthy
      end
    end

    context 'exchange is autoapproved' do
      let!(:exchange) { FactoryBot.create(:shift_exchange, :with_shifts) }
      it 'should update the attributes and create new shifts' do
        expect { exchange.be_approved_by_user }.to change(::Shift, :count).by(2)
        expect(exchange.pending_user_approval).to be_falsey
        expect(exchange.approved_by_user).to be_truthy
      end
    end
  end

  describe '.be_refused_by_user' do
    let!(:exchange) { FactoryBot.create(:shift_exchange, :with_shifts) }

    context 'when invoked' do
      it 'should update pending_user_approval and approved_by_user for false' do
        exchange.be_refused_by_user
        expect(exchange.pending_user_approval).to be_falsey
        expect(exchange.approved_by_user).to be_falsey
      end
    end
  end
end
