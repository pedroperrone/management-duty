# frozen_string_literal: true

require 'rails_helper'
require 'management_duty/shift/copier.rb'

describe ManagementDuty::Shift::Copier do
  let!(:old_shift) { FactoryBot.create(:shift, :with_user) }

  describe '.create_copy' do
    context 'with no custom attributes' do
      it 'should create a new shift putting the old one as origin_shift' do
        old_shift.update(active: false)
        expect { described_class.new(old_shift).create_copy }
          .to change(::Shift, :count).by(1)

        new_shift = Shift.last
        expect(new_shift.origin_shift).to eq(old_shift)
        expect(new_shift.active).to be_truthy
        assert_time_equals(new_shift.starts_at, old_shift.starts_at)
        assert_time_equals(new_shift.ends_at, old_shift.ends_at)
        expect(new_shift.user).to eq(old_shift.user)
      end
    end

    context 'with custom attributes' do
      let!(:other_user) { FactoryBot.create(:user) }
      let(:custom_attributes) do
        { user: other_user, ends_at: old_shift.ends_at + 1.hour }
      end

      it 'should create a new shift coping some attributes and customizing' do
        old_shift.update(active: false)
        expect { described_class.new(old_shift, custom_attributes).create_copy }
          .to change(::Shift, :count).by(1)

        new_shift = Shift.last
        expect(new_shift.user).to eq(other_user)
        assert_time_equals(new_shift.starts_at, old_shift.starts_at)
        assert_time_equals(new_shift.ends_at, old_shift.ends_at + 1.hour)
      end
    end
  end
end
