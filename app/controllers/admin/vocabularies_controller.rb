class Admin::VocabulariesController < Admin::BaseController
  def index
    @total_count = Vocabulary.count
    @active_count = Vocabulary.active.count
    @inactive_count = Vocabulary.where(active: false).count
  end
end
