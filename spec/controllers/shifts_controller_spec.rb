require 'rails_helper'

RSpec.describe ShiftsController, type: :controller do
  describe "GET #new" do
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

        it 'render new shift page as user' do
          get :new
          expect(subject).to redirect_to(admin_session_path)
        end
      end
    end

    context 'without sessoin' do
      it 'render new shift as anon' do
        get :new
        expect(response).to redirect_to(admin_session_path)
      end
    end
    
  end

  describe "GET #edit" do
    pending
  end

end
