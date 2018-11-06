# frozen_string_literal: true

require 'date'

class ShiftsController < ApplicationController
  before_action :authenticate_admin!, except: %i[show index]
  before_action :authenticate_any!, only: %i[show index]

  before_action :set_visibility, except: %i[new index]

  before_action :set_user_from_email, only: %i[edit destroy]

  before_action :set_user_from_id, only: [:show]
  before_action :set_user_from_shift, only: %i[edit destroy]
  before_action :set_user_from_email, only: %i[create update]

  before_action :validate_visibility, except: %i[new update index]

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
      redirect_to user_show_path(@user)
    else
      redirect_to user_show_path(@user)
    end
  end

  def update
    # set_shift_from_id
    # set_user_from_shift
    puts '--------------------------------'
    @shift = Shift.find(params[:shift_id])
    if @shift.update(update_params)
      redirect_to user_show_path(@user)
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
    redirect_to root_path if @user.nil? || @collabs.where(id: @user.id).count.zero?
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
    puts '-------------------------------------'
    puts label
    DateTime.strptime(label,'%d/%m/%Y %I:%M %p')
  end

  def shift_params
    shift = params[:shift]
    puts shift
    {
      starts_at: parsed_date_params(shift[:starts_at]),
      ends_at: parsed_date_params(shift[:ends_at]),
      user_id: @user.id
    }
  end

  def update_params
    {
      starts_at: parsed_date_params(params[:starts_at]),
      ends_at: parsed_date_params(params[:ends_at])
    }
  end

end
