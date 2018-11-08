# frozen_string_literal: true

module TimeAssertionHelper
  def assert_time_equals(actual_time, expected_time)
    expect(actual_time.strftime('%Y/%m/%d %H:%M:%S'))
      .to eq(expected_time.strftime('%Y/%m/%d %H:%M:%S'))
  end

  def to_datetime_picker_format(datetime)
    datetime = datetime.to_datetime if datetime.class == String
    datetime.strftime('%m/%d/%Y %I:%M %p')
  end
end
