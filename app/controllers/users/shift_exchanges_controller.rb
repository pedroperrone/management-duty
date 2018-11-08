# frozen_string_literal: true
require 'management_duty/errors/time_out_of_shift_range_error'

class Users::ShiftExchangesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shifts, :authenticate_given_up_shift_ownership,
                only: :create
  before_action :set_shift_exchange, :authenticate_requested_shift_ownership,
                only: %i[approve refuse]

  rescue_from ActiveRecord::RecordNotFound, with: :redirect_not_found

  def index
    @shift_exchanges = ShiftExchange.pending_for_user(current_user)
  end

  def create
    new_shift_exchenge = ShiftExchange.new(shift_exchange_params)
    if new_shift_exchenge.save
      redirect_to users_searches_path
    else
      redirect_to dashboard_path
    end
  end

  def approve
    if @shift_exchange.be_approved_by_user
      redirect_to user_show_path(current_user.id)
    else
      redirect_to user_show_path(current_user.id)
    end
  end

  def refuse
    if @shift_exchange.be_refused_by_user
      redirect_to dashboard_path
    else
      redirect_to root_path
    end
  end

  private

  def set_shifts
    @given_up_shift = Shift.find(params[:given_up_shift_id])
    @requested_shift = Shift.find(params[:requested_shift_id])
  end

  def redirect_not_found
    redirect_to root_path
  end

  def authenticate_given_up_shift_ownership
    return if current_user_owns_given_up_shift?

    redirect_to root_path
  end

  def current_user_owns_given_up_shift?
    @given_up_shift.user_id == current_user.id
  end

  def shift_exchange_params
    { given_up_shift: @given_up_shift, requested_shift: @requested_shift }
  end

  def set_shift_exchange
    @shift_exchange = ShiftExchange.find(params[:id])
  end

  def authenticate_requested_shift_ownership
    return if current_user_owns_requested_shift?

    redirect_to root_path
  end

  def current_user_owns_requested_shift?
    @shift_exchange.requested_shift.user_id == current_user.id
  end
end
