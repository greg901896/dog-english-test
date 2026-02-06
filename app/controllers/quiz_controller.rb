class QuizController < ApplicationController
  def index
    @categories = Vocabulary.distinct.pluck(:category)
    scope = Vocabulary.by_category(params[:category]).by_difficulty(params[:difficulty])
    @vocabulary = scope.order("RAND()").first

    return unless @vocabulary.nil?
    redirect_to quiz_path, alert: "目前沒有符合條件的單字"
  end

  def answer
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    user_answer = params[:user_answer].to_s.strip
    correct = @vocabulary.chinese.include?(user_answer) && user_answer.present?

    current_user.quiz_records.create!(
      vocabulary: @vocabulary,
      user_answer: user_answer,
      correct: correct
    )

    if correct
      redirect_to quiz_path(category: params[:category], difficulty: params[:difficulty]),
                  notice: "答對了！ #{@vocabulary.english} = #{@vocabulary.chinese}"
    else
      redirect_to quiz_path(category: params[:category], difficulty: params[:difficulty]),
                  alert: "答錯了！ #{@vocabulary.english} 的正確答案是「#{@vocabulary.chinese}」"
    end
  end

  def mistakes
    mistake_vocab_ids = current_user.quiz_records
      .where(correct: false)
      .select(:vocabulary_id)
      .distinct

    @mistakes = Vocabulary
      .where(id: mistake_vocab_ids)
      .left_joins(:quiz_records)
      .where(quiz_records: { correct: false, user_id: current_user.id })
      .group("vocabularies.id")
      .select("vocabularies.*, COUNT(quiz_records.id) AS wrong_count")
      .order("wrong_count DESC")
  end

  def retry_mistakes
    mistake_vocab_ids = current_user.quiz_records
      .where(correct: false)
      .select(:vocabulary_id)
      .distinct

    @vocabulary = Vocabulary.where(id: mistake_vocab_ids).order("RAND()").first
    @categories = Vocabulary.distinct.pluck(:category)

    if @vocabulary.nil?
      redirect_to quiz_mistakes_path, notice: "沒有答錯的單字，太厲害了！"
    else
      render :index
    end
  end
end
