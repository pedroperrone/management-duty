# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_admin!, :validate_params

  def show
    @shift = Shift.new
    @user = User.find(id_param)
    @shifts = @user.shifts
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
