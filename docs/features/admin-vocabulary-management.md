# Admin 單字管理後台

## 目標

讓管理員可以透過後台介面新增、更新、瀏覽與管理單字資料。

## 版本範圍

Admin v1 只做 Vocabulary 管理。

第一版先把「單字庫維護」做穩，不處理使用者管理、批次匯入、後台統計或複雜角色權限。這樣可以讓開發範圍保持清楚，也避免後台一次長太大。

## 解決問題

目前單字資料主要依賴 seed data 或直接修改資料庫。新增後台 UI 後，單字庫會更容易維護。

## 功能範圍

- 新增只有管理員可以進入的權限控制。
- 新增單字列表、詳細頁、新增、編輯、更新與停用流程。
- 支援依照英文、中文、分類、難度與啟用狀態搜尋、篩選。
- 只有管理員可以看到後台導覽連結。
- 停用單字後，前台測驗不應再抽到該單字。

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
- `DELETE /admin/vocabularies/:id`

`DELETE` 第一版不做硬刪除，而是把單字標記為停用。

## 可能資料變更

- 在 `users` 新增 `admin:boolean, default: false, null: false`。
- 在 `vocabularies` 新增 `active:boolean, default: true, null: false`。

## 權限規則

- 未登入使用者不能進入 `/admin`。
- 已登入但不是 admin 的使用者不能進入 `/admin`。
- 只有 `current_user.admin?` 為 true 的使用者可以進入後台。
- 後台 controller 應繼承 `Admin::BaseController`，集中處理登入與 admin 權限檢查。

## 資料管理規則

- `english` 不可空白，且應維持唯一。
- `chinese` 不可空白。
- `category` 不使用硬性白名單，避免既有資料因分類不在清單內而無法編輯。
- Admin 表單應提供既有分類與建議分類作為輸入提示。
- 管理員可以輸入新分類，但應盡量沿用既有分類命名，避免產生過多相似分類。
- `difficulty` 應限制在 1、2、3。
- 停用單字使用 `active: false`，不要直接刪除資料。
- 前台測驗抽題時應只抽 `active: true` 的單字。

## 頁面設計

### 單字列表

- 顯示英文、中文、分類、難度、狀態、更新時間與操作按鈕。
- 提供新增單字按鈕。
- 提供搜尋英文與中文的輸入框。
- 提供分類、難度、啟用狀態篩選。
- 操作包含查看、編輯、停用。

### 新增與編輯表單

- 欄位包含英文、中文、分類、難度與啟用狀態。
- 表單錯誤訊息要清楚顯示。
- 送出後應回到列表或詳細頁，並顯示 flash 訊息。

## 實作步驟

1. 新增 admin 權限資料。
2. 新增 vocabulary 啟用狀態資料。
3. 新增 `Admin::BaseController`。
4. 新增 `Admin::VocabulariesController`。
5. 新增 Admin 單字管理 views。
6. 新增只有 admin 可以看到的 navbar 連結。
7. 讓前台測驗只抽啟用中的單字。
8. 新增權限控制與 CRUD 的 request/system tests。

## 驗證清單

- 未登入使用者進入 `/admin` 會被導向登入頁。
- 一般使用者進入 `/admin` 會被拒絕並導回前台。
- admin 使用者可以進入 `/admin/vocabularies`。
- admin 可以新增單字。
- admin 可以編輯單字。
- admin 可以停用單字。
- 停用單字不會再出現在前台測驗。
- 非 admin 看不到 navbar 的後台入口。
- 表單與列表在手機版和桌機版都能正常使用。

## UX 備註

- 表單在桌機與手機版都應該容易使用。
- 桌機版列表可以使用 table，方便快速掃描資料。
- 手機版不要硬塞寬表格，應使用 card list 或 responsive table。
- 分類欄位可自由輸入，但表單應透過 datalist 提供既有分類與建議分類，降低命名不一致。
- 刪除單字可能影響歷史答題紀錄，因此停用資料通常比硬刪除更安全。
