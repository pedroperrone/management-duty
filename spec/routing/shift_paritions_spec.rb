# frozen_string_literal: true

RSpec.describe ShiftPartitionsController, type: :routing do
  describe 'routing' do
    it 'routes to paritionante' do
      expect(put: 'shift_partitions')
        .to route_to('shift_partitions#partitionate')
    end
  end
end
