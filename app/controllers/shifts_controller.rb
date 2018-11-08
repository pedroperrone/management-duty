# frozen_string_literal: true

require 'date'
class ShiftsController < ApplicationController

  before_action :logged_in?, except: :index
  before_action :set_user, except: :index
  before_action :authenticate_admin_relationship, except: :index
  before_action :set_shift, except: %i[index create]

  rescue_from ActiveRecord::RecordNotFound, with: :redirect_not_found

  def index
    render 'show', layout: 'dashboard'
  end

  def create
    shift = Shift.new(create_shift_params)
    if shift.save
      redirect_to user_show_path(@user)
    else
      redirect_to user_show_path(@user)
    end



  end

  def update
    if @shift.update(update_shift_params)
      redirect_to user_show_path(@user)
    else
      redirect_to user_show_path(@user)
    end
  end

  def destroy
    if @shift.delete
      redirect_to user_show_path(@user)
    else
      redirect_to root_path
    end
  end

  private

  def logged_in?
    authenticate_admin! || authenticate_user!
  end

  def authenticate_resource_company
    if admin_signed_in?
      return if @shift.user.invited_by == current_admin
    elsif user_signed_in?
      return if @shift.user == current_user
    end
    redirect_to root_path
  end

  def authenticate_admin_relationship
    return if @user.invited_by == current_admin
    redirect_to users_searches_path
  end

  def set_user
    @user = User.find_by_email(params[:user_email])
    redirect_not_found if @user.nil?
  end

  def parsed_date_params(label)
    parse_datetime_from_picker(unwrapped_shift_param(label))
  end

  def create_shift_params
    update_shift_params.merge(user: @user)
  end

  def update_shift_params
    %i[starts_at ends_at].inject({}) do |hash, key|
      hash[key] = parsed_date_params(key)
      hash
    end
  end

  def unwrapped_shift_param(key)
    shift = params[:shift]
    shift[key]
  end

  def set_shift
    @shift = Shift.find(params[:id])
  end

  def redirect_not_found
    redirect_to users_searches_path
  end
end
