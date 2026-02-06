class DashboardController < ApplicationController
  def index
    records = current_user.quiz_records

    @total_count = records.count
    @correct_count = records.where(correct: true).count
    @wrong_count = @total_count - @correct_count
    @accuracy = @total_count > 0 ? (@correct_count.to_f / @total_count * 100).round(1) : 0

    @category_stats = records
      .joins(:vocabulary)
      .group("vocabularies.category")
      .select(
        "vocabularies.category",
        "COUNT(*) AS total",
        "SUM(CASE WHEN quiz_records.correct = true THEN 1 ELSE 0 END) AS correct_total"
      )

    @mode_stats = records
      .group(:quiz_mode)
      .select(
        "quiz_records.quiz_mode",
        "COUNT(*) AS total",
        "SUM(CASE WHEN quiz_records.correct = true THEN 1 ELSE 0 END) AS correct_total"
      )

    @daily_stats = records
      .where("quiz_records.created_at >= ?", 7.days.ago.beginning_of_day)
      .group("DATE(quiz_records.created_at)")
      .select(
        "DATE(quiz_records.created_at) AS quiz_date",
        "COUNT(*) AS total",
        "SUM(CASE WHEN quiz_records.correct = true THEN 1 ELSE 0 END) AS correct_total"
      )
      .order("quiz_date")
  end
end
