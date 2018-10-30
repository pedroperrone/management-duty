# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'an exchange to be judged by the admin' do
  it 'should be returned for the scope' do
    scope_result = ShiftExchange.pending_for_admin(admin)
    expect(scope_result).to include(exchange)
  end
end

RSpec.shared_examples 'an exchange not to be judged by the admin' do
  it 'should not be returned for the scope' do
    scope_result = ShiftExchange.pending_for_admin(admin)
    expect(scope_result).not_to include(exchange)
  end
end

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

    describe 'pending_for_admin' do
      let!(:admin) { FactoryBot.create(:admin) }

      context 'exchange for this admin' do
        let!(:user_one) { FactoryBot.create(:user, invited_by: admin) }
        let!(:user_two) { FactoryBot.create(:user, invited_by: admin) }
        let!(:shift_one) { FactoryBot.create(:shift, user: user_one) }
        let!(:shift_two) { FactoryBot.create(:shift, user: user_two) }

        context 'there are exchanges with pending admin approval' do
          let!(:exchange) do
            FactoryBot.create(
              :shift_exchange, :pending_admin_approval,
              given_up_shift: shift_one, requested_shift: shift_two
            )
          end

          it_behaves_like 'an exchange to be judged by the admin'
        end

        context 'there are exchanges with pending user approval' do
          let!(:exchange) do
            FactoryBot.create(
              :shift_exchange, :pending_user_approval,
              given_up_shift: shift_one, requested_shift: shift_two
            )
          end

          it_behaves_like 'an exchange not to be judged by the admin'
        end

        context 'there are exchanges refused by users' do
          let!(:exchange) do
            FactoryBot.create(
              :shift_exchange, :refused_by_user,
              given_up_shift: shift_one, requested_shift: shift_two
            )
          end

          it_behaves_like 'an exchange not to be judged by the admin'
        end
      end

      context 'there are exchanges pending to another admin' do
        let!(:exchange) do
          FactoryBot.create(:shift_exchange, :with_shifts,
                            :pending_admin_approval)
        end

        it_behaves_like 'an exchange not to be judged by the admin'
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

  describe '.be_refused_by_admin' do
    let!(:exchange) do
      FactoryBot.create(:shift_exchange, :with_shifts, :pending_admin_approval)
    end

    it 'should set pending_admin_approval and approved_by_admin as false' do
      expect { exchange.be_refused_by_admin }.to change(::Shift, :count).by(0)
      expect(exchange.pending_admin_approval).to be_falsey
      expect(exchange.approved_by_admin).to be_falsey
    end
  end

  describe '.be_approved_by_admin' do
    let!(:exchange) do
      FactoryBot.create(:shift_exchange, :with_shifts, :pending_admin_approval)
    end

    it 'should make the exchange and set the boolean attributes properly' do
      expect { exchange.be_approved_by_admin }.to change(::Shift, :count).by(2)
      expect(exchange.pending_admin_approval).to be_falsey
      expect(exchange.approved_by_admin).to be_truthy
    end
  end
end
