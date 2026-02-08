class FavoritesController < ApplicationController
  def index
    @favorites = current_user.favorites.includes(:vocabulary).order(created_at: :desc)
  end

  def create
    vocabulary = Vocabulary.find(params[:vocabulary_id])
    current_user.favorites.find_or_create_by!(vocabulary: vocabulary)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "favorite_btn_#{vocabulary.id}",
          partial: "shared/favorite_button",
          locals: { vocabulary: vocabulary, favorited: true }
        )
      end
      format.html { redirect_back fallback_location: quiz_choice_path }
    end
  end

  def destroy
    vocabulary = Vocabulary.find(params[:vocabulary_id])
    current_user.favorites.find_by(vocabulary: vocabulary)&.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "favorite_btn_#{vocabulary.id}",
          partial: "shared/favorite_button",
          locals: { vocabulary: vocabulary, favorited: false }
        )
      end
      format.html { redirect_back fallback_location: favorites_path }
    end
  end
end
