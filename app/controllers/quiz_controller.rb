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

  def choice
    @categories = Vocabulary.distinct.pluck(:category)
    scope = Vocabulary.by_category(params[:category]).by_difficulty(params[:difficulty])
    @vocabulary = scope.order("RAND()").first

    if @vocabulary.nil?
      redirect_to quiz_choice_path, alert: "目前沒有符合條件的單字"
      return
    end

    @options = generate_options(@vocabulary)
  end

  def choice_answer
    @vocabulary = Vocabulary.find(params[:vocabulary_id])
    user_answer = params[:user_answer].to_s.strip
    correct = user_answer == @vocabulary.chinese

    current_user.quiz_records.create!(
      vocabulary: @vocabulary,
      user_answer: user_answer,
      correct: correct,
      quiz_mode: "choice"
    )

    if correct
      redirect_to quiz_choice_path(category: params[:category], difficulty: params[:difficulty]),
                  notice: "答對了！ #{@vocabulary.english} = #{@vocabulary.chinese}"
    else
      redirect_to quiz_choice_path(category: params[:category], difficulty: params[:difficulty]),
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

  private

  def generate_options(vocabulary)
    wrong_options = []

    # 1) 同分類的其他單字
    same_category = Vocabulary
      .where(category: vocabulary.category)
      .where.not(id: vocabulary.id)
      .order("RAND()")
      .limit(3)
      .pluck(:chinese)
    wrong_options.concat(same_category)

    # 2) 不夠的話，從同難度補
    if wrong_options.size < 3
      same_difficulty = Vocabulary
        .where(difficulty: vocabulary.difficulty)
        .where.not(id: vocabulary.id)
        .where.not(chinese: wrong_options + [vocabulary.chinese])
        .order("RAND()")
        .limit(3 - wrong_options.size)
        .pluck(:chinese)
      wrong_options.concat(same_difficulty)
    end

    # 3) 還不夠就從全部補
    if wrong_options.size < 3
      fallback = Vocabulary
        .where.not(id: vocabulary.id)
        .where.not(chinese: wrong_options + [vocabulary.chinese])
        .order("RAND()")
        .limit(3 - wrong_options.size)
        .pluck(:chinese)
      wrong_options.concat(fallback)
    end

    (wrong_options.first(3) + [vocabulary.chinese]).shuffle
  end
end
