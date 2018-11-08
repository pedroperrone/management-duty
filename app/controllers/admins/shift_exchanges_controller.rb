# frozen_string_literal: true

class Admins::ShiftExchangesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_shift_exchange, :validate_admin, except: :index

  rescue_from ActiveRecord::RecordNotFound, with: :redirect_not_found

  def index
    @shift_exchanges = ShiftExchange.pending_for_admin(current_admin)
    render layout: 'dashboard'
  end

  def approve
    if @shift_exchange.be_approved_by_admin
      redirect_to admins_shift_exchanges_path
    else
      redirect_to admins_shift_exchanges_path
    end
  end

  def refuse
    if @shift_exchange.be_refused_by_admin
      redirect_to admins_shift_exchanges_path
    else
      redirect_to admins_shift_exchanges_path
    end
  end

  private

  def set_shift_exchange
    @shift_exchange = ShiftExchange.find(params[:id])
  end

  def redirect_not_found
    redirect_to root_path
  end

  def validate_admin
    # binding.pry
    return if current_admin_invited_shift_owner?

    redirect_to dashboard_path
  end

  def current_admin_invited_shift_owner?
    @shift_exchange.admin == current_admin
  end
end
