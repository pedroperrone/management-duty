require 'rails_helper'

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

  describe "edit_shift GET, #edit" do
    context 'with session' do
      before { sign_in resource }
      
      context 'admin session' do
        let!(:resource) { FactoryBot.create(:admin) }

        context 'valid shift' do
          let!(:shift_user) { FactoryBot.create(:user, invited_by: resource) }
          let!(:shift_param) { FactoryBot.create(:shift, user: shift_user) }

          it 'render edit shift page as admin' do
            get :edit, params: { :id => shift_param.id.to_s }

            expect(response).to have_http_status(:success)
          end
        end

        context 'invalid shift' do
          let!(:shift_param) { FactoryBot.create(:shift, :with_user) }
          
          it 'attempt to edit invalid shift as admin' do
            get :edit, params: { :id => shift_param.id.to_s }

            expect(response).to redirect_to(root_path)
          end
        end
      end
      
      context 'user session' do
        let!(:resource) { FactoryBot.create(:user) }

        it 'attempt to edit shift as user' do
          get :edit, params: {:id => '0'}
          
          expect(subject).to redirect_to(admin_session_path)
        end
      end
    end
    
    context 'without session' do
      it 'attempt to edit shift as anon' do
        get :edit, params: {:id => '0'}

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
            get :show, params: { :id => shift_user.id.to_s }

            expect(response).to have_http_status(:success)
          end
        end

        context 'invalid shift' do
          pending
        end
      end
      
      context 'user session' do
        let!(:resource) { FactoryBot.create(:user) }

        it 'attempt to views own shifts as user' do
          get :show, params: {:id => resource.id.to_s}
          
          expect(response).to have_http_status(:success)
        end

        it 'attempt to views other\'s shifts as user' do
          get :show, params: {:id => (resource.id+1).to_s}
          
          expect(response).to have_http_status(:redirect)
        end
      end
    end
    
    context 'without session' do
      it 'attempt to view shifts as anon' do
        get :show, params: {:id => '0'}

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

        context 'valid shift' do
          let!(:shift_user) { FactoryBot.create(:user, invited_by: resource) }

          it 'create valid shift as admin' do
            post :create, params: {
                   :shift => {
                     'starts_at(1i)' => 2018,
                     'starts_at(2i)' => 1,
                     'starts_at(3i)' => 1,
                     'starts_at(4i)' => 1,
                     'starts_at(5i)' => 1,
                     'ends_at(1i)' => 2018,
                     'ends_at(2i)' => 1,
                     'ends_at(3i)' => 1,
                     'ends_at(4i)' => 2,
                     'ends_at(5i)' => 1
                   },
                   :user_email => shift_user.email }

            expect(Shift.count).to eq 1
            expect(response).to have_http_status(:success)
          end

          it 'create invalid (too short) shift as admin' do
            post :create, params: {
                   :shift => {
                     'starts_at(1i)' => 2018,
                     'starts_at(2i)' => 1,
                     'starts_at(3i)' => 1,
                     'starts_at(4i)' => 1,
                     'starts_at(5i)' => 1,
                     'ends_at(1i)' => 2018,
                     'ends_at(2i)' => 1,
                     'ends_at(3i)' => 1,
                     'ends_at(4i)' => 1,
                     'ends_at(5i)' => 1
                   },
                   :user_email => shift_user.email }

            expect(Shift.count).to eq 0
            expect(subject).to redirect_to(new_shift_path)
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

        expect(subject).to redirect_to(admin_session_path)
      end
    end
  end
  
  describe "PATCH, #update" do
    context 'with session' do
      before { sign_in resource }
      
    end

    context 'without session' do
      it 'attempt to create shift as anon' do
        put :update, params: { :id => 0.to_s}

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
          let!(:user_shift) { FactoryBot.create(:shift, :with_user, user_id: shift_owner.id) }

          it 'destroy existing shift as admin' do
            delete :destroy, params: { :id => user_shift.id }

            expect(response).to have_http_status(:success)
            expect(Shift.count).to eq 0
          end
        end

        context 'invalid (other company) shift' do
          let!(:user_shift) { FactoryBot.create(:shift, :with_user) }

          it 'attempt to destroy other\'s shift' do
            delete :destroy, params: { :id => user_shift.id }

            expect(Shift.count).to eq 1
            expect(subject).to redirect_to root_path
          end
        end
      end

      context 'user session' do
        let!(:resource) { FactoryBot.create(:user) }

        it 'attempt to destroy shift as user' do
          delete :destroy, params: { :id => 0.to_s }

          expect(subject).to redirect_to(admin_session_path)
        end
      end
    end

    context 'without session' do
      it 'attempt to create shift as anon' do
        delete :destroy, params: { :id => 0.to_s }

        expect(subject).to redirect_to(admin_session_path)
      end
    end
  end
end
