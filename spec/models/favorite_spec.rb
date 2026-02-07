require "rails_helper"

RSpec.describe Favorite, type: :model do
  describe "validations" do
    it "is valid with user and vocabulary" do
      fav = build(:favorite)
      expect(fav).to be_valid
    end

    it "prevents duplicate favorites for same user and vocabulary" do
      user = create(:user)
      vocab = create(:vocabulary)
      create(:favorite, user: user, vocabulary: vocab)
      dup = build(:favorite, user: user, vocabulary: vocab)
      expect(dup).not_to be_valid
    end
  end
end
