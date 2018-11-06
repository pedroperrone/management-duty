# frozen_string_literal: true

require 'date'

class ShiftsController < ApplicationController
  before_action :authenticate_admin!, except: %i[show index]
  before_action :authenticate_any!, only: %i[show index]

  before_action :set_visibility, except: %i[new index]

  before_action :set_shift_from_id, only: %i[edit update destroy]

  before_action :set_user_from_id, only: [:show]
  before_action :set_user_from_shift, only: %i[edit update destroy]
  before_action :set_user_from_email, only: :create

  before_action :validate_visibility, except: %i[new index]

  # Views
  def new
    render 'new', layout: 'dashboard'
  end

  def edit
    # set_shift_from_id
    render 'edit', layout: 'dashboard'
  end

  def show
    # set_user_from_id
    render 'show', layout: 'dashboard'
  end

  def index
    render 'show', layout: 'dashboard'
  end

  # CRUD
  def create
    # set_user_from_email
    @shift = Shift.new(shift_params)

    if @shift.save
      render 'show', layout: 'dashboard'
    else
      redirect_to new_shift_path
    end
  end

  def update
    # set_shift_from_id
    # set_user_from_shift

    if @shift.update(shift_params)
      render 'show', layout: 'dashboard'
    else
      redirect_to edit_shift_path
    end
  end

  def destroy
    # set_shift_from_id

    if @shift.delete
      render 'show', layout: 'dashboard'
    else
      redirect_to root_path
    end
  end

  private

  def set_visibility
    @collabs = if admin_signed_in?
                 User.where(invited_by: current_admin)
               else
                 User.where(invited_by: current_user.invited_by)
                     end
    @shifts = Shift.where(user_id: @collabs.select(:id))
  end

  def validate_visibility
    if @user.nil? || @collabs.where(id: @user.id).count == 0
      redirect_to root_path
    end
  end

  def set_shift_from_id
    # When a shift id is passed on params

    @shift = Shift.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  def set_user_from_shift
    @user = User.where(invited_by: current_admin).find(@shift.user_id)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  def set_user_from_email
    # When an user e-mail is passed on params

    @user = User.find_by_email(params[:user_email])
  rescue ActiveRecord::RecordNotFound
    redirect_to new_shift_path
  end

  def set_user_from_id
    # When an user id is passed on params

    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path
  end

  def parsed_date_params(label)
    # Method for parsing datetime_select date
    date = DateTime.new(params[:shift][label.to_s + "(1i)"].to_i,
                        params[:shift][label.to_s + "(2i)"].to_i,
                        params[:shift][label.to_s + "(3i)"].to_i,
                        params[:shift][label.to_s + "(4i)"].to_i,
                        params[:shift][label.to_s + "(5i)"].to_i)
  end

  def shift_params
    {

      starts_at: parsed_date_params(:starts_at),
      ends_at: parsed_date_params(:ends_at),
      user_id: @user.id
    }
  end
end
