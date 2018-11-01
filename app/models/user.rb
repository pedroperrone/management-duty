# frozen_string_literal: true

class User < ApplicationRecord
  include PgSearch
  pg_search_scope :search_by_name, against: %i[name role email],

                                   using: {
                                     tsearch: {
                                       any_word: true,
                                       prefix: true
                                     }
                                   }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, :role, presence: true

  has_many :shifts, -> { where(active: true) }

  def same_expertise_level?(user)
    same_role?(user) && same_specialty?(user)
  end

  private

  def same_role?(user)
    role == user.role
  end

  def same_specialty?(user)
    specialty == user.specialty
  end
end
