# MeetingPointFinder

複数人の合流地点を最適に見つけるiOSアプリです。

## 概要

複数の出発地点と交通手段（電車・車）を入力すると、全員にとって最適な合流駅を提案します。

### 主な機能

- **複数人対応**: 2人以上のメンバーの出発地点を設定
- **交通手段選択**: メンバーごとに電車または車を選択
- **最適駅ランキング**: 合計移動時間または最大移動時間でソート
- **地図表示**: 候補駅と各メンバーの出発地点を地図上に表示
- **検索履歴**: 過去の検索結果をSwiftDataで保存

## 技術スタック

- **UI**: SwiftUI
- **最小iOS**: iOS 17.0+
- **地図**: MapKit, MKDirections
- **データ永続化**: SwiftData
- **位置情報**: CoreLocation
- **言語**: Swift 5.9+

## セットアップ

1. Xcodeでプロジェクトを開く
2. [駅データ.jp](https://ekidata.jp/) から全駅データCSVをダウンロード
3. `MeetingPointFinder/Resources/stations_sample.csv` を差し替え
4. ビルド＆実行

詳細は [SETUP.md](SETUP.md) を参照してください。

## アーキテクチャ

```
MeetingPointFinder/
├── Models/          # SwiftDataモデル、データ構造体
├── Views/           # SwiftUIビュー
├── ViewModels/      # ビューモデル（@Observable）
├── Services/        # 駅データ、ルート計算サービス
├── Utilities/       # ユーティリティ関数
└── Resources/       # CSVデータ、アセット
```

## ライセンス

MIT License
