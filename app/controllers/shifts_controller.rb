require 'date'

class ShiftsController < ApplicationController
  before_action :authenticate_admin!

  before_action :set_user, only: :create

  before_action :set_user_from_email, only: :create
  before_action :set_user_from_shift_id, only: :update
  before_action :set_shift, only: :edit

  # Views
  def new
    @shift = Shift.new
    @shift.starts_at = 0.hours.from_now
    @shift.ends_at = 1.hours.from_now
    
    render 'new', layout: 'dashboard'
  end

  def edit
    render 'edit', layout: 'dashboard'
  end

  # CRUD
  def create
    @shift = Shift.new(shift_params)

    if @shift.save
      redirect_to dashboard_path
    else
      puts @shift.errors.messages
      redirect_to new_shift_path
    end
  end

  def update
    @shift = Shift.find_by_id(params[:id])
    
    if @shift.update(shift_params)
      redirect_to dashboard_path
    else
      puts @shift.errors.messages
      redirect_to edit_shift_path
    end
  end

  def destroy
  end

  #
  private
  def set_user_from_email
    @user = User.find_by_email(params[:user_email])
    
    redirect_to new_shift_path if @user.nil?
  end

  def set_user_from_shift_id
    @user = User.find_by_id(Shift.find_by_id(params[:id]).user_id)
    
    redirect_to root_path if @user.nil?
  end

  def set_shift
    @shift = Shift.find_by_id(params[:id])

    redirect_to root_path if @shift.nil?
  end

  #
  def parse_date_params label
    # Method for parsing datetime_select date
    date = DateTime.new(params[:shift][label.to_s + "(1i)"].to_i,
                        params[:shift][label.to_s + "(2i)"].to_i,
                        params[:shift][label.to_s + "(3i)"].to_i,
                        params[:shift][label.to_s + "(4i)"].to_i,
                        params[:shift][label.to_s + "(5i)"].to_i)
  end

  def shift_params
    {
      :starts_at => parse_date_params(:starts_at),
      :ends_at => parse_date_params(:ends_at),
      :user_id => @user.id
    }
  end
end
