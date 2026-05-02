# Admin 單字管理後台

## 目標

讓管理員可以透過後台介面新增、更新、瀏覽與管理單字資料。

## 解決問題

目前單字資料主要依賴 seed data 或直接修改資料庫。新增後台 UI 後，單字庫會更容易維護。

## 功能範圍

- 新增只有管理員可以進入的權限控制。
- 新增單字列表、詳細頁、新增、編輯與更新流程。
- 支援依照分類與難度搜尋、篩選。
- 只有管理員可以看到後台導覽連結。

## 暫不包含

- 使用者管理。
- CSV 匯入與匯出。
- 批次編輯。
- 完整的管理員分析 Dashboard。

## 可能路由

- `GET /admin`
- `GET /admin/vocabularies`
- `GET /admin/vocabularies/new`
- `POST /admin/vocabularies`
- `GET /admin/vocabularies/:id`
- `GET /admin/vocabularies/:id/edit`
- `PATCH /admin/vocabularies/:id`

## 可能資料變更

- 在 `users` 新增 `admin:boolean`。
- 可考慮在 `vocabularies` 新增 `active:boolean`，讓單字可以被停用，而不是直接刪除。

## 實作步驟

1. 新增 admin 權限資料。
2. 新增 `Admin::BaseController`。
3. 新增 `Admin::VocabulariesController`。
4. 新增 Admin 單字管理 views。
5. 新增只有 admin 可以看到的 navbar 連結。
6. 新增權限控制與 CRUD 的 request/system tests。

## UX 備註

- 表單在桌機與手機版都應該容易使用。
- 分類應使用一致的固定值，避免自由輸入造成資料不一致。
- 刪除單字可能影響歷史答題紀錄，因此停用資料通常比硬刪除更安全。
