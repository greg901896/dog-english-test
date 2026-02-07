FactoryBot.define do
  factory :quiz_record do
    user
    vocabulary
    user_answer { "測試答案" }
    correct { false }
    quiz_mode { "input" }
  end
end
