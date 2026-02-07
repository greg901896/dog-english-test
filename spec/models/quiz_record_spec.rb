require "rails_helper"

RSpec.describe QuizRecord, type: :model do
  describe "associations" do
    it "belongs to user" do
      expect(QuizRecord.reflect_on_association(:user).macro).to eq(:belongs_to)
    end

    it "belongs to vocabulary" do
      expect(QuizRecord.reflect_on_association(:vocabulary).macro).to eq(:belongs_to)
    end
  end

  describe "quiz_mode" do
    it "defaults to input" do
      record = create(:quiz_record)
      expect(record.quiz_mode).to eq("input")
    end

    it "can be set to choice" do
      record = create(:quiz_record, quiz_mode: "choice")
      expect(record.quiz_mode).to eq("choice")
    end
  end
end
