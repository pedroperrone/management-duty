module ManagementDuty
  module Errors
    class TimeOutOfShiftRangeError < StandardError
      def initialize
        super(I18n.t('lib.shift.partitionate'))
      end
    end
  end
end
