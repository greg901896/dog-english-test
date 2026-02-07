require "rails_helper"

RSpec.describe "Favorites", type: :request do
  let(:user) { create(:user) }
  let(:vocab) { create(:vocabulary) }

  before { sign_in user }

  describe "GET /favorites" do
    it "returns success" do
      get favorites_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /favorites/:vocabulary_id" do
    it "creates a favorite" do
      expect {
        post favorite_create_path(vocabulary_id: vocab.id)
      }.to change(Favorite, :count).by(1)
    end

    it "does not duplicate favorites" do
      create(:favorite, user: user, vocabulary: vocab)
      expect {
        post favorite_create_path(vocabulary_id: vocab.id)
      }.not_to change(Favorite, :count)
    end
  end

  describe "DELETE /favorites/:vocabulary_id" do
    it "removes a favorite" do
      create(:favorite, user: user, vocabulary: vocab)
      expect {
        delete favorite_path(vocabulary_id: vocab.id)
      }.to change(Favorite, :count).by(-1)
    end
  end
end
