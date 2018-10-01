# frozen_string_literal: true

class Admin < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, :company_name, presence: true
  validates_uniqueness_of :company_name, case_sensitive: false

  def has_invitations_left?
    true
  end

  def decrement_invitation_limit!
    true
  end
end
