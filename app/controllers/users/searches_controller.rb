# frozen_string_literal: true

class Users::SearchesController < ApplicationController
  before_action :authenticate_user!
  def index
    if params[:name]
      admin  = current_user.invited_by_id
      @search_collaborators = User.search_by_name(params[:name])
                                  .where(invited_by_id: admin)
      respond_to do |format|
        format.js { render partial: 'search-results' }
      end
    else
      render layout: 'dashboard'
    end
  end
end
