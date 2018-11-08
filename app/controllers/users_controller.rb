# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :validate_params

  def show
    @shift = Shift.new
    @user = User.find(id_param)
    user = @user
    @shifts = @user.shifts
    if current_user
      @my_shifts = current_user.shifts
      @my_shift_exchanges = ShiftExchange.pending_for_user(current_user)
    end
    @shift_exchanges = ShiftExchange.pending_for_user(user)
    render layout: 'profile'
  end

  private

  def validate_params
    return if valid_params?
  end

  def valid_params?
    id_param.present?
  end

  def id_param
    params[:id]
  end

end
