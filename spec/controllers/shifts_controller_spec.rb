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

        it 'attempt to create new shift page as user' do
          get :new

          expect(subject).to redirect_to(admin_session_path)
        end
      end
    end

    context 'without session' do
      it 'attempt to create new shift as anon' do
        get :new

        expect(response).to redirect_to(admin_session_path)
      end
    end
    
  end

  describe "GET #edit" do
    context 'with session' do
      before { sign_in resource }
      
      context 'admin session' do
        let!(:resource) { FactoryBot.create(:admin) }

        context 'valid shift' do 
          let!(:shift_param) { FactoryBot.create(:shift, :with_user) }

          it 'render edit shift page as admin' do
            post :edit, params: { :id => shift_param.id.to_s }

            expect(response).to have_http_status(:success)
          end
        end

        context 'invalid shift' do
          it 'attempt to edit invalid shift as admin' do
            post :edit, params: { :id => '0' }

            expect(response).to redirect_to(root_path)
          end
        end
      end
      
      context 'user session' do
        let!(:resource) { FactoryBot.create(:user) }

        it 'attempt to edit shift as user' do
          post :edit, params: {:id => '0'}
          
          expect(subject).to redirect_to(admin_session_path)
        end
      end
    end
    
    context 'without session' do
      it 'attempt to edit shift as anon' do
        post :edit, params: {:id => '0'}

        expect(subject).to redirect_to(admin_session_path)
      end
    end
  end

end
