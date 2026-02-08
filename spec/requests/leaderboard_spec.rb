require "rails_helper"

RSpec.describe "Leaderboard", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /leaderboard" do
    it "returns success" do
      get leaderboard_path
      expect(response).to have_http_status(:ok)
    end

    it "shows ranking after answering" do
      vocab = create(:vocabulary)
      create(:quiz_record, user: user, vocabulary: vocab, correct: true, quiz_mode: "choice")
      get leaderboard_path
      expect(response.body).to include(user.username)
    end

    it "shows title based on accuracy" do
      vocab = create(:vocabulary)
      5.times { create(:quiz_record, user: user, vocabulary: vocab, correct: true, quiz_mode: "choice") }
      get leaderboard_path
      expect(response.body).to include("好狗")
    end
  end
end
