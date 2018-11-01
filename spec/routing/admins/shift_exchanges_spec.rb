# frozen_string_literal: true

RSpec.describe Admins::ShiftExchangesController, type: :routing do
  describe 'routing' do
    context 'PUT' do
      context 'approve' do
        it 'routes to #accept' do
          expect(put: 'admins/shift_exchanges/42/approve')
            .to route_to('admins/shift_exchanges#approve', id: '42')
        end
      end

      context 'refuse' do
        it 'routes to #refuse' do
          expect(put: 'admins/shift_exchanges/42/refuse')
            .to route_to('admins/shift_exchanges#refuse', id: '42')
        end
      end
    end

    describe 'GET' do
      it 'routes to #index' do
        expect(get: 'admins/shift_exchanges')
          .to route_to('admins/shift_exchanges#index')
      end
    end
  end
end
