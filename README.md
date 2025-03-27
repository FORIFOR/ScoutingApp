# FanScout - ファンがスカウトマンになれるスポーツビジネスサービス

![FanScout Logo](https://example.com/fanscout-logo.png)

## 概要

FanScoutは、サッカーファンがスカウティングレポートの作成を支援することで、クラブのスカウト負荷を削減するプラットフォームです。ファンの情熱と観察力をクラブの人材発掘に活かし、サッカー界全体の発展に貢献します。

### 主な特徴

- **ファン参加型スカウティング**: ファンが試合観戦とレポート作成でクラブをサポート
- **クラブ独自のテンプレート**: 各クラブのスカウティング理念に基づいたレポート形式
- **インセンティブシステム**: 貢献度に応じたポイント付与と報酬交換
- **オフライン対応**: スタジアムでのネットワーク環境に依存しない機能性
- **分析ダッシュボード**: 選手評価の統計分析と視覚化

## 技術スタック

- **フロントエンド**: SwiftUI, UIKit
- **バックエンド**: Firebase (Firestore, Authentication, Storage, Functions)
- **アーキテクチャ**: MVVM (Model-View-ViewModel)
- **データ同期**: Combine Framework
- **セキュリティ**: AES-GCM暗号化, Firebase Security Rules

## 必要条件

- macOS 12.0以上
- Xcode 14.0以上
- iOS 15.0以上（実行環境）
- CocoaPods 1.11.0以上
- Firebase アカウント

## インストール手順

### 開発環境のセットアップ

1. リポジトリをクローン
   ```bash
   git clone https://github.com/YourUsername/ScoutingApp.git
   cd ScoutingApp
   ```

2. CocoaPodsをインストール（未インストールの場合）
   ```bash
   sudo gem install cocoapods
   ```

3. 依存関係をインストール
   ```bash
   cd code/ScoutingApp
   pod install
   ```

4. Firebase設定
   - [Firebase Console](https://console.firebase.google.com/)で新しいプロジェクトを作成
   - iOSアプリを追加（バンドルID: com.fanscout.app）
   - `GoogleService-Info.plist`をダウンロードし、Xcodeプロジェクトに追加

5. Xcodeでワークスペースを開く
   ```bash
   open ScoutingApp.xcworkspace
   ```

## 使用方法

### アプリの実行

1. Xcodeで開発チームを設定
   - Project Navigator > ScoutingApp > Signing & Capabilities
   - Team: あなたのApple Developer Accountを選択

2. 実行デバイスを選択
   - シミュレータ: iPhone 14 Pro, iPhone 14 Pro Max など
   - 実機: USBで接続したiOSデバイス

3. ビルドと実行
   - Xcodeの実行ボタン(▶)をクリック

### テスト用アカウント

アプリを起動したら、以下のテスト用アカウントでログインできます：

- **ファンユーザー**
  - メール: fan@example.com
  - パスワード: test1234

- **クラブユーザー**
  - メール: club@example.com
  - パスワード: test1234

## プロジェクト構造

```
ScoutingApp/
├── docs/                   # プロジェクトドキュメント
│   ├── requirements.md     # 要件定義書
│   ├── architecture.md     # アーキテクチャ設計書
│   ├── user_flow.md        # ユーザーフロー図
│   └── ...
├── design/                 # デザインリソース
│   ├── wireframes.md       # ワイヤーフレーム
│   ├── design_guidelines.md # デザインガイドライン
│   └── mockups/            # モックアップデザイン
├── code/                   # ソースコード
│   └── ScoutingApp/
│       ├── Core/           # コア機能
│       │   ├── Models/     # データモデル
│       │   ├── Authentication/ # 認証機能
│       │   ├── Schedule/   # スケジュール管理
│       │   ├── Report/     # レポート機能
│       │   ├── Database/   # データベース連携
│       │   └── Security/   # セキュリティ機能
│       ├── Prototype/      # プロトタイプ
│       └── Tests/          # テストコード
└── README.md               # このファイル
```

## 主要機能

### ファンユーザー向け機能

1. **試合スケジュール管理**
   - 各クラブが注目する試合の一覧表示
   - 地域、日付、カテゴリによるフィルタリング
   - 試合詳細情報の表示

2. **スカウティングレポート作成**
   - クラブごとのテンプレートに基づくレポート作成
   - 選手評価（テクニック、フィジカル、戦術理解など）
   - 画像・動画添付機能
   - オフラインでの作成と自動同期

3. **ポイントと報酬**
   - レポート提出によるポイント獲得
   - クラブからの評価によるボーナスポイント
   - ポイントを使った報酬交換（チケット割引、グッズなど）
   - 貢献度ランキング

### クラブユーザー向け機能

1. **テンプレート管理**
   - クラブ独自のスカウティングテンプレート作成
   - 評価項目のカスタマイズ
   - 必須項目と任意項目の設定

2. **レポート管理**
   - 提出されたレポートの一覧表示と検索
   - レポート評価といいね機能
   - フィードバックコメント機能
   - 選手ごとのレポート集約

3. **分析ダッシュボード**
   - 選手評価の統計分析
   - ポジション別の人材マップ
   - ファン評価とスカウト評価の比較
   - トレンド分析

## トラブルシューティング

- **ビルドエラー**
  - Xcodeを再起動
  - プロジェクトをクリーン（Product > Clean Build Folder）
  - 依存関係を再インストール（`pod install --repo-update`）

- **実行時エラー**
  - Firebase設定が正しいか確認
  - ネットワーク接続を確認
  - コンソールログでエラーメッセージを確認

- **データ同期の問題**
  - アプリを再起動
  - ネットワーク接続を確認
  - アカウントからログアウトして再ログイン

## リリース計画

詳細なリリース計画は `docs/release_plan.md` を参照してください。主な流れは以下の通りです：

1. App Store Connectでアプリを登録
2. TestFlightでのベータテスト実施
3. フィードバック収集と改善
4. App Store審査提出
5. 正式リリースとマーケティング

## 貢献ガイドライン

プロジェクトへの貢献を歓迎します。以下の手順で貢献できます：

1. リポジトリをフォーク
2. 機能ブランチを作成（`git checkout -b feature/amazing-feature`）
3. 変更をコミット（`git commit -m 'Add some amazing feature'`）
4. ブランチにプッシュ（`git push origin feature/amazing-feature`）
5. プルリクエストを作成

## ライセンス

このプロジェクトは [MIT License](LICENSE) の下で公開されています。

## 連絡先

- プロジェクト管理者: developer@fanscout.jp
- ウェブサイト: https://fanscout.jp
- サポート: support@fanscout.jp

---

© 2025 FanScout Team. All Rights Reserved.
