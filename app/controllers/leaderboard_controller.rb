class LeaderboardController < ApplicationController
  def index
    @rankings = User
      .joins(:quiz_records)
      .group("users.id")
      .select(
        "users.id",
        "users.username",
        "COUNT(quiz_records.id) AS total_count",
        "SUM(CASE WHEN quiz_records.correct = true THEN 1 ELSE 0 END) AS correct_count",
        "SUM(CASE WHEN quiz_records.correct = true THEN 10 ELSE 2 END) AS points"
      )
      .order("points DESC")
      .limit(5)
  end
end
