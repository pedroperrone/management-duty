# frozen_string_literal: true

class ShiftExchange < ApplicationRecord
  belongs_to :requested_shift, class_name: Shift.name
  belongs_to :given_up_shift, class_name: Shift.name
  validates :given_up_shift, :requested_shift, presence: true
  with_options unless: :nil_attributes? do
    validate :shifts_length
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
end
