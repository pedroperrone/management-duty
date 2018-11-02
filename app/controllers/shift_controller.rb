require 'date'

class ShiftController < ApplicationController
  before_action :authenticate_admin!
  
  def new
    render 'new', layout: 'dashboard'
  end

  def create
    start_date = DateTime.new(params["day1"]["starts_at(1i)"].to_i, 
                            params["day1"]["starts_at(2i)"].to_i,
                            params["day1"]["starts_at(3i)"].to_i,
                            params["day1"]["starts_at(4i)"].to_i,
                            params["day1"]["starts_at(5i)"].to_i)

    end_date = DateTime.new(params["day2"]["ends_at(1i)"].to_i, 
                            params["day2"]["ends_at(2i)"].to_i,
                            params["day2"]["ends_at(3i)"].to_i,
                            params["day2"]["ends_at(4i)"].to_i,
                            params["day2"]["ends_at(5i)"].to_i)

    user = User.find_by email: params[:user_email]

    if user
      user_id = user['id'].to_i

      @shift = Shift.new({starts_at: start_date, ends_at: end_date, user_id: user_id})
      
      if @shift.save
        redirect_to '/dashboard'

      else
        # Erro ao criar turno
        redirect_to '/shift/new'
      end

    else
      # Erro ao obter id do usuario
      redirect_to '/shift/new'
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
