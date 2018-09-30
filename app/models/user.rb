# frozen_string_literal: true

class User < ApplicationRecord
  enum role: %i[Company_Administrator]
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  before_create :set_default_role

  validates :name, :role, presence: true

  private

  def set_default_role
    self.role ||= :company_admin
  end
end
