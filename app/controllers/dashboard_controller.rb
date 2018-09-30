# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    if user_signed_in?
      render params[:page], layout: 'dashboard'
    else
      redirect_to root_path
    end
  end
end
