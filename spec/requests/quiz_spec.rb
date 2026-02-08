require "rails_helper"

RSpec.describe "Quiz", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
    create_list(:vocabulary, 5, category: "rails")
  end

  describe "GET /quiz/choice" do
    it "returns success" do
      get quiz_choice_path
      expect(response).to have_http_status(:ok)
    end

    it "shows 4 choice options" do
      get quiz_choice_path
      expect(response.body.scan("btn-choice").size).to eq(4)
    end
  end

  describe "GET /quiz/mistakes" do
    it "returns success" do
      get quiz_mistakes_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /quiz/retry" do
    it "redirects when no mistakes" do
      get quiz_retry_path
      expect(response).to redirect_to(quiz_mistakes_path)
    end

    it "shows retry quiz when mistakes exist" do
      vocab = Vocabulary.first
      create(:quiz_record, user: user, vocabulary: vocab, correct: false)
      get quiz_retry_path
      expect(response).to have_http_status(:ok)
    end
  end

  context "unauthenticated" do
    before { sign_out user }

    it "redirects to login" do
      get quiz_choice_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
