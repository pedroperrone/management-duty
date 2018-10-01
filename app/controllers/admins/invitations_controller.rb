# frozen_string_literal: true

class Admins::InvitationsController < ApplicationController
  def index
    @collaborators = User.where(invited_by_id: current_admin.id)
    render layout: 'dashboard'
  end
end
