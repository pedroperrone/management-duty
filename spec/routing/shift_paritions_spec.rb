# frozen_string_literal: true

RSpec.describe ShiftPartitionsController, type: :routing do
  describe 'routing' do
    it 'routes to paritionante' do
      expect(put: 'shift_partitions/12')
        .to route_to('shift_partitions#partitionate', id: '12')
    end
  end
end
