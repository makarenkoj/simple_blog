require 'rails_helper'

RSpec.describe PostView, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:post) }
    it { is_expected.to belong_to(:user).optional }
  end
end
