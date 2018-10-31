require 'rails_helper'

RSpec.shared_examples 'exchange a non existing shift' do
  it 'should redirect to root' do
    post :create, params: params

    expect(subject).to redirect_to(root_path)
  end
end

RSpec.describe Users::ShiftExchangesController, type: :controller do
  describe 'GET #index' do
    context 'without user session' do
      it 'should redirect to login' do
        get :index

        expect(subject).to redirect_to(user_session_path)
      end
    end

    context 'with user session' do
      let!(:user) { FactoryBot.create(:user) }
      let!(:requested_shift) { FactoryBot.create(:shift, user: user) }
      let!(:given_up_shift) { FactoryBot.create(:shift, :with_user) }
      let!(:shift_exchange) do
        FactoryBot.create(
          :shift_exchange, requested_shift: requested_shift,
          given_up_shift: given_up_shift
        )
      end

      before { sign_in user }
      it 'shows user exchanges with pending approval' do
        get :index

        expect(response).to have_http_status(:success)
        expect(subject).to render_template(:index)
        expect(assigns(:shift_exchanges))
          .to eq(ShiftExchange.pending_for_user(user))
      end
    end
  end

  describe 'POST #create' do
    context 'without user session' do
      it 'should redirect to login' do
        post :create

        expect(subject).to redirect_to(user_session_path)
      end
    end

    context 'with user session' do
      let!(:user) { FactoryBot.create(:user) }
      let!(:given_up_shift) { FactoryBot.create(:shift, user: user) }
      let!(:requested_shift) { FactoryBot.create(:shift, :with_user) }

      before { sign_in user }
      context 'user tries to give up on a shift that is not his' do
        let!(:given_up_shift) { FactoryBot.create(:shift, :with_user) }
        let(:params) do
          {
            given_up_shift_id: given_up_shift.id,
            requested_shift_id: requested_shift.id
          }
        end

        it 'should redirect him to root' do
          post :create, params: params

          expect(subject).to redirect_to(root_path)
        end
      end

      context 'user tries to exchange a shift that does not exist' do
        context 'given_up_shift does not exist' do
          let(:params) do
            {
              given_up_shift_id: 999999,
              requested_shift_id: requested_shift.id
            }
          end

          it_should_behave_like 'exchange a non existing shift'
        end

        context 'requested_shift does not exist' do
          let(:params) do
            {
              given_up_shift_id: given_up_shift.id,
              requested_shift_id: 999999
            }
          end

          it_should_behave_like 'exchange a non existing shift'
        end
      end

      context 'a successful exchange creation' do
        let(:params) do
          {
            requested_shift_id: requested_shift.id,
            given_up_shift_id: given_up_shift.id
          }
        end

        it 'creates a new shift_exchange' do
          post :create, params: params

          new_exchange = ShiftExchange.last
          expect(new_exchange.given_up_shift).to eq(given_up_shift)
          expect(new_exchange.requested_shift).to eq(requested_shift)
          expect(subject).to redirect_to(users_shift_exchanges_path)
        end
      end
    end
  end

  describe 'PUT #approve' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:shift) { FactoryBot.create(:shift, user: user) }
    let!(:exchange) do
      FactoryBot.create(:shift_exchange, :with_shifts, requested_shift: shift)
    end

    context 'without user session' do
      it 'should redirect_to user_session_path' do
        put :approve, params: { id: shift.id }

        expect(subject).to redirect_to(user_session_path)
      end
    end

    context 'with user session' do
      before { sign_in user }
      context 'user does not own the requested shift' do
        let!(:exchange) do
          FactoryBot.create(:shift_exchange, :with_shifts)
        end

        it 'should redirect_to root_path' do
          put :approve, params: { id: exchange.id }

          expect(subject).to redirect_to(root_path)
          expect(exchange.pending_user_approval).to be_truthy
        end
      end

      context 'valid approval' do
        it 'approves the exchange' do
          put :approve, params: { id: exchange.id }

          expect(subject).to redirect_to(dashboard_path)
          expect(exchange.reload.pending_user_approval).to be_falsey
          expect(exchange.approved_by_user).to be_truthy
        end
      end
    end
  end

  describe 'PUT #refuse' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:shift) { FactoryBot.create(:shift, user: user) }
    let!(:exchange) do
      FactoryBot.create(:shift_exchange, :with_shifts, requested_shift: shift)
    end

    context 'without user session' do
      it 'should redirect_to user_session_path' do
        put :refuse, params: { id: shift.id }

        expect(subject).to redirect_to(user_session_path)
      end
    end

    context 'with user session' do
      before { sign_in user }
      context 'user does not own the requested shift' do
        let!(:exchange) do
          FactoryBot.create(:shift_exchange, :with_shifts)
        end

        it 'should redirect_to root_path' do
          put :refuse, params: { id: exchange.id }

          expect(subject).to redirect_to(root_path)
          expect(exchange.pending_user_approval).to be_truthy
        end
      end

      context 'valid approval' do
        it 'approves the exchange' do
          put :refuse, params: { id: exchange.id }

          expect(subject).to redirect_to(dashboard_path)
          expect(exchange.reload.pending_user_approval).to be_falsey
          expect(exchange.approved_by_user).to be_falsey
        end
      end
    end
  end
end
