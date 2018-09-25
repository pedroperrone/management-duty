class DashboardController < ApplicationController
  def show
    render params[:page]
  end
end
