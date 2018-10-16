# frozen_string_literal: true

class Shift < ApplicationRecord
  belongs_to :user
  belongs_to :origin_shift, class_name: Shift.name, optional: true

  validates :ends_at, :starts_at, :user, presence: true
  with_options unless: :nil_attributes? do
    validate :summed_length_limit, :minimum_length, :overlap
  end

  ININTERRUPTED_TIME_LIMIT = 16
  MINIMUM_LENGTH = 1

  def length
    TimeDifference.between(starts_at, ends_at).in_hours
  end

  def prepended_length
    return 0 if prepended_shift.nil?

    prepended_shift.length + prepended_shift.prepended_length
  end

  def appended_length
    return 0 if appended_shift.nil?

    appended_shift.length + appended_shift.appended_length
  end

  def contains?(time)
    time >= starts_at && time < ends_at
  end

  private

  def summed_length_limit
    return if valid_summed_time?

    errors.add(:limit_time, I18n.t('validations.shift.total_length'))
  end

  def minimum_length
    return if length >= MINIMUM_LENGTH

    errors.add(:minimum_length, I18n.t('validations.shift.minimum_length'))
  end

  def overlap
    return unless overlaps_another_shift?

    errors.add(:overlap, I18n.t('validations.shift.overlap'))
  end

  def valid_summed_time?
    prepended_length + length + appended_length <= ININTERRUPTED_TIME_LIMIT
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

  def prepended_shift
    @prepended_shift ||= user.shifts.find_by_ends_at(starts_at)
  end

  def appended_shift
    @appended_shift ||= user.shifts.find_by_starts_at(ends_at)
  end
end
