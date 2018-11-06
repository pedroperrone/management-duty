# frozen_string_literal: true

require 'rails_helper'

def split_date_params(date_obj, label)
  {
    label.to_s + "(1i)" => date_obj.year,
    label.to_s + "(2i)" => date_obj.month,
    label.to_s + "(3i)" => date_obj.day,
    label.to_s + "(4i)" => date_obj.hour,
    label.to_s + "(5i)" => date_obj.min
  }
end

RSpec.describe ShiftsController, type: :controller do
  # SCREENS
  describe "new_shift GET, #new" do
    context 'with session' do
      before { sign_in resource }

      context 'admin session' do
        let!(:resource) { FactoryBot.create(:admin) }

        it 'render new shift page as admin' do
          get :new

          expect(response).to have_http_status(:success)
        end
      end

      context 'user session' do
        let!(:resource) { FactoryBot.create(:user) }

        it 'attempt to create new shift page as user' do
          get :new

          expect(response).to have_http_status(:redirect)
          expect(subject).to redirect_to(admin_session_path)
        end
      end
    end

    context 'without session' do
      it 'attempt to create new shift as anon' do
        get :new

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(admin_session_path)
      end
    end
  end

  describe "edit_shift GET, #edit" do
    context 'with session' do
      before { sign_in resource }

      context 'admin session' do
        let!(:resource) { FactoryBot.create(:admin) }

        context 'valid shift' do
          let!(:shift_user) { FactoryBot.create(:user, invited_by: resource) }
          let!(:shift_param) { FactoryBot.create(:shift, user: shift_user) }

          it 'render edit shift page as admin' do
            get :edit, params: { id: shift_param.id.to_s }

            expect(response).to have_http_status(:success)
          end
        end

        context 'invalid shift' do
          let!(:shift_param) { FactoryBot.create(:shift, :with_user) }

          it 'attempt to edit invalid shift as admin' do
            get :edit, params: { id: shift_param.id.to_s }

            expect(response).to redirect_to(root_path)
          end
        end
      end

      context 'user session' do
        let!(:resource) { FactoryBot.create(:user) }

        it 'attempt to edit shift as user' do
          get :edit, params: { id: '0' }

          expect(response).to have_http_status(:redirect)
          expect(subject).to redirect_to(admin_session_path)
        end
      end
    end

    context 'without session' do
      it 'attempt to edit shift as anon' do
        get :edit, params: { id: '0' }

        expect(response).to have_http_status(:redirect)
        expect(subject).to redirect_to(admin_session_path)
      end
    end
  end

  describe "shift GET, #show" do
    context 'with session' do
      before { sign_in resource }

      context 'admin session' do
        let!(:resource) { FactoryBot.create(:admin) }

        context 'valid shift' do
          let!(:shift_user) { FactoryBot.create(:user, invited_by: resource) }

          it 'render shift page as admin' do
            get :show, params: { id: shift_user.id.to_s }

            expect(response).to have_http_status(:success)
          end
        end

        context 'invalid shift' do
          let!(:shift_user) { FactoryBot.create(:user) }

          it 'attempt to render invalid shift page as admin' do
            get :show, params: { id: shift_user.id.to_s }

            expect(response).to have_http_status(:redirect)
            expect(subject).to redirect_to(root_path)
          end
        end
      end

      context 'user session' do
        let!(:inv1) { FactoryBot.create(:admin) }
        let!(:resource) { FactoryBot.create(:user, invited_by: inv1) }
        let!(:inv2) { FactoryBot.create(:admin) }
        let!(:other_user) { FactoryBot.create(:user, invited_by: inv2) }

        it 'attempt to view own shifts as user' do
          get :show, params: { id: resource.id.to_s }

          expect(response).to have_http_status(:success)
        end

        it 'attempt to view other\'s shifts as user' do
          get :show, params: { id: other_user.id.to_s }

          expect(response).to have_http_status(:redirect)
        end

        it 'attempt to view non-existing user shifts as user' do
          get :show, params: { id: -1.to_s }

          expect(response).to have_http_status(:redirect)
        end
      end
    end

    context 'without session' do
      it 'attempt to view shifts as anon' do
        get :show, params: { id: 0.to_s }

        expect(response).to have_http_status(:redirect)
        expect(subject).to redirect_to(user_session_path)
      end
    end
  end

  # CRUD
  describe "POST, #create" do
    context 'with session' do
      before { sign_in resource }

      context 'admin session' do
        let!(:resource) { FactoryBot.create(:admin) }
        let!(:date_before) { DateTime.new(2018, 1, 1, 1, 1) }
        let!(:date_after) { DateTime.new(2018, 1, 1, 2, 1) }

        context 'shift owner' do
          let!(:shift_user) { FactoryBot.create(:user, invited_by: resource) }

          context 'valid shift' do
            it 'create valid shift as admin' do
              post :create, params: {
                shift: {}
                  .merge(split_date_params(date_before, :starts_at))
                  .merge(split_date_params(date_after, :ends_at)),
                user_email: shift_user.email
              }

              expect(Shift.count).to eq 1
              expect(response).to have_http_status(:success)
            end
          end

          context 'invalid shift' do
            it 'attempt to create shift too short as admin' do
              post :create, params: {
                shift: {}
                  .merge(split_date_params(date_before, :starts_at))
                  .merge(split_date_params(date_before, :ends_at)),
                user_email: shift_user.email
              }

              expect(Shift.count).to eq 0
              expect(response).to have_http_status(:redirect)
              expect(subject).to redirect_to(new_shift_path)
            end

            it 'attempt to create impossible shift as admin' do
              post :create, params: {
                shift: {}
                  .merge(split_date_params(date_after, :starts_at))
                  .merge(split_date_params(date_before, :ends_at)),
                user_email: shift_user.email
              }

              expect(Shift.count).to eq 0
              expect(response).to have_http_status(:redirect)
              expect(subject).to redirect_to(new_shift_path)
            end
          end
        end

        context 'not shift owner' do
          let!(:shift_user) { FactoryBot.create(:user, invited_by: resource) }
          let!(:another_inv) { FactoryBot.create(:admin) }
          let!(:another_user) { FactoryBot.create(:user, invited_by: another_inv) }

          it 'attempt to create other\'s shift as admin' do
            post :create, params: {
              shift: {}
                .merge(split_date_params(
                         DateTime.new(2018, 1, 1, 1, 1), :starts_at
                       ))
                .merge(split_date_params(
                         DateTime.new(2018, 1, 1, 2, 1), :ends_at
                       )),
              user_email: another_user.email
            }

            expect(Shift.count).to eq 0
            expect(response).to have_http_status(:redirect)
            expect(subject).to redirect_to(root_path)
          end
        end
      end

      context 'user session' do
        let!(:resource) { FactoryBot.create(:user) }

        it 'attempt to create shift as user' do
          get :create, params: {}

          expect(subject).to redirect_to(admin_session_path)
        end
      end
    end

    context 'without session' do
      it 'attempt to create shift as anon' do
        get :create, params: {}

        expect(Shift.count).to eq 0
        expect(response).to have_http_status(:redirect)
        expect(subject).to redirect_to(admin_session_path)
      end
    end
  end

  describe "PATCH, #update" do
    let!(:any_shift) { FactoryBot.create(:shift, :with_user) }
    let!(:date_before) { DateTime.new(2018, 1, 1, 1, 1) }
    let!(:date_after) { DateTime.new(2018, 1, 1, 2, 1) }

    context 'with session' do
      before { sign_in resource }

      context 'admin session' do
        let!(:resource) { FactoryBot.create(:admin) }

        context 'valid shift' do
          let!(:shift_user) { FactoryBot.create(:user, invited_by: resource) }
          let!(:shift_param) { FactoryBot.create(:shift, :short, user: shift_user) }

          it 'update owned shift without change as admin' do
            put :update, params: {
              id: shift_param.id,
              shift: {}
                .merge(split_date_params(shift_param.starts_at, :starts_at))
                .merge(split_date_params(shift_param.ends_at, :ends_at))
            }

            expect(response).to have_http_status(:success)
          end

          it 'update owned shift by extending it as admin' do
            put :update, params: {
              id: shift_param.id,
              shift: {}
                .merge(split_date_params(shift_param.starts_at, :starts_at))
                .merge(split_date_params(shift_param.ends_at + 1.hour, :ends_at))
            }

            expect(response).to have_http_status(:success)
          end

          it 'update owned shift by shifting it 1 hour as admin' do
            put :update, params: {
              id: shift_param.id,
              shift: {}
                .merge(split_date_params(shift_param.starts_at + 1.hour, :starts_at))
                .merge(split_date_params(shift_param.ends_at + 1.hour, :ends_at))
            }

            expect(response).to have_http_status(:success)
          end

          it 'update owned shift to valid one as admin' do
            put :update, params: {
              id: shift_param.id,
              shift: {}
                .merge(split_date_params(date_before, :starts_at))
                .merge(split_date_params(date_after, :ends_at))
            }

            expect(response).to have_http_status(:success)
          end

          it 'update owned shift to invalid (too short) one as admin' do
            put :update, params: {
              id: shift_param.id,
              shift: {}
                .merge(split_date_params(date_before, :starts_at))
                .merge(split_date_params(date_before, :ends_at))
            }

            expect(response).to have_http_status(:redirect)
            expect(subject).to redirect_to(edit_shift_path)
          end
        end
      end

      context 'user session' do
        let!(:resource) { FactoryBot.create(:user) }

        it 'attempt to update shift as user' do
          put :update, params: { id: any_shift.id }

          expect(response).to have_http_status(:redirect)
          expect(subject).to redirect_to(admin_session_path)
        end
      end
    end

    context 'without session' do
      it 'attempt to update shift as anon' do
        put :update, params: { id: any_shift.id }

        expect(response).to have_http_status(:redirect)
        expect(subject).to redirect_to(admin_session_path)
      end
    end
  end

  describe "DELETE, #destroy" do
    context 'with session' do
      before { sign_in resource }

      context 'admin session' do
        let!(:resource) { FactoryBot.create(:admin) }

        context 'valid shift' do
          let!(:shift_owner) { FactoryBot.create(:user, invited_by: resource) }
          let!(:user_shift) { FactoryBot.create(:shift, user_id: shift_owner.id) }

          it 'destroy existing shift as admin' do
            delete :destroy, params: { id: user_shift.id }

            expect(response).to have_http_status(:success)
            expect(Shift.count).to eq 0
          end
        end

        context 'invalid (other company) shift' do
          let!(:user_shift) { FactoryBot.create(:shift, :with_user) }

          it 'attempt to destroy other\'s shift' do
            delete :destroy, params: { id: user_shift.id }

            expect(Shift.count).to eq 1
            expect(subject).to redirect_to root_path
            expect(response).to have_http_status(:redirect)
          end
        end
      end

      context 'user session' do
        let!(:resource) { FactoryBot.create(:user) }

        it 'attempt to destroy shift as user' do
          delete :destroy, params: { id: 0.to_s }

          expect(subject).to redirect_to(admin_session_path)
          expect(response).to have_http_status(:redirect)
        end
      end
    end

    context 'without session' do
      it 'attempt to create shift as anon' do
        delete :destroy, params: { id: 0.to_s }

        expect(subject).to redirect_to(admin_session_path)
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
