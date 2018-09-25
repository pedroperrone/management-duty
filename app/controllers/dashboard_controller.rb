# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    render params[:page], layout: 'dashboard'
  end
end
