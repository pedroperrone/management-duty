# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  describe 'GET #show' do
    context 'with session' do
      before { sign_in resource }

      context 'user session' do
        let!(:resource) { FactoryBot.create(:user) }

        it 'render dashboard with index as default page' do
          get :show
          expect(response).to have_http_status(:success)
          expect(subject).to render_template(:index)
        end
      end

      context 'admin session' do
        let!(:resource) { FactoryBot.create(:admin) }

        it 'render dashboard' do
          get :show
          expect(response).to have_http_status(:success)
        end
      end
    end

    context 'without session' do
      it 'rendirect to user_session_path' do
        get :show
        expect(subject).to redirect_to(user_session_path)
      end
    end
  end
end
