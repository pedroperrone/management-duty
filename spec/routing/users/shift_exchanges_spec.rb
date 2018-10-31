# frozen_string_literal: true

RSpec.describe Users::ShiftExchangesController, type: :routing do
  describe 'routing' do
    context 'POST' do
      it 'routes to #create' do
        expect(post: 'users/shift_exchanges')
          .to route_to('users/shift_exchanges#create')
      end
    end

    context 'PUT' do
      context 'approve' do
        it 'routes to #accept' do
          expect(put: 'users/shift_exchanges/42/approve')
            .to route_to('users/shift_exchanges#approve', id: '42')
        end
      end

      context 'refuse' do
        it 'routes to #refuse' do
          expect(put: 'users/shift_exchanges/42/refuse')
            .to route_to('users/shift_exchanges#refuse', id: '42')
        end
      end
    end

    describe 'GET' do
      it 'routes to #index' do
        expect(get: 'users/shift_exchanges')
          .to route_to('users/shift_exchanges#index')
      end
    end
  end
end
