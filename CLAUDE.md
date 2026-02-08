# IT English Vocabulary Quiz - 專案規格書

## 開發規則

- 在改寫 code 之前先跟我說會改動到什麼地方，如果有回答確認才開始實作程式碼
- 實作時有動到 view 都要考量到手機格式跟電腦畫面格式是否合理

## 專案概述

一個用 Rails 打造的 IT 英文詞彙學習平台，幫助使用者提升閱讀 IT 技術文件（如 Ruby on Rails Guides）的英文能力。
系統提供英翻中的測驗模式，並記錄使用者答錯的單字，方便日後複習。

## 技術環境

- Ruby: 3.2.4
- Rails: 8.1.2
- Database: MySQL (mysql2)
- Frontend: Hotwire (Turbo + Stimulus) + Importmap + Propshaft
- 認證: Devise

## 資料庫設計

### users（由 Devise 產生）

| 欄位 | 型別 | 說明 |
|------|------|------|
| email | string | 使用者信箱（登入帳號） |
| encrypted_password | string | 加密密碼 |
| 其他 Devise 預設欄位 | - | reset_password_token 等 |

### vocabularies（單字庫）

| 欄位 | 型別 | 說明 |
|------|------|------|
| id | bigint | 主鍵 |
| english | string | 英文單字，not null，唯一索引 |
| chinese | string | 中文翻譯，not null |
| category | string | 分類（例如：rails、general、database、frontend、backend、devops） |
| difficulty | integer | 難度等級（1: 簡單, 2: 中等, 3: 困難），預設 1 |
| created_at | datetime | |
| updated_at | datetime | |

### quiz_records（答題紀錄）

| 欄位 | 型別 | 說明 |
|------|------|------|
| id | bigint | 主鍵 |
| user_id | bigint | 外鍵，關聯 users |
| vocabulary_id | bigint | 外鍵，關聯 vocabularies |
| user_answer | string | 使用者輸入或選擇的答案 |
| correct | boolean | 是否答對 |
| quiz_mode | string | 測驗模式："input"（輸入題）或 "choice"（選擇題），預設 "input" |
| created_at | datetime | |

### favorites（收藏單字）

| 欄位 | 型別 | 說明 |
|------|------|------|
| id | bigint | 主鍵 |
| user_id | bigint | 外鍵，關聯 users，not null |
| vocabulary_id | bigint | 外鍵，關聯 vocabularies，not null |
| created_at | datetime | |

- 聯合唯一索引：`[user_id, vocabulary_id]`（同一使用者不能重複收藏同一單字）

## Model 關聯

```
User
  has_many :quiz_records
  has_many :favorites
  has_many :favorite_vocabularies, through: :favorites, source: :vocabulary

Vocabulary
  has_many :quiz_records
  has_many :favorites

Favorite
  belongs_to :user
  belongs_to :vocabulary

QuizRecord
  belongs_to :user
  belongs_to :vocabulary
```

## 功能規劃

### 1. 使用者認證（Devise）

- 註冊 / 登入 / 登出
- 未登入時導向登入頁面
- 所有功能頁面皆需登入才能存取

### 2. 單字測驗頁面（主要功能）

- 路徑：`GET /quiz`
- 畫面顯示一個英文單字
- 使用者在輸入框中填寫中文翻譯後送出
- 答對：顯示成功通知（flash notice），自動載入下一題
- 答錯：顯示錯誤通知（flash alert），同時顯示正確答案，讓使用者可以繼續下一題
- 每次作答都會建立一筆 quiz_record
- 可透過篩選條件選擇分類（category）或難度（difficulty）

### 3. 選擇題測驗頁面（新功能）

- 路徑：`GET /quiz/choice`
- 畫面顯示一個英文單字 + 四個中文選項（單選）
- 四個選項 = 1 個正確答案 + 3 個誘導選項
- 誘導選項的產生邏輯（優先順序）：
  1. 優先從**同分類（category）**的單字中隨機抽取中文翻譯作為錯誤選項
  2. 同分類不足 3 個時，從**同難度（difficulty）**的其他分類單字補充
  3. 仍不足時，從全部單字庫隨機補充
- 四個選項順序隨機打亂
- 答對：顯示成功通知（flash notice），自動載入下一題
- 答錯：顯示錯誤通知（flash alert），同時顯示正確答案
- 每次作答建立一筆 quiz_record，quiz_mode 記為 "choice"
- 同樣支援分類（category）和難度（difficulty）篩選
- 導覽列新增「選擇題」連結

### 4. 錯誤單字複習頁面

- 路徑：`GET /quiz/mistakes`
- 列出該使用者所有答錯過的單字（去重複）
- 顯示：英文單字、正確中文翻譯、答錯次數、測驗模式（輸入/選擇）
- 可以點擊「重新測驗」針對錯誤單字再次練習

### 5. 收藏單字功能

- 在輸入題（`/quiz`）、選擇題（`/quiz/choice`）、錯題重測（`/quiz/retry`）的單字旁邊顯示一個星號按鈕
- 未收藏狀態：空心星號 `☆`，點擊後收藏該單字（新增一筆 favorite）
- 已收藏狀態：實心星號 `★`，點擊後取消收藏（刪除該筆 favorite）
- 使用 Turbo Frame 讓收藏/取消收藏不需整頁刷新

### 6. 收藏單字列表頁面

- 路徑：`GET /favorites`
- 列出該使用者所有收藏的單字
- 顯示：英文單字、中文翻譯、分類、收藏時間
- 每筆收藏旁有「移除收藏」按鈕，點擊後從列表移除
- 導覽列新增「收藏」連結

### 7. 答題統計頁面

- 路徑：`GET /dashboard`
- 顯示該使用者的答題統計資料：
  - 總答題數
  - 答對數 / 答錯數
  - 答對率（百分比）
  - 各分類的答對率
  - 各模式（輸入題/選擇題）的答對率
  - 最近 7 天的答題趨勢（每日答題數與答對率）

### 6. 種子資料（db/seeds.rb）

- 預先匯入 IT 相關英文詞彙，至少包含以下分類各 20 個以上單字：
  - `rails`：如 scaffold, migration, routing, controller, model, view, partial, helper, concern, callback, validation, association, scope, turbo, stimulus, devise, middleware, asset, deployment, mailer
  - `general`：如 implement, deprecated, initialize, configure, parameter, instance, variable, method, function, argument, syntax, compile, execute, debug, refactor, iterate, deploy, repository, dependency, environment
  - `database`：如 schema, query, index, migration, transaction, constraint, normalize, aggregate, join, primary key, foreign key, seed, rollback, column, table, record, association, relation, persistence, throughput
  - `frontend`：如 component, render, responsive, layout, stylesheet, viewport, accessibility, animation, framework, DOM, event, listener, selector, template, binding, reactive, hydration, bundle, minify, transpile
  - `backend`：如 endpoint, middleware, authentication, authorization, session, token, cache, queue, webhook, serializer, API, request, response, header, payload, encryption, hashing, throughput, latency, microservice
  - `devops`：如 container, orchestration, pipeline, deployment, monitoring, scaling, load balancer, registry, volume, cluster, namespace, ingress, rollout, artifact, provisioning, infrastructure, logging, alerting, uptime, failover

## 頁面路由規劃

```ruby
# config/routes.rb
devise_for :users

authenticated :user do
  root "quiz#index", as: :authenticated_root
end
root "devise/sessions#new"

get "quiz",            to: "quiz#index"
post "quiz/answer",    to: "quiz#answer"
get "quiz/choice",     to: "quiz#choice"
post "quiz/choice_answer", to: "quiz#choice_answer"
get "quiz/mistakes",   to: "quiz#mistakes"
post "quiz/retry",     to: "quiz#retry"

post "favorites/:vocabulary_id", to: "favorites#create",  as: :favorites
delete "favorites/:vocabulary_id", to: "favorites#destroy", as: :favorite
get "favorites",       to: "favorites#index"

get "dashboard",       to: "dashboard#index"
```

## 實作順序

1. ~~安裝 Devise，設定 User model 與登入/註冊功能~~ (已完成)
2. ~~建立 Vocabulary model 與 migration~~ (已完成)
3. ~~建立 QuizRecord model 與 migration~~ (已完成)
4. ~~撰寫 seeds.rb，匯入 IT 詞彙種子資料~~ (已完成)
5. ~~實作 QuizController（輸入題測驗、作答、錯誤單字複習）~~ (已完成)
6. ~~實作 DashboardController（答題統計）~~ (已完成)
7. ~~製作前端頁面~~ (已完成)
8. ~~加上基本的 CSS 樣式~~ (已完成)
9. 對 quiz_records 新增 quiz_mode 欄位（migration）
10. 實作選擇題功能（QuizController#choice / #choice_answer）
11. 建立選擇題 view（quiz/choice.html.erb）
12. 導覽列加上「選擇題」連結
13. ~~Dashboard 新增「各模式答對率」統計~~ (已完成)
14. 建立 Favorite model 與 migration（聯合唯一索引）
15. 實作 FavoritesController（create / destroy / index）
16. 在輸入題、選擇題、錯題重測 view 加上星號收藏按鈕（Turbo Frame）
17. 建立收藏列表頁面（favorites/index.html.erb）
18. 導覽列加上「收藏」連結
