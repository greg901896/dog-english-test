require "rails_helper"

RSpec.describe "Dashboard", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /dashboard" do
    it "returns success" do
      get dashboard_path
      expect(response).to have_http_status(:ok)
    end

    it "shows statistics" do
      get dashboard_path
      expect(response.body).to include("總答題數")
    end

    it "shows mode stats after answering" do
      vocab = create(:vocabulary)
      create(:quiz_record, user: user, vocabulary: vocab, correct: true, quiz_mode: "choice")
      get dashboard_path
      expect(response.body).to include("選擇題")
    end
  end
end
