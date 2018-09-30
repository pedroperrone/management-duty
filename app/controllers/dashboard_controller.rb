# frozen_string_literal: true

class DashboardController < ApplicationController
  def show
    if user_signed_in? || admin_signed_in?
      render page, layout: 'dashboard'
    else
      redirect_to user_session_path
    end
  end

  private

  def page
    params[:page] || 'index'
  end
end
