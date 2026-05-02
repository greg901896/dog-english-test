# 專案架構

這份文件說明目前 Rails App 的組織方式，以及主要產品流程如何運作。

## 專案概述

IT English Vocabulary Quiz 是一個 Rails 學習平台，用來練習技術文件中常見的英文詞彙。

目前 App 的核心包含使用者登入、單字測驗、錯題複習、收藏單字、Dashboard 統計，以及類似排行榜的學習進度。

## 核心 Models

- `User`：使用 Devise 管理的帳號 model。
- `Vocabulary`：儲存英文單字、中文翻譯、分類與難度。
- `QuizRecord`：儲存每位使用者的答題紀錄。
- `Favorite`：儲存使用者收藏的單字。

## 主要流程

- 使用者透過 Devise 登入。
- 使用者進行單字測驗。
- 每次作答都會建立一筆 `QuizRecord`。
- 答錯的單字可以在錯題複習流程中再次練習。
- 使用者可以收藏單字，方便之後複習。
- Dashboard 會整理答題紀錄與答對率。

## 技術重點

- 認證：Devise。
- 前端：Hotwire、Turbo、Stimulus、Importmap、Propshaft。
- 資料庫：透過 `mysql2` 使用 MySQL。
- 樣式：Rails app stylesheets。

## 未來架構備註

- Admin 功能應該放在 `Admin::` namespace 底下。
- 只有 Admin 可以使用的 controllers 應該繼承 `Admin::BaseController`。
- 長期的間隔複習排程可能需要獨立的 review model，而不是只依賴 `QuizRecord`。
