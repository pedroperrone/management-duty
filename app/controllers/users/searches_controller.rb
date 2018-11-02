# frozen_string_literal: true

class Users::SearchesController < ApplicationController
  before_action :authenticate_user!, :validate_params

  def index
    @search_collaborators = User.search_colleagues(current_user, name_param)

    respond_to do |format|
      format.js { render partial: 'search-results' }
    end
  end

  private

  def validate_params
    return if valid_params?

    render layout: 'dashboard'
  end

  def valid_params?
    name_param.present?
  end

  def name_param
    params[:name]
  end
end
