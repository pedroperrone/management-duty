# frozen_string_literal: true

class Shift < ApplicationRecord
  belongs_to :user

  validates :ends_at, :starts_at, :user, presence: true
  with_options unless: :nil_attributes? do
    validate :summed_length_limit, :minimum_length, :overlap
  end

  ININTERRUPTED_TIME_LIMIT = 16
  MINIMUM_LENGTH = 1

  def length
    TimeDifference.between(starts_at, ends_at).in_hours
  end

  private

  def summed_length_limit
    return if valid_summed_time?

    errors.add(:limit_time, I18n.t('validations.shift.total_length'))
  end

  def valid_summed_time?
    time_right_before + length + time_right_after <= ININTERRUPTED_TIME_LIMIT
  end

  def time_right_before
    return 0 if following_shift.nil?

    following_shift.length
  end

  def preceding_shift
    @preceding_shift ||= user.shifts.find_by_ends_at(starts_at)
  end

  def time_right_after
    return 0 if preceding_shift.nil?

    preceding_shift.length
  end

  def following_shift
    @following_shift ||= user.shifts.find_by_starts_at(ends_at)
  end

  def minimum_length
    return if length >= MINIMUM_LENGTH

    errors.add(:minimum_length, I18n.t('validations.shift.minimum_length'))
  end

  def overlap
    return unless overlaps_another_shift?

    errors.add(:minimum_length, I18n.t('validations.shift.overlap'))
  end

  def overlaps_another_shift?
    start_overlap_count + end_overlap_count > 0
  end

  def start_overlap_count
    overlap_count(starts_at)
  end

  def end_overlap_count
    overlap_count(ends_at)
  end

  def overlap_count(limit)
    user.shifts
        .where('starts_at < ? AND ends_at > ?', limit, limit).count
  end

  def nil_attributes?
    user.nil? || starts_at.nil? || ends_at.nil?
  end
end
