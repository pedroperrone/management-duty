# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protected

  def after_sign_in_path_for(resource)
    dashboard_path || stored_location_for(resource) || root_path
  end
end
