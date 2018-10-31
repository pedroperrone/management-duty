# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale

  protected

  def after_sign_in_path_for(resource)
    dashboard_path || stored_location_for(resource) || root_path
  end

  def authenticate_inviter!
    authenticate_admin!(force: true)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:accept_invitation, keys: %i[name role])
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end
