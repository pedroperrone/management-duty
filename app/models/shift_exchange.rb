# frozen_string_literal: true

class ShiftExchange < ApplicationRecord
  belongs_to :requested_shift, class_name: Shift.name
  belongs_to :given_up_shift, class_name: Shift.name
  validates :given_up_shift, :requested_shift, presence: true
  with_options unless: :nil_attributes? do
    validate :shifts_length
  end

  scope :pending_for_user, lambda { |user|
    where(pending_user_approval: true)
      .joins('JOIN shifts ON shifts.id = shift_exchanges.requested_shift_id')
      .where('shifts.user_id = ?', user.id)
  }

  scope :pending_for_admin, lambda { |admin|
    where(pending_user_approval: false, approved_by_user: true)
      .joins('JOIN shifts ON shifts.id = shift_exchanges.given_up_shift_id')
      .joins('JOIN users ON shifts.user_id = users.id')
      .where('users.invited_by_id = ?', admin.id)
  }

  def be_approved_by_user
    be_judged_by_user(true)
    perform_exchange if autoapproved?
  end

  def be_refused_by_user
    be_judged_by_user(false)
  end

  private

  def shifts_length
    return if shifts_with_same_length?

    errors.add(:shifts_length,
               I18n.t('validations.shift_exchange.shifts_length'))
  end

  def shifts_with_same_length?
    requested_shift.length == given_up_shift.length
  end

  def nil_attributes?
    requested_shift.nil? || given_up_shift.nil?
  end

  def be_judged_by_user(user_response)
    update(pending_user_approval: false, approved_by_user: user_response)
  end

  def autoapproved?
    requested_shift.user.same_expertise_level?(given_up_shift.user)
  end

  def perform_exchange
    ActiveRecord::Base.transaction do
      inactivate_shifts
      create_copies
    end
  end

  def inactivate_shifts
    given_up_shift.update(active: false)
    requested_shift.update(active: false)
  end

  def create_copies
    ManagementDuty::Shift::Copier.new(
      given_up_shift, given_up_shift_custom_attributes
    ).create_copy

    ManagementDuty::Shift::Copier.new(
      requested_shift, requested_shift_custom_attributes
    ).create_copy
  end

  def given_up_shift_custom_attributes
    { user: requested_shift.user }
  end

  def requested_shift_custom_attributes
    { user: given_up_shift.user }
  end
end
