# frozen_string_literal: true

require 'rails_helper'
require 'management_duty/errors/time_out_of_shift_range_error'

RSpec.describe ShiftPartitionsController, type: :controller do
  describe 'PUT #partitionate' do
    context 'without user session' do
      it 'redirects to user session path' do
        put :partitionate, params: { id: 1 }

        expect(subject).to redirect_to(user_session_path)
      end
    end

    context 'with user session' do
      let!(:user) { FactoryBot.create(:user) }

      before { sign_in user }
      context 'user does not own the shift' do
        let!(:shift) { FactoryBot.create(:shift, :with_user) }

        it 'redirects to dashboard' do
          put :partitionate, params: { id: shift.id }

          expect(subject).to redirect_to(dashboard_path)
        end
      end

      context 'user owns the shift' do
        let!(:shift) { FactoryBot.create(:shift, user: user) }

        context 'shift does not exist' do
          it 'redirects to dashboard' do
            put :partitionate, params: { id: 99_999 }

            expect(subject).to redirect_to(dashboard_path)
          end
        end

        context 'shift exists' do
          let(:params) do
            {
              params: {
                id: shift.id,
                partition_time: to_datetime_picker_format(partition_time)
              }
            }
          end

          context 'shift does not contain the param time' do
            let(:partition_time) { shift.starts_at - 3.hour }
            it 'redirect_to dashboard' do
              put :partitionate, params

              expect(subject).to redirect_to(dashboard_path)
            end
          end

          context 'new shifts wont be valid' do
            let(:partition_time) { shift.starts_at + 30.minute }
            it 'redirect_to dashboard' do
              put :partitionate, params

              expect(subject).to redirect_to(dashboard_path)
            end
          end

          context 'partition is valid' do
            let(:partition_time) { shift.starts_at + 3.hour }
            it 'redirects to dashboard' do
              expect { put :partitionate, params }
                .to change(::Shift, :count).by(2)

              expect(subject).to redirect_to(user_show_path(user))
            end
          end
        end
      end
    end
  end
end
