# frozen_string_literal: true

module ManagementDuty
  module Shift
    class Copier
      REJECTED_ATTRIBUTES = %w[id created_at updated_at active].freeze
      def initialize(shift, custom_attributes = {})
        @shift = shift
        @custom_attributes = custom_attributes
      end

      def create_copy
        new_shift = ::Shift.new(new_shift_attributes)
        new_shift.save
      end

      private

      def new_shift_attributes
        inherited_attributes.merge(@custom_attributes)
                            .merge('origin_shift_id' => @shift.id)
      end

      def inherited_attributes
        @shift.as_json.except(*REJECTED_ATTRIBUTES)
      end
    end
  end
end
