class Users::ShiftExchangesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_shifts, :authenticate_shift_ownership, only: :create

  rescue_from ActiveRecord::RecordNotFound, with: :redirect_not_found

  def index
    @shift_exchanges = ShiftExchange.pending_for_user(current_user)
  end

  def create
    new_shift_exchenge = ShiftExchange.new(shift_exchange_params)
    if new_shift_exchenge.save
      redirect_to users_shift_exchanges_path
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

  def authenticate_shift_ownership
    return if current_user_owns_given_up_shift?
    redirect_to root_path
  end

  def current_user_owns_given_up_shift?
    @given_up_shift.user == current_user
  end

  def shift_exchange_params
    { given_up_shift: @given_up_shift, requested_shift: @requested_shift }
  end
end
