# 「ファンがスカウトマンになれる」スポーツビジネスサービス アーキテクチャ設計

## 1. システムアーキテクチャ概要

### 1.1 全体構成
本アプリケーションは、iOS用のネイティブアプリケーションとして開発し、バックエンドサーバーと連携する構成とします。

```
[iOS アプリケーション] ⟷ [API Gateway] ⟷ [バックエンドサーバー] ⟷ [データベース]
```

### 1.2 アーキテクチャパターン
iOS アプリケーションには MVVM (Model-View-ViewModel) アーキテクチャパターンを採用します。

- **Model**: データとビジネスロジックを担当
- **View**: ユーザーインターフェースを担当
- **ViewModel**: ModelとViewの間の仲介役として、Viewに表示するためのデータを準備

### 1.3 技術スタック

#### iOS アプリケーション
- **言語**: Swift 5.5+
- **最小対応 iOS バージョン**: iOS 15.0
- **開発環境**: Xcode 13.0+
- **UI フレームワーク**: UIKit + SwiftUI (ハイブリッド)
- **非同期処理**: Combine フレームワーク
- **ローカルデータベース**: Core Data
- **ネットワーク**: URLSession + Combine

#### バックエンド (参考)
- **言語**: Node.js / TypeScript
- **フレームワーク**: Express.js
- **データベース**: MongoDB
- **認証**: JWT (JSON Web Tokens)
- **API**: RESTful API

## 2. モジュール構成

### 2.1 アプリケーションモジュール

```
ScoutingApp/
├── Application/ (アプリケーション全体の設定)
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── AppConfiguration.swift
├── Presentation/ (UI関連)
│   ├── Common/ (共通UI要素)
│   ├── Authentication/ (認証画面)
│   ├── Home/ (ホーム画面)
│   ├── Schedule/ (試合スケジュール)
│   ├── Scouting/ (スカウティングレポート)
│   ├── Profile/ (プロフィール)
│   └── Rewards/ (報酬システム)
├── Domain/ (ビジネスロジック)
│   ├── Entities/ (データモデル)
│   ├── UseCases/ (ユースケース)
│   └── Repositories/ (リポジトリインターフェース)
├── Data/ (データアクセス)
│   ├── Network/ (APIクライアント)
│   ├── Local/ (ローカルストレージ)
│   └── Repositories/ (リポジトリ実装)
└── Core/ (共通ユーティリティ)
    ├── Extensions/
    ├── Helpers/
    └── Constants/
```

### 2.2 主要モジュールの責務

#### 2.2.1 Presentation層
- ユーザーインターフェースの表示
- ユーザー入力の処理
- ViewModelを通じたDomain層との連携

#### 2.2.2 Domain層
- ビジネスロジックの実装
- データモデルの定義
- ユースケースの実装

#### 2.2.3 Data層
- APIとの通信処理
- ローカルデータの永続化
- リポジトリパターンによるデータアクセスの抽象化

## 3. データモデル設計

### 3.1 主要エンティティ

#### 3.1.1 User (ユーザー)
```swift
struct User {
    let id: String
    let username: String
    let email: String
    let userType: UserType // ファン or クラブ
    let favoriteClubs: [String] // 応援するクラブのID
    let region: String // 活動地域
    let profileImage: URL?
    let createdAt: Date
    let updatedAt: Date
}

enum UserType {
    case fan
    case club
}
```

#### 3.1.2 Club (クラブ)
```swift
struct Club {
    let id: String
    let name: String
    let logo: URL
    let description: String
    let scoutingPhilosophy: String // スカウティング理念
    let category: ClubCategory // J1, J2, J3, JFL, 大学など
    let region: String
    let createdAt: Date
    let updatedAt: Date
}

enum ClubCategory {
    case j1
    case j2
    case j3
    case jfl
    case university
    case other
}
```

#### 3.1.3 Match (試合)
```swift
struct Match {
    let id: String
    let homeTeam: Team
    let awayTeam: Team
    let date: Date
    let venue: Venue
    let category: MatchCategory // リーグ戦、カップ戦など
    let interestedClubs: [String] // この試合に注目しているクラブのID
    let notablePlayers: [Player] // 注目選手
    let createdAt: Date
    let updatedAt: Date
}

struct Team {
    let id: String
    let name: String
    let logo: URL
    let category: ClubCategory
}

struct Venue {
    let id: String
    let name: String
    let address: String
    let location: CLLocationCoordinate2D
}

enum MatchCategory {
    case league
    case cup
    case friendly
    case other
}
```

#### 3.1.4 ScoutingReport (スカウティングレポート)
```swift
struct ScoutingReport {
    let id: String
    let match: Match
    let author: User
    let targetClub: String // レポートの公開先クラブID
    let targetPlayer: Player
    let templateId: String // 使用したテンプレートID
    let evaluations: [Evaluation] // 評価項目
    let generalComment: String
    let mediaAttachments: [MediaAttachment] // 写真・動画
    let status: ReportStatus
    let likes: Int // クラブからのいいね数
    let clubFeedback: String? // クラブからのフィードバック
    let createdAt: Date
    let updatedAt: Date
}

struct Evaluation {
    let criteriaId: String
    let criteriaName: String
    let rating: Int // 1-5の評価
    let comment: String
}

struct MediaAttachment {
    let id: String
    let type: MediaType
    let url: URL
    let thumbnail: URL?
    let caption: String?
}

enum MediaType {
    case image
    case video
}

enum ReportStatus {
    case draft
    case submitted
    case reviewed
}
```

#### 3.1.5 ReportTemplate (レポートテンプレート)
```swift
struct ReportTemplate {
    let id: String
    let club: Club
    let name: String
    let description: String
    let criteria: [EvaluationCriteria]
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
}

struct EvaluationCriteria {
    let id: String
    let name: String
    let description: String
    let isRequired: Bool
    let ratingType: RatingType
}

enum RatingType {
    case fivePoint
    case tenPoint
    case yesNo
    case text
}
```

#### 3.1.6 Player (選手)
```swift
struct Player {
    let id: String
    let name: String
    let dateOfBirth: Date?
    let position: Position
    let currentTeam: Team?
    let height: Double?
    let weight: Double?
    let dominantFoot: Foot?
    let profileImage: URL?
}

enum Position {
    case goalkeeper
    case defender
    case midfielder
    case forward
    case unknown
}

enum Foot {
    case right
    case left
    case both
    case unknown
}
```

#### 3.1.7 Reward (報酬)
```swift
struct Reward {
    let id: String
    let user: User
    let points: Int
    let type: RewardType
    let sourceId: String? // レポートIDなど、ポイント発生源
    let description: String
    let createdAt: Date
}

enum RewardType {
    case reportSubmission
    case reportLike
    case continuousActivity
    case special
}
```

### 3.2 リレーションシップ
- User - Club: 多対多 (ファンは複数のクラブを応援可能)
- Club - Match: 多対多 (クラブは複数の試合に注目可能)
- User - ScoutingReport: 1対多 (ユーザーは複数のレポートを作成可能)
- Club - ReportTemplate: 1対多 (クラブは複数のテンプレートを作成可能)
- Match - ScoutingReport: 1対多 (1試合に対して複数のレポートが作成される)
- User - Reward: 1対多 (ユーザーは複数の報酬を獲得可能)

## 4. APIインターフェース設計

### 4.1 認証API
- `POST /api/auth/register` - ユーザー登録
- `POST /api/auth/login` - ログイン
- `POST /api/auth/refresh` - トークンリフレッシュ
- `GET /api/auth/me` - 現在のユーザー情報取得

### 4.2 ユーザーAPI
- `GET /api/users/:id` - ユーザー情報取得
- `PUT /api/users/:id` - ユーザー情報更新
- `GET /api/users/:id/reports` - ユーザーのレポート一覧取得
- `GET /api/users/:id/rewards` - ユーザーの報酬履歴取得

### 4.3 クラブAPI
- `GET /api/clubs` - クラブ一覧取得
- `GET /api/clubs/:id` - クラブ詳細取得
- `GET /api/clubs/:id/templates` - クラブのテンプレート一覧取得
- `GET /api/clubs/:id/matches` - クラブが注目する試合一覧取得

### 4.4 試合API
- `GET /api/matches` - 試合一覧取得
- `GET /api/matches/:id` - 試合詳細取得
- `GET /api/matches/upcoming` - 今後の試合一覧取得
- `GET /api/matches/by-region/:region` - 地域別試合一覧取得

### 4.5 レポートAPI
- `POST /api/reports` - レポート作成
- `GET /api/reports/:id` - レポート詳細取得
- `PUT /api/reports/:id` - レポート更新
- `POST /api/reports/:id/submit` - レポート提出
- `POST /api/reports/:id/like` - レポートにいいねを付ける
- `POST /api/reports/:id/feedback` - レポートにフィードバックを追加

### 4.6 テンプレートAPI
- `GET /api/templates/:id` - テンプレート詳細取得
- `POST /api/templates` - テンプレート作成 (クラブのみ)
- `PUT /api/templates/:id` - テンプレート更新 (クラブのみ)

### 4.7 報酬API
- `GET /api/rewards` - 報酬履歴取得
- `POST /api/rewards/redeem` - ポイント交換申請

## 5. セキュリティ設計

### 5.1 認証・認可
- JWT (JSON Web Token) による認証
- ロールベースのアクセス制御 (ファン/クラブ)
- セッション管理とトークンリフレッシュ

### 5.2 データ保護
- HTTPS通信の強制
- センシティブデータの暗号化
- 入力値のバリデーション

### 5.3 プライバシー保護
- ユーザーデータのアクセス制限
- レポートの公開範囲制御
- データ削除リクエストへの対応

## 6. オフライン機能設計

### 6.1 データキャッシュ
- Core Dataを使用したローカルデータベース
- 試合スケジュールのオフラインキャッシュ
- レポートのオフライン作成・保存

### 6.2 同期メカニズム
- バックグラウンド同期
- 競合解決戦略
- 同期状態の表示

## 7. パフォーマンス最適化

### 7.1 画像・動画最適化
- 画像の圧縮とキャッシュ
- 動画のストリーミング対応
- 遅延読み込み (Lazy Loading)

### 7.2 ネットワーク最適化
- バッチリクエスト
- データの増分更新
- 接続状態に応じた動作調整

## 8. スケーラビリティ設計

### 8.1 将来の拡張性
- 他スポーツへの対応
- 国際化対応
- 新機能追加の容易性

### 8.2 コードの拡張性
- モジュール化されたアーキテクチャ
- 依存性注入パターンの採用
- インターフェースによる抽象化
