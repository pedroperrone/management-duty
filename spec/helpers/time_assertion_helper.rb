# frozen_string_literal: true

module TimeAssertionHelper
  def assert_time_equals(actual_time, expected_time)
    expect(actual_time.strftime('%Y/%m/%d %H:%M:%S'))
      .to eq(expected_time.strftime('%Y/%m/%d %H:%M:%S'))
  end

  def to_datetime_picker_format(datetime)
    datetime.strftime('%d/%m/%Y %I:%M %p')
  end
end
