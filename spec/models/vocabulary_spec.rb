require "rails_helper"

RSpec.describe Vocabulary, type: :model do
  describe "validations" do
    it "is valid with english, chinese, category, difficulty" do
      vocab = build(:vocabulary)
      expect(vocab).to be_valid
    end

    it "is invalid without english" do
      vocab = build(:vocabulary, english: nil)
      expect(vocab).not_to be_valid
    end

    it "is invalid without chinese" do
      vocab = build(:vocabulary, chinese: nil)
      expect(vocab).not_to be_valid
    end

    it "is invalid with duplicate english" do
      create(:vocabulary, english: "duplicate")
      vocab = build(:vocabulary, english: "duplicate")
      expect(vocab).not_to be_valid
    end

    it "is invalid with difficulty outside 1..3" do
      vocab = build(:vocabulary, difficulty: 5)
      expect(vocab).not_to be_valid
    end
  end

  describe "scopes" do
    before do
      create(:vocabulary, english: "a", category: "rails", difficulty: 1)
      create(:vocabulary, english: "b", category: "devops", difficulty: 3)
    end

    it "filters by category" do
      expect(Vocabulary.by_category("rails").count).to eq(1)
    end

    it "filters by difficulty" do
      expect(Vocabulary.by_difficulty(3).count).to eq(1)
    end

    it "returns all when category is blank" do
      expect(Vocabulary.by_category("").count).to eq(2)
    end
  end
end
