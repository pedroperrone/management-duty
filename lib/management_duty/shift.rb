module ManagementDuty
  class Shift
    def initialize(shift)
      @shift = shift
    end

    def partitionate(partition_time)
      unless @shift.contains?(partition_time)
        raise ManagementDuty::Errors::TimeOutOfShiftRangeError
      end
      first_new_shift = ::Shift.new(first_shift_params(partition_time))
      second_new_shift = ::Shift.new(second_shift_params(partition_time))
      ActiveRecord::Base.transaction do
        @shift.update!(active: false)
        first_new_shift.save!
        second_new_shift.save!
      end
    end

    private

    def first_shift_params(partition_time)
      { starts_at: @shift.starts_at, ends_at: partition_time }
        .merge(default_params)
    end

    def second_shift_params(partition_time)
      { starts_at: partition_time, ends_at: @shift.ends_at}
        .merge(default_params)
    end

    def default_params
      { user: @shift.user, origin_shift: @shift }
    end
  end
end
