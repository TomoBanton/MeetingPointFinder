# MeetingPointFinder セットアップガイド

## 前提条件

- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+の実機またはシミュレータ

## セットアップ手順

### 1. プロジェクトを開く

```bash
git clone https://github.com/TomoBanton/MeetingPointFinder.git
cd MeetingPointFinder
open MeetingPointFinder.xcodeproj
```

Xcodeでプロジェクトを開いてください。

### 2. 駅データの準備

アプリにはサンプルの駅データ（50駅）が同梱されています。
全国の駅データを使用する場合は、以下の手順でデータを差し替えてください。

1. [駅データ.jp](https://ekidata.jp/) にアクセス
2. 「駅データ」からCSVファイルをダウンロード
3. 以下の形式のCSVを準備:

```csv
station_cd,station_name,lat,lon,line_name,pref_cd
1130101,東京,35.681236,139.767125,JR山手線,13
...
```

4. `MeetingPointFinder/Resources/stations_sample.csv` を差し替え

### 3. ビルド＆実行

1. Xcodeでターゲットデバイスを選択（iPhone 15 Pro推奨）
2. `Cmd + R` でビルド＆実行
3. 初回起動時は「設定」タブから駅データをインポート

### 4. 位置情報の設定（シミュレータの場合）

シミュレータでテストする場合、GPS機能を使うには以下の設定が必要です:

- Xcodeメニュー > Features > Location > Custom Location
- 緯度・経度を入力（例: 東京駅 35.6812, 139.7671）

## プロジェクト構成

```
MeetingPointFinder/
├── MeetingPointFinderApp.swift  # エントリーポイント
├── ContentView.swift            # メインTabView
├── Models/
│   ├── Station.swift           # 駅データモデル (SwiftData)
│   ├── Member.swift            # メンバーデータモデル
│   ├── MeetingResult.swift     # 検索結果構造体
│   └── SearchHistory.swift     # 検索履歴モデル (SwiftData)
├── Views/
│   ├── HomeView.swift          # ホーム画面
│   ├── MemberSetupView.swift   # メンバー設定画面
│   ├── LocationPickerView.swift # 出発地点選択画面
│   ├── ResultsView.swift       # 検索結果画面
│   ├── ResultDetailView.swift  # 結果詳細画面
│   └── SettingsView.swift      # 設定画面
├── ViewModels/
│   ├── MeetingViewModel.swift  # 検索ロジック
│   └── LocationManager.swift   # 位置情報管理
├── Services/
│   ├── StationDataService.swift   # 駅データ管理
│   ├── RouteCalculator.swift      # ルート計算
│   └── TransitAPIService.swift    # 乗換検索API (Phase 2)
├── Utilities/
│   └── HaversineDistance.swift # Haversine距離計算
├── Resources/
│   └── stations_sample.csv    # サンプル駅データ (50駅)
└── Info.plist                  # アプリ設定
```

## 今後の拡張予定 (Phase 2)

- Google Maps Directions APIによる実際の乗換検索
- 駅データの自動アップデート
- お気に入り駅の保存機能
- 共有機能（URLスキーム）
- Widget対応
