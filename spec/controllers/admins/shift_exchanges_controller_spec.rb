require 'rails_helper'

RSpec.describe Admins::ShiftExchangesController, type: :controller do
  describe 'GET #index' do
    context 'without admin session' do
      it 'should redirect to login' do
        get :index

        expect(subject).to redirect_to(admin_session_path)
      end
    end

    context 'with admin session' do
      let!(:admin) { FactoryBot.create(:admin) }
      let!(:user) { FactoryBot.create(:user, invited_by: admin) }
      let!(:requested_shift) { FactoryBot.create(:shift, user: user) }
      let!(:given_up_shift) { FactoryBot.create(:shift, :with_user) }
      let!(:shift_exchange) do
        FactoryBot.create(
          :shift_exchange, requested_shift: requested_shift,
                           given_up_shift: given_up_shift
        )
      end

      before { sign_in admin }
      it 'shows admin exchanges with pending approval' do
        get :index

        expect(response).to have_http_status(:success)
        expect(subject).to render_template(:index)
        expect(assigns(:shift_exchanges))
          .to eq(ShiftExchange.pending_for_admin(admin))
      end
    end
  end

  describe 'PUT #approve' do
    context 'without session' do
      it 'should redirect to login' do
        put :approve, params: { id: 1 }

        expect(subject).to redirect_to(admin_session_path)
      end
    end

    context 'with session' do
      let!(:admin) { FactoryBot.create(:admin) }
      let!(:user) { FactoryBot.create(:user, invited_by: admin) }
      let!(:shift) { FactoryBot.create(:shift, user: user) }
      let!(:shift_exchange) do
        FactoryBot.create(:shift_exchange, :with_shifts,
          :pending_admin_approval,given_up_shift: shift)
      end
      let(:params) do
        {
          params: {
            id: shift_exchange.id
          }
        }
      end

      before { sign_in admin }
      context 'shift does not exist' do
        it 'should redirect to route path' do
          put :approve, params: { id: 99999 }

          expect(subject).to redirect_to(root_path)
        end
      end

      context 'admin is not allowed to approve this exchange' do
        let!(:other_admin) { FactoryBot.create(:admin) }

        before { sign_in other_admin }
        it 'should redirect to route path' do
          put :approve, params

          expect(subject).to redirect_to(dashboard_path)
          expect(shift_exchange.reload.pending_admin_approval).to be_truthy
          expect(shift_exchange.approved_by_admin).to be_falsey
        end
      end

      context 'admin approves the exchange' do
        context 'the change is valid' do
          it 'approves the change and redirects to index' do
            put :approve, params

            expect(subject).to redirect_to(admins_shift_exchanges_path)
            expect(shift_exchange.reload.pending_admin_approval).to be_falsey
            expect(shift_exchange.approved_by_admin).to be_truthy
          end
        end
      end
    end
  end

  describe 'PUT #refuse' do
    context 'without session' do
      it 'should redirect to login' do
        put :refuse, params: { id: 1 }

        expect(subject).to redirect_to(admin_session_path)
      end
    end

    context 'with session' do
      let!(:admin) { FactoryBot.create(:admin) }
      let!(:user) { FactoryBot.create(:user, invited_by: admin) }
      let!(:shift) { FactoryBot.create(:shift, user: user) }
      let!(:shift_exchange) do
        FactoryBot.create(:shift_exchange, :with_shifts,
          :pending_admin_approval,given_up_shift: shift)
      end
      let(:params) do
        {
          params: {
            id: shift_exchange.id
          }
        }
      end

      before { sign_in admin }
      context 'shift does not exist' do
        it 'should redirect to route path' do
          put :refuse, params: { id: 99999 }

          expect(subject).to redirect_to(root_path)
        end
      end

      context 'admin is not allowed to refuse this exchange' do
        let!(:other_admin) { FactoryBot.create(:admin) }

        before { sign_in other_admin }
        it 'should redirect to route path' do
          put :refuse, params

          expect(subject).to redirect_to(dashboard_path)
          expect(shift_exchange.reload.pending_admin_approval).to be_truthy
          expect(shift_exchange.approved_by_admin).to be_falsey
        end
      end

      context 'admin refuse the exchange' do
        context 'the change is valid' do
          it 'refuse the change and redirects to index' do
            put :refuse, params

            expect(subject).to redirect_to(admins_shift_exchanges_path)
            expect(shift_exchange.reload.pending_admin_approval).to be_falsey
            expect(shift_exchange.approved_by_admin).to be_falsey
          end
        end
      end
    end
  end
end
