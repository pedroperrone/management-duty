require 'date'

class ShiftController < ApplicationController
  before_action :authenticate_admin!

  before_action :set_user_from_email, only: :create

  before_action :set_user_from_shift, only: :update

  # Views
  def new
    @shift = Shift.new
    @shift.starts_at = 0.hours.from_now
    @shift.ends_at = 1.hours.from_now
    
    render 'new', layout: 'dashboard'
  end

  def edit
    @shift = Shift.find_by_id(params[:shift_id])
    
    render 'edit', layout: 'dashboard'
  end

  # CRUD
  def create
    @shift = Shift.new(shift_params)

    if @shift.save
      redirect_to dashboard_path
    else
      puts @shift.errors.messages
      redirect_to shift_new_path
    end
  end


  def update
    @shift = Shift.find_by_id(params[:shift_id])
    
    if @shift.update(shift_params)
      redirect_to dashboard_path
    else
      puts @shift.errors.messages
      redirect_to shift_new_path
    end
    
  end

  def destroy
  end

  #
  private
  def set_user_from_email
    @user = User.find_by_email(params[:user_email])
    
    redirect_to shift_new_path if @user.nil?
  end

  def set_user_from_shift
    @user = User.find_by_id(Shift.find_by_id(params[:shift_id]).user_id)
    
    redirect_to shift_new_path if @user.nil?
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
