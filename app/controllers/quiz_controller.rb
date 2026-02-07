class QuizController < ApplicationController
  def index
    @categories = Vocabulary.distinct.pluck(:category)
    scope = Vocabulary.by_category(params[:category]).by_difficulty(params[:difficulty])
    @vocabulary = scope.order("RAND()").first

    if @vocabulary
      @favorited = current_user.favorites.exists?(vocabulary: @vocabulary)
    elsif params[:category].present? || params[:difficulty].present?
      redirect_to quiz_path, alert: "目前沒有符合條件的單字"
    else
      redirect_to dashboard_path, alert: "還沒有單字資料，請先匯入"
    end
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
      if params[:category].present? || params[:difficulty].present?
        redirect_to quiz_choice_path, alert: "目前沒有符合條件的單字"
      else
        redirect_to dashboard_path, alert: "還沒有單字資料，請先匯入"
      end
      return
    end

    @favorited = current_user.favorites.exists?(vocabulary: @vocabulary)
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
    @mistakes = Vocabulary
      .where(id: unmastered_vocab_ids)
      .left_joins(:quiz_records)
      .where(quiz_records: { correct: false, user_id: current_user.id })
      .group("vocabularies.id")
      .select("vocabularies.*, COUNT(quiz_records.id) AS wrong_count")
      .order("wrong_count DESC")
  end

  def retry_mistakes
    @vocabulary = Vocabulary.where(id: unmastered_vocab_ids).order("RAND()").first
    @categories = Vocabulary.distinct.pluck(:category)

    if @vocabulary.nil?
      redirect_to quiz_mistakes_path, notice: "沒有答錯的單字，太厲害了！"
    else
      @favorited = current_user.favorites.exists?(vocabulary: @vocabulary)
      @options = generate_options(@vocabulary)
      render :retry_quiz
    end
  end

  def retry_answer
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
      redirect_to quiz_retry_path,
                  notice: "答對了！「#{@vocabulary.english}」已從錯誤清單移除"
    else
      redirect_to quiz_retry_path,
                  alert: "答錯了！ #{@vocabulary.english} 的正確答案是「#{@vocabulary.chinese}」"
    end
  end

  private

  # 答錯過但之後沒有答對過的單字
  def unmastered_vocab_ids
    wrong_ids = current_user.quiz_records.where(correct: false).select(:vocabulary_id).distinct
    mastered_ids = current_user.quiz_records.where(correct: true).select(:vocabulary_id).distinct
    Vocabulary.where(id: wrong_ids).where.not(id: mastered_ids).pluck(:id)
  end

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
