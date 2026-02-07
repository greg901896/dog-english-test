FactoryBot.define do
  factory :vocabulary do
    sequence(:english) { |n| "word#{n}" }
    chinese { "中文翻譯" }
    category { "general" }
    difficulty { 1 }
  end
end
