class Admin::VocabulariesController < Admin::BaseController
  before_action :set_vocabulary, only: [:show, :edit, :update, :destroy]

  def index
    @total_count = Vocabulary.count
    @active_count = Vocabulary.active.count
    @inactive_count = Vocabulary.where(active: false).count
    @categories = Vocabulary.where.not(category: [nil, ""]).distinct.order(:category).pluck(:category)
    @vocabularies = filtered_vocabularies
  end

  def show
  end

  def new
    @vocabulary = Vocabulary.new(active: true, difficulty: 1)
  end

  def create
    @vocabulary = Vocabulary.new(vocabulary_params)

    if @vocabulary.save
      redirect_to admin_vocabulary_path(@vocabulary), notice: "單字已新增"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @vocabulary.update(vocabulary_params)
      redirect_to admin_vocabulary_path(@vocabulary), notice: "單字已更新"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @vocabulary.update!(active: false)
    redirect_to admin_vocabularies_path, notice: "單字已停用"
  end

  private

  def set_vocabulary
    @vocabulary = Vocabulary.find(params[:id])
  end

  def vocabulary_params
    params.require(:vocabulary).permit(:english, :chinese, :category, :difficulty, :active)
  end

  def filtered_vocabularies
    scope = Vocabulary.order(updated_at: :desc, english: :asc)

    if params[:query].present?
      query = "%#{ActiveRecord::Base.sanitize_sql_like(params[:query].strip)}%"
      scope = scope.where("english LIKE :query OR chinese LIKE :query", query: query)
    end

    scope = scope.where(category: params[:category]) if params[:category].present?
    scope = scope.where(difficulty: params[:difficulty]) if params[:difficulty].present?
    scope = scope.where(active: params[:active]) if params[:active].in?(["true", "false"])

    scope
  end
end
