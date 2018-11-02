# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'an user with same expertise' do
  it 'should be true' do
    expect(user.same_expertise_level?(other_user)).to be_truthy
  end
end

RSpec.shared_examples 'an user with different expertise' do
  it 'should be true' do
    expect(user.same_expertise_level?(other_user)).to be_falsey
  end
end

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:role) }
  end

  describe 'scopes' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:shift_one) { FactoryBot.create(:shift, :inactive, user: user) }
    let!(:shift_two) { FactoryBot.create(:shift, user: user) }

    it 'should contain only active shifts' do
      expect(user.shifts).to include(shift_two)
      expect(user.shifts).not_to include(shift_one)
    end

    context '.search_colleagues' do
      let!(:admin_one) { FactoryBot.create(:admin) }
      let!(:admin_two) { FactoryBot.create(:admin) }
      let!(:user) { FactoryBot.create(:user, invited_by: admin_one) }
      let!(:colleage_one) do
        FactoryBot.create(:user, invited_by: admin_one, name: 'AAA',
                                 role: 'AAA', email: 'AA@A')
      end
      let!(:colleage_two) do
        FactoryBot.create(:user, invited_by: admin_one, name: 'ZZZ',
                                 role: 'ZZZ', email: 'ZZ@Z')
      end
      let!(:user_from_another_company) do
        FactoryBot.create(
          :user, invited_by: admin_two, name: colleage_one.name,
                 role: colleage_one.role, email: "a#{colleage_one.email}"
        )
      end

      it 'should return compatible users from the same company' do
        scope_response = User.search_colleagues(user, 'Aa')
        expect(scope_response).to include(colleage_one)
        expect(scope_response)
          .not_to include(colleage_two, user, user_from_another_company)
      end
    end
  end

  describe '.same_expertise_level?' do
    context 'with specialty' do
      let!(:user) do
        FactoryBot.create(:user, role: 'Programmer', specialty: 'Ruby')
      end

      context 'given user also has specialty' do
        context 'the specialty is the same' do
          context 'the role is the same' do
            let!(:other_user) do
              FactoryBot.create(:user, role: 'Programmer', specialty: 'Ruby')
            end

            it_should_behave_like 'an user with same expertise'
          end

          context 'the role is different' do
            let!(:other_user) do
              FactoryBot.create(:user, role: 'Programmer', specialty: 'Java')
            end

            it_should_behave_like 'an user with different expertise'
          end
        end

        context 'the specialty is different' do
          let!(:other_user) do
            FactoryBot.create(:user, role: 'Programmer', specialty: 'Java')
          end

          it_should_behave_like 'an user with different expertise'
        end
      end

      context 'given user does not have specialty' do
        let!(:other_user) do
          FactoryBot.create(:user, role: 'Fireman')
        end

        it_should_behave_like 'an user with different expertise'
      end
    end

    context 'without specialty' do
      let!(:user) do
        FactoryBot.create(:user, role: 'Fireman')
      end

      context 'the role is the same' do
        let!(:other_user) do
          FactoryBot.create(:user, role: 'Fireman')
        end

        it_should_behave_like 'an user with same expertise'
      end

      context 'the role is different' do
        let!(:other_user) do
          FactoryBot.create(:user, role: 'Smith')
        end

        it_should_behave_like 'an user with different expertise'
      end
    end
  end
end
