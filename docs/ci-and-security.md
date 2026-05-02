# CI 與安全掃描筆記

## CI 檢查項目

目前 GitHub Actions CI 主要包含：

- `scan_ruby`：Ruby / Rails 安全掃描
  - `bundle exec brakeman --no-pager --confidence-level 2 --no-exit-on-warn`
  - `bin/bundler-audit`
- `scan_js`：Importmap JavaScript 套件安全掃描
  - `bin/importmap audit`
- `test`：RSpec 測試
  - `bin/rails db:test:prepare && bundle exec rspec`

## Bundler Audit 注意事項

`bin/bundler-audit` 會比對 `Gemfile.lock` 裡鎖定的 gem 版本與 `ruby-advisory-db`
漏洞資料庫。

因此，即使沒有修改 `Gemfile` 或 `Gemfile.lock`，CI 仍可能因為漏洞資料庫更新而突然失敗。
這通常代表「新的漏洞紀錄被公開或收錄」，不一定代表最新 commit 引入了程式錯誤。

## Low Vulnerability 處理原則

Low vulnerability 可以短期接受，但不應該無條件永久忽略。

可以暫時 ignore 的情況：

- 官方嚴重度為 Low
- 專案目前沒有使用到相關功能
- 已在 `config/bundler-audit.yml` 留下忽略原因
- 後續會定期重新檢查

不建議直接 ignore 的情況：

- Medium / High / Critical vulnerability
- 不確定專案是否使用到受影響功能
- 修補方式只是安全 patch 版升級，且升級成本低

## 定期手動檢查指令

建議每 2 到 4 週手動跑一次：

```bash
bin/bundler-audit update
bin/bundler-audit
bin/importmap audit
bundle exec brakeman --no-pager --confidence-level 2
```

如果 `bin/bundler-audit` 發現新的 vulnerability，先判斷：

- 是否有使用到受影響功能
- 官方嚴重度是 Low、Medium、High 或 Critical
- 是否可以用 patch 版升級解決
- 是否需要暫時加入 `config/bundler-audit.yml` 的 ignore 清單

## 目前忽略的 Advisory

目前 `config/bundler-audit.yml` 忽略以下 Low vulnerability：

- `GHSA-53p3-c7vp-4mcc`
  - 原因：專案目前沒有使用 Trix editor 或 Action Text rich text input
- `CVE-2026-33658`
  - 原因：專案目前沒有使用 Active Storage proxy mode 對外服務檔案

如果未來新增以下功能，需要重新評估並優先改成升級 gem：

- Trix editor
- Action Text
- 使用者檔案上傳
- Active Storage proxy mode
