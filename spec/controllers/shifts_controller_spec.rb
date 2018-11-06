# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShiftsController, type: :controller do
  describe "POST, #create" do
    context 'with session' do
      before { sign_in resource }

      context 'admin session' do
        let!(:resource) { FactoryBot.create(:admin) }
        let(:date_before) { DateTime.new(2018, 1, 1, 1, 1) }
        let(:date_after) { DateTime.new(2018, 1, 1, 2, 1) }

        context 'shift owner' do
          let!(:shift_user) { FactoryBot.create(:user, invited_by: resource) }

          context 'valid shift' do
            it 'create valid shift as admin' do
              post :create, params: {
                shift: { starts_at: to_datetime_picker_format(date_before),
                         ends_at: to_datetime_picker_format(date_after) },
                user_email: shift_user.email
              }

              expect(subject).to redirect_to(user_show_path(shift_user))
              expect(Shift.count).to eq(1)
            end
          end

          context 'invalid shift' do
            it 'attempt to create shift too short as admin' do
              post :create, params: {
                shift: { starts_at: to_datetime_picker_format(date_before),
                         ends_at: to_datetime_picker_format(
                           date_after - 30.minute
                         ) },
                user_email: shift_user.email
              }

              expect(Shift.count).to eq(0)
              expect(response).to have_http_status(:redirect)
              expect(subject).to redirect_to(user_show_path(shift_user))
            end

            it 'attempt to create impossible shift as admin' do
              post :create, params: {
                shift: { starts_at: to_datetime_picker_format(date_after),
                         ends_at: to_datetime_picker_format(date_before) },
                user_email: shift_user.email
              }

              expect(Shift.count).to eq(0)
              expect(response).to have_http_status(:redirect)
              expect(subject).to redirect_to(user_show_path(shift_user))
            end
          end
        end

        context 'not shift owner' do
          let!(:shift_user) { FactoryBot.create(:user, invited_by: resource) }
          let!(:another_inv) { FactoryBot.create(:admin) }
          let!(:another_user) do
            FactoryBot.create(:user, invited_by: another_inv)
          end

          it 'attempt to create other\'s shift as admin' do
            post :create, params: {
              shift: { starts_at: to_datetime_picker_format(
                DateTime.new(2018, 1, 1, 1, 1)
              ),
                       ends_at: to_datetime_picker_format(
                         DateTime.new(2018, 1, 1, 2, 1)
                       ) },
              user_email: another_user.email
            }

            expect(Shift.count).to eq 0
            expect(response).to have_http_status(:redirect)
            expect(subject).to redirect_to(users_searches_path)
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

  describe "PUT, #update" do
    let!(:any_shift) { FactoryBot.create(:shift, :with_user) }
    let!(:date_before) { DateTime.new(2018, 1, 1, 1, 1) }
    let!(:date_after) { DateTime.new(2018, 1, 1, 2, 1) }

    context 'with session' do
      before { sign_in resource }

      context 'admin session' do
        let!(:resource) { FactoryBot.create(:admin) }

        context 'valid shift' do
          let!(:shift_user) { FactoryBot.create(:user, invited_by: resource) }
          let!(:shift_param) do
            FactoryBot.create(:shift, :short, user: shift_user)
          end

          it 'update owned shift without change as admin' do
            put :update, params: {
              id: shift_param.id,
              shift: {
                starts_at: to_datetime_picker_format(shift_param.starts_at),
                ends_at: to_datetime_picker_format(shift_param.ends_at)
              },
              user_email: shift_user.email
            }

            expect(resource).to redirect_to(user_show_path(shift_user))
          end

          it 'update owned shift by extending it as admin' do
            put :update, params: {
              id: shift_param.id,
              shift: {
                starts_at: to_datetime_picker_format(shift_param.starts_at),
                ends_at: to_datetime_picker_format(shift_param.ends_at + 1.hour)
              },
              user_email: shift_user.email
            }

            expect(resource).to redirect_to(user_show_path(shift_user))
          end

          it 'update owned shift by shifting it 1 hour as admin' do
            put :update, params: {
              id: shift_param.id,
              shift: {
                starts_at: to_datetime_picker_format(
                  shift_param.starts_at + 1.hour
                ),
                ends_at: to_datetime_picker_format(shift_param.ends_at + 1.hour)
              },
              user_email: shift_user.email
            }

            expect(subject).to redirect_to(user_show_path(shift_user))
          end

          it 'update owned shift to valid one as admin' do
            put :update, params: {
              id: shift_param.id,
              shift: {
                starts_at: to_datetime_picker_format(shift_param.starts_at),
                ends_at: to_datetime_picker_format(shift_param.ends_at)
              },
              user_email: shift_user.email
            }

            expect(subject).to redirect_to(user_show_path(shift_user))
          end

          it 'update owned shift to invalid (too short) one as admin' do
            put :update, params: {
              id: shift_param.id,
              shift: {
                starts_at: to_datetime_picker_format(shift_param.starts_at),
                ends_at: to_datetime_picker_format(
                  shift_param.starts_at + 30.minute
                )
              },
              user_email: shift_user.email
            }

            expect(response).to have_http_status(:redirect)
            expect(subject).to redirect_to(user_show_path(shift_user))
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
            delete :destroy, params: { id: user_shift.id,
                                       user_email: shift_owner.email }

            expect(subject).to redirect_to(user_show_path(shift_owner))
            expect(Shift.count).to eq 0
          end
        end

        context 'invalid (other company) shift' do
          let!(:user_shift) { FactoryBot.create(:shift, :with_user) }

          it 'attempt to destroy other\'s shift' do
            delete :destroy, params: { id: user_shift.id }

            expect(Shift.count).to eq 1
            expect(subject).to redirect_to(users_searches_path)
            expect(response).to have_http_status(:redirect)
          end
        end
      end

      context 'user session' do
        let!(:resource) { FactoryBot.create(:user) }

        it 'attempt to destroy shift as user' do
          delete :destroy, params: { id: 0 }

          expect(subject).to redirect_to(admin_session_path)
          expect(response).to have_http_status(:redirect)
        end
      end
    end

    context 'without session' do
      it 'attempt to create shift as anon' do
        delete :destroy, params: { id: 0 }

        expect(subject).to redirect_to(admin_session_path)
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
