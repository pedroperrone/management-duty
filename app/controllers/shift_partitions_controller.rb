# frozen_string_literal: true

require 'management_duty/errors/time_out_of_shift_range_error'
require 'management_duty/shift/partitionator.rb'

class ShiftPartitionsController < ApplicationController
  before_action :authenticate_user!, :authenticate_shift_ownership

  rescue_from ActiveRecord::RecordNotFound, with: :redirect_not_found
  rescue_from ManagementDuty::Errors::TimeOutOfShiftRangeError,
              with: :redirect_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :redirect_not_found

  def partitionate
    ManagementDuty::Shift::Partitionator.new(shift)
                                        .partitionate_at(partition_time)
    redirect_to user_show_path(current_user)
  end

  private

  def authenticate_shift_ownership
    return if shift.user == current_user

    redirect_to dashboard_path
  end

  def shift
    @shift ||= Shift.find(params[:id])
  end

  def redirect_not_found
    redirect_to dashboard_path
  end

  def partition_time
    params[:partition_time]
  end
end
