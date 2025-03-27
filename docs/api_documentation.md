# API ドキュメント：「ファンがスカウトマンになれる」スポーツビジネスサービス

## 1. 概要

このドキュメントでは、「ファンがスカウトマンになれる」スポーツビジネスサービスのAPIインターフェースについて説明します。このAPIは、iOSアプリケーションとFirebaseバックエンド間の通信を担当します。

### 1.1 ベースURL

すべてのAPIリクエストは以下のベースURLに対して行われます：

```
https://firestore.googleapis.com/v1/projects/scouting-app/databases/(default)/documents/
```

### 1.2 認証

すべてのAPIリクエストには、Firebase認証トークンをAuthorizationヘッダーに含める必要があります：

```
Authorization: Bearer {firebase_auth_token}
```

### 1.3 リクエスト形式

リクエストボディはJSON形式で送信します。

### 1.4 レスポンス形式

レスポンスはJSON形式で返されます。標準的なレスポンス構造は以下の通りです：

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/{collection}/{document_id}",
  "fields": {
    // ドキュメントのフィールド
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T10:00:00.000000Z"
}
```

### 1.5 エラーレスポンス

エラーが発生した場合、以下の形式でレスポンスが返されます：

```json
{
  "error": {
    "code": 400,
    "message": "エラーメッセージ",
    "status": "INVALID_ARGUMENT"
  }
}
```

## 2. ユーザー管理API

### 2.1 ユーザー登録

新しいユーザーを登録します。

**エンドポイント**: `POST /users`

**リクエスト**:

```json
{
  "fields": {
    "email": { "stringValue": "user@example.com" },
    "username": { "stringValue": "username" },
    "favoriteClub": { "stringValue": "club1" },
    "isClubUser": { "booleanValue": false },
    "profileImageUrl": { "stringValue": "https://example.com/profile.jpg" },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
  }
}
```

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/users/{user_id}",
  "fields": {
    "email": { "stringValue": "user@example.com" },
    "username": { "stringValue": "username" },
    "favoriteClub": { "stringValue": "club1" },
    "isClubUser": { "booleanValue": false },
    "profileImageUrl": { "stringValue": "https://example.com/profile.jpg" },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T10:00:00.000000Z"
}
```

### 2.2 ユーザー情報取得

ユーザー情報を取得します。

**エンドポイント**: `GET /users/{user_id}`

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/users/{user_id}",
  "fields": {
    "email": { "stringValue": "user@example.com" },
    "username": { "stringValue": "username" },
    "favoriteClub": { "stringValue": "club1" },
    "isClubUser": { "booleanValue": false },
    "profileImageUrl": { "stringValue": "https://example.com/profile.jpg" },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T10:00:00.000000Z"
}
```

### 2.3 ユーザー情報更新

ユーザー情報を更新します。

**エンドポイント**: `PATCH /users/{user_id}`

**リクエスト**:

```json
{
  "fields": {
    "username": { "stringValue": "new_username" },
    "favoriteClub": { "stringValue": "club2" },
    "profileImageUrl": { "stringValue": "https://example.com/new_profile.jpg" },
    "updatedAt": { "timestampValue": "2025-03-27T11:00:00.000000Z" }
  },
  "updateMask": {
    "fieldPaths": ["username", "favoriteClub", "profileImageUrl", "updatedAt"]
  }
}
```

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/users/{user_id}",
  "fields": {
    "email": { "stringValue": "user@example.com" },
    "username": { "stringValue": "new_username" },
    "favoriteClub": { "stringValue": "club2" },
    "isClubUser": { "booleanValue": false },
    "profileImageUrl": { "stringValue": "https://example.com/new_profile.jpg" },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T11:00:00.000000Z" }
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T11:00:00.000000Z"
}
```

## 3. クラブAPI

### 3.1 クラブ一覧取得

クラブの一覧を取得します。

**エンドポイント**: `GET /clubs`

**クエリパラメータ**:
- `pageSize`: 取得するクラブの最大数
- `pageToken`: ページネーショントークン
- `orderBy`: ソート順（例: "name"）

**レスポンス**:

```json
{
  "documents": [
    {
      "name": "projects/scouting-app/databases/(default)/documents/clubs/club1",
      "fields": {
        "name": { "stringValue": "FC東京" },
        "category": { "stringValue": "J1" },
        "region": { "stringValue": "関東" },
        "logoUrl": { "stringValue": "https://example.com/fctokyo_logo.jpg" },
        "description": { "stringValue": "東京を拠点とするJリーグクラブ" },
        "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
        "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
      },
      "createTime": "2025-03-27T10:00:00.000000Z",
      "updateTime": "2025-03-27T10:00:00.000000Z"
    },
    // 他のクラブ...
  ],
  "nextPageToken": "next_page_token"
}
```

### 3.2 クラブ情報取得

特定のクラブの情報を取得します。

**エンドポイント**: `GET /clubs/{club_id}`

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/clubs/club1",
  "fields": {
    "name": { "stringValue": "FC東京" },
    "category": { "stringValue": "J1" },
    "region": { "stringValue": "関東" },
    "logoUrl": { "stringValue": "https://example.com/fctokyo_logo.jpg" },
    "description": { "stringValue": "東京を拠点とするJリーグクラブ" },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T10:00:00.000000Z"
}
```

## 4. 試合API

### 4.1 試合一覧取得

試合の一覧を取得します。

**エンドポイント**: `GET /matches`

**クエリパラメータ**:
- `pageSize`: 取得する試合の最大数
- `pageToken`: ページネーショントークン
- `orderBy`: ソート順（例: "date"）
- `region`: 地域でフィルタリング
- `category`: カテゴリでフィルタリング
- `date`: 日付でフィルタリング

**レスポンス**:

```json
{
  "documents": [
    {
      "name": "projects/scouting-app/databases/(default)/documents/matches/match1",
      "fields": {
        "homeTeamId": { "stringValue": "club1" },
        "awayTeamId": { "stringValue": "club2" },
        "date": { "timestampValue": "2025-04-01T15:00:00.000000Z" },
        "venue": { "stringValue": "味の素スタジアム" },
        "category": { "stringValue": "J1" },
        "status": { "stringValue": "scheduled" },
        "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
        "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
      },
      "createTime": "2025-03-27T10:00:00.000000Z",
      "updateTime": "2025-03-27T10:00:00.000000Z"
    },
    // 他の試合...
  ],
  "nextPageToken": "next_page_token"
}
```

### 4.2 試合情報取得

特定の試合の情報を取得します。

**エンドポイント**: `GET /matches/{match_id}`

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/matches/match1",
  "fields": {
    "homeTeamId": { "stringValue": "club1" },
    "awayTeamId": { "stringValue": "club2" },
    "date": { "timestampValue": "2025-04-01T15:00:00.000000Z" },
    "venue": { "stringValue": "味の素スタジアム" },
    "category": { "stringValue": "J1" },
    "status": { "stringValue": "scheduled" },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T10:00:00.000000Z"
}
```

## 5. 選手API

### 5.1 選手一覧取得

選手の一覧を取得します。

**エンドポイント**: `GET /players`

**クエリパラメータ**:
- `pageSize`: 取得する選手の最大数
- `pageToken`: ページネーショントークン
- `orderBy`: ソート順（例: "name"）
- `teamId`: チームIDでフィルタリング
- `position`: ポジションでフィルタリング

**レスポンス**:

```json
{
  "documents": [
    {
      "name": "projects/scouting-app/databases/(default)/documents/players/player1",
      "fields": {
        "name": { "stringValue": "山田 太郎" },
        "teamId": { "stringValue": "club1" },
        "position": { "stringValue": "MF" },
        "jerseyNumber": { "integerValue": "10" },
        "dateOfBirth": { "timestampValue": "1995-05-15T00:00:00.000000Z" },
        "height": { "integerValue": "175" },
        "weight": { "integerValue": "68" },
        "profileImageUrl": { "stringValue": "https://example.com/yamada_profile.jpg" },
        "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
        "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
      },
      "createTime": "2025-03-27T10:00:00.000000Z",
      "updateTime": "2025-03-27T10:00:00.000000Z"
    },
    // 他の選手...
  ],
  "nextPageToken": "next_page_token"
}
```

### 5.2 選手情報取得

特定の選手の情報を取得します。

**エンドポイント**: `GET /players/{player_id}`

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/players/player1",
  "fields": {
    "name": { "stringValue": "山田 太郎" },
    "teamId": { "stringValue": "club1" },
    "position": { "stringValue": "MF" },
    "jerseyNumber": { "integerValue": "10" },
    "dateOfBirth": { "timestampValue": "1995-05-15T00:00:00.000000Z" },
    "height": { "integerValue": "175" },
    "weight": { "integerValue": "68" },
    "profileImageUrl": { "stringValue": "https://example.com/yamada_profile.jpg" },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T10:00:00.000000Z"
}
```

## 6. スカウティングレポートAPI

### 6.1 レポート作成

新しいスカウティングレポートを作成します。

**エンドポイント**: `POST /reports`

**リクエスト**:

```json
{
  "fields": {
    "userId": { "stringValue": "user1" },
    "clubId": { "stringValue": "club1" },
    "playerId": { "stringValue": "player1" },
    "matchId": { "stringValue": "match1" },
    "templateId": { "stringValue": "template1" },
    "status": { "stringValue": "draft" },
    "evaluations": {
      "arrayValue": {
        "values": [
          {
            "mapValue": {
              "fields": {
                "id": { "stringValue": "eval1" },
                "itemId": { "stringValue": "item1" },
                "rating": { "integerValue": "4" },
                "comment": { "stringValue": "素晴らしいテクニックを持っています" }
              }
            }
          },
          {
            "mapValue": {
              "fields": {
                "id": { "stringValue": "eval2" },
                "itemId": { "stringValue": "item2" },
                "rating": { "integerValue": "3" },
                "comment": { "stringValue": "フィジカルは平均的" }
              }
            }
          }
        ]
      }
    },
    "overallComment": { "stringValue": "将来性のある選手です" },
    "mediaUrls": {
      "arrayValue": {
        "values": [
          { "stringValue": "https://example.com/report1_image1.jpg" },
          { "stringValue": "https://example.com/report1_image2.jpg" }
        ]
      }
    },
    "likes": { "integerValue": "0" },
    "feedback": { "nullValue": null },
    "pointsAwarded": { "integerValue": "0" },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
  }
}
```

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/reports/report1",
  "fields": {
    "userId": { "stringValue": "user1" },
    "clubId": { "stringValue": "club1" },
    "playerId": { "stringValue": "player1" },
    "matchId": { "stringValue": "match1" },
    "templateId": { "stringValue": "template1" },
    "status": { "stringValue": "draft" },
    "evaluations": {
      "arrayValue": {
        "values": [
          {
            "mapValue": {
              "fields": {
                "id": { "stringValue": "eval1" },
                "itemId": { "stringValue": "item1" },
                "rating": { "integerValue": "4" },
                "comment": { "stringValue": "素晴らしいテクニックを持っています" }
              }
            }
          },
          {
            "mapValue": {
              "fields": {
                "id": { "stringValue": "eval2" },
                "itemId": { "stringValue": "item2" },
                "rating": { "integerValue": "3" },
                "comment": { "stringValue": "フィジカルは平均的" }
              }
            }
          }
        ]
      }
    },
    "overallComment": { "stringValue": "将来性のある選手です" },
    "mediaUrls": {
      "arrayValue": {
        "values": [
          { "stringValue": "https://example.com/report1_image1.jpg" },
          { "stringValue": "https://example.com/report1_image2.jpg" }
        ]
      }
    },
    "likes": { "integerValue": "0" },
    "feedback": { "nullValue": null },
    "pointsAwarded": { "integerValue": "0" },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T10:00:00.000000Z"
}
```

### 6.2 レポート更新

スカウティングレポートを更新します。

**エンドポイント**: `PATCH /reports/{report_id}`

**リクエスト**:

```json
{
  "fields": {
    "status": { "stringValue": "submitted" },
    "evaluations": {
      "arrayValue": {
        "values": [
          {
            "mapValue": {
              "fields": {
                "id": { "stringValue": "eval1" },
                "itemId": { "stringValue": "item1" },
                "rating": { "integerValue": "5" },
                "comment": { "stringValue": "非常に優れたテクニックを持っています" }
              }
            }
          },
          {
            "mapValue": {
              "fields": {
                "id": { "stringValue": "eval2" },
                "itemId": { "stringValue": "item2" },
                "rating": { "integerValue": "3" },
                "comment": { "stringValue": "フィジカルは平均的" }
              }
            }
          }
        ]
      }
    },
    "overallComment": { "stringValue": "将来性のある選手です。特にテクニック面が優れています。" },
    "updatedAt": { "timestampValue": "2025-03-27T11:00:00.000000Z" }
  },
  "updateMask": {
    "fieldPaths": ["status", "evaluations", "overallComment", "updatedAt"]
  }
}
```

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/reports/report1",
  "fields": {
    "userId": { "stringValue": "user1" },
    "clubId": { "stringValue": "club1" },
    "playerId": { "stringValue": "player1" },
    "matchId": { "stringValue": "match1" },
    "templateId": { "stringValue": "template1" },
    "status": { "stringValue": "submitted" },
    "evaluations": {
      "arrayValue": {
        "values": [
          {
            "mapValue": {
              "fields": {
                "id": { "stringValue": "eval1" },
                "itemId": { "stringValue": "item1" },
                "rating": { "integerValue": "5" },
                "comment": { "stringValue": "非常に優れたテクニックを持っています" }
              }
            }
          },
          {
            "mapValue": {
              "fields": {
                "id": { "stringValue": "eval2" },
                "itemId": { "stringValue": "item2" },
                "rating": { "integerValue": "3" },
                "comment": { "stringValue": "フィジカルは平均的" }
              }
            }
          }
        ]
      }
    },
    "overallComment": { "stringValue": "将来性のある選手です。特にテクニック面が優れています。" },
    "mediaUrls": {
      "arrayValue": {
        "values": [
          { "stringValue": "https://example.com/report1_image1.jpg" },
          { "stringValue": "https://example.com/report1_image2.jpg" }
        ]
      }
    },
    "likes": { "integerValue": "0" },
    "feedback": { "nullValue": null },
    "pointsAwarded": { "integerValue": "0" },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T11:00:00.000000Z" }
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T11:00:00.000000Z"
}
```

### 6.3 レポート一覧取得（ユーザー別）

特定のユーザーが作成したレポートの一覧を取得します。

**エンドポイント**: `GET /reports?userId={user_id}`

**クエリパラメータ**:
- `userId`: ユーザーID（必須）
- `status`: レポートのステータスでフィルタリング（任意）
- `pageSize`: 取得するレポートの最大数
- `pageToken`: ページネーショントークン
- `orderBy`: ソート順（例: "createdAt desc"）

**レスポンス**:

```json
{
  "documents": [
    {
      "name": "projects/scouting-app/databases/(default)/documents/reports/report1",
      "fields": {
        // レポート1のフィールド
      },
      "createTime": "2025-03-27T10:00:00.000000Z",
      "updateTime": "2025-03-27T11:00:00.000000Z"
    },
    // 他のレポート...
  ],
  "nextPageToken": "next_page_token"
}
```

### 6.4 レポート一覧取得（クラブ別）

特定のクラブ向けのレポートの一覧を取得します。

**エンドポイント**: `GET /reports?clubId={club_id}`

**クエリパラメータ**:
- `clubId`: クラブID（必須）
- `status`: レポートのステータスでフィルタリング（任意）
- `pageSize`: 取得するレポートの最大数
- `pageToken`: ページネーショントークン
- `orderBy`: ソート順（例: "createdAt desc"）

**レスポンス**:

```json
{
  "documents": [
    {
      "name": "projects/scouting-app/databases/(default)/documents/reports/report1",
      "fields": {
        // レポート1のフィールド
      },
      "createTime": "2025-03-27T10:00:00.000000Z",
      "updateTime": "2025-03-27T11:00:00.000000Z"
    },
    // 他のレポート...
  ],
  "nextPageToken": "next_page_token"
}
```

### 6.5 レポート詳細取得

特定のレポートの詳細を取得します。

**エンドポイント**: `GET /reports/{report_id}`

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/reports/report1",
  "fields": {
    "userId": { "stringValue": "user1" },
    "clubId": { "stringValue": "club1" },
    "playerId": { "stringValue": "player1" },
    "matchId": { "stringValue": "match1" },
    "templateId": { "stringValue": "template1" },
    "status": { "stringValue": "submitted" },
    "evaluations": {
      "arrayValue": {
        "values": [
          // 評価項目...
        ]
      }
    },
    "overallComment": { "stringValue": "将来性のある選手です。特にテクニック面が優れています。" },
    "mediaUrls": {
      "arrayValue": {
        "values": [
          { "stringValue": "https://example.com/report1_image1.jpg" },
          { "stringValue": "https://example.com/report1_image2.jpg" }
        ]
      }
    },
    "likes": { "integerValue": "0" },
    "feedback": { "nullValue": null },
    "pointsAwarded": { "integerValue": "0" },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T11:00:00.000000Z" }
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T11:00:00.000000Z"
}
```

### 6.6 レポートへのいいね追加

レポートにいいねを追加します。

**エンドポイント**: `POST /reports/{report_id}:like`

**リクエスト**:

```json
{
  "clubId": "club1"
}
```

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/reports/report1",
  "fields": {
    // レポートのフィールド
    "likes": { "integerValue": "1" },
    // 他のフィールド...
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T12:00:00.000000Z"
}
```

### 6.7 レポートへのフィードバック追加

レポートにフィードバックを追加します。

**エンドポイント**: `POST /reports/{report_id}:feedback`

**リクエスト**:

```json
{
  "feedback": "素晴らしい観察眼です。特にテクニック面の評価が的確です。",
  "pointsAwarded": 100
}
```

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/reports/report1",
  "fields": {
    // レポートのフィールド
    "feedback": { "stringValue": "素晴らしい観察眼です。特にテクニック面の評価が的確です。" },
    "pointsAwarded": { "integerValue": "100" },
    "status": { "stringValue": "reviewed" },
    // 他のフィールド...
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T12:00:00.000000Z"
}
```

## 7. レポートテンプレートAPI

### 7.1 テンプレート作成

新しいレポートテンプレートを作成します。

**エンドポイント**: `POST /reportTemplates`

**リクエスト**:

```json
{
  "fields": {
    "clubId": { "stringValue": "club1" },
    "name": { "stringValue": "標準スカウティングテンプレート" },
    "description": { "stringValue": "選手の基本的な能力を評価するためのテンプレート" },
    "evaluationItems": {
      "arrayValue": {
        "values": [
          {
            "mapValue": {
              "fields": {
                "id": { "stringValue": "item1" },
                "name": { "stringValue": "テクニック" },
                "description": { "stringValue": "ボールコントロール、パス精度、ドリブル技術など" },
                "category": { "stringValue": "技術" }
              }
            }
          },
          {
            "mapValue": {
              "fields": {
                "id": { "stringValue": "item2" },
                "name": { "stringValue": "フィジカル" },
                "description": { "stringValue": "スピード、持久力、強さなど" },
                "category": { "stringValue": "身体能力" }
              }
            }
          },
          {
            "mapValue": {
              "fields": {
                "id": { "stringValue": "item3" },
                "name": { "stringValue": "戦術理解" },
                "description": { "stringValue": "ポジショニング、状況判断、戦術的柔軟性など" },
                "category": { "stringValue": "知性" }
              }
            }
          }
        ]
      }
    },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
  }
}
```

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/reportTemplates/template1",
  "fields": {
    "clubId": { "stringValue": "club1" },
    "name": { "stringValue": "標準スカウティングテンプレート" },
    "description": { "stringValue": "選手の基本的な能力を評価するためのテンプレート" },
    "evaluationItems": {
      "arrayValue": {
        "values": [
          // 評価項目...
        ]
      }
    },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T10:00:00.000000Z"
}
```

### 7.2 テンプレート一覧取得

テンプレートの一覧を取得します。

**エンドポイント**: `GET /reportTemplates`

**クエリパラメータ**:
- `clubId`: クラブIDでフィルタリング
- `pageSize`: 取得するテンプレートの最大数
- `pageToken`: ページネーショントークン
- `orderBy`: ソート順（例: "name"）

**レスポンス**:

```json
{
  "documents": [
    {
      "name": "projects/scouting-app/databases/(default)/documents/reportTemplates/template1",
      "fields": {
        // テンプレート1のフィールド
      },
      "createTime": "2025-03-27T10:00:00.000000Z",
      "updateTime": "2025-03-27T10:00:00.000000Z"
    },
    // 他のテンプレート...
  ],
  "nextPageToken": "next_page_token"
}
```

### 7.3 テンプレート詳細取得

特定のテンプレートの詳細を取得します。

**エンドポイント**: `GET /reportTemplates/{template_id}`

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/reportTemplates/template1",
  "fields": {
    "clubId": { "stringValue": "club1" },
    "name": { "stringValue": "標準スカウティングテンプレート" },
    "description": { "stringValue": "選手の基本的な能力を評価するためのテンプレート" },
    "evaluationItems": {
      "arrayValue": {
        "values": [
          // 評価項目...
        ]
      }
    },
    "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
  },
  "createTime": "2025-03-27T10:00:00.000000Z",
  "updateTime": "2025-03-27T10:00:00.000000Z"
}
```

## 8. ポイントAPI

### 8.1 ユーザーポイント取得

ユーザーの現在のポイントを取得します。

**エンドポイント**: `GET /users/{user_id}/points`

**レスポンス**:

```json
{
  "points": 250
}
```

### 8.2 ポイント履歴取得

ユーザーのポイント履歴を取得します。

**エンドポイント**: `GET /pointHistory`

**クエリパラメータ**:
- `userId`: ユーザーID（必須）
- `pageSize`: 取得する履歴の最大数
- `pageToken`: ページネーショントークン
- `orderBy`: ソート順（例: "createdAt desc"）

**レスポンス**:

```json
{
  "documents": [
    {
      "name": "projects/scouting-app/databases/(default)/documents/pointHistory/history1",
      "fields": {
        "userId": { "stringValue": "user1" },
        "amount": { "integerValue": "100" },
        "type": { "stringValue": "earned" },
        "description": { "stringValue": "レポートへのフィードバック" },
        "relatedId": { "stringValue": "report1" },
        "createdAt": { "timestampValue": "2025-03-27T12:00:00.000000Z" }
      },
      "createTime": "2025-03-27T12:00:00.000000Z",
      "updateTime": "2025-03-27T12:00:00.000000Z"
    },
    // 他の履歴...
  ],
  "nextPageToken": "next_page_token"
}
```

## 9. 報酬API

### 9.1 報酬アイテム一覧取得

報酬アイテムの一覧を取得します。

**エンドポイント**: `GET /rewardItems`

**クエリパラメータ**:
- `category`: カテゴリでフィルタリング
- `pageSize`: 取得するアイテムの最大数
- `pageToken`: ページネーショントークン
- `orderBy`: ソート順（例: "pointCost"）

**レスポンス**:

```json
{
  "documents": [
    {
      "name": "projects/scouting-app/databases/(default)/documents/rewardItems/reward1",
      "fields": {
        "name": { "stringValue": "ホームゲームチケット割引" },
        "description": { "stringValue": "次回ホームゲームのチケットが20%オフになります" },
        "pointCost": { "integerValue": "500" },
        "category": { "stringValue": "ticket" },
        "imageUrl": { "stringValue": "https://example.com/ticket_discount.jpg" },
        "createdAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" },
        "updatedAt": { "timestampValue": "2025-03-27T10:00:00.000000Z" }
      },
      "createTime": "2025-03-27T10:00:00.000000Z",
      "updateTime": "2025-03-27T10:00:00.000000Z"
    },
    // 他の報酬アイテム...
  ],
  "nextPageToken": "next_page_token"
}
```

### 9.2 報酬交換

報酬アイテムとポイントを交換します。

**エンドポイント**: `POST /rewardRedemptions`

**リクエスト**:

```json
{
  "fields": {
    "userId": { "stringValue": "user1" },
    "rewardId": { "stringValue": "reward1" },
    "status": { "stringValue": "pending" },
    "createdAt": { "timestampValue": "2025-03-27T13:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T13:00:00.000000Z" }
  }
}
```

**レスポンス**:

```json
{
  "name": "projects/scouting-app/databases/(default)/documents/rewardRedemptions/redemption1",
  "fields": {
    "userId": { "stringValue": "user1" },
    "rewardId": { "stringValue": "reward1" },
    "status": { "stringValue": "pending" },
    "createdAt": { "timestampValue": "2025-03-27T13:00:00.000000Z" },
    "updatedAt": { "timestampValue": "2025-03-27T13:00:00.000000Z" }
  },
  "createTime": "2025-03-27T13:00:00.000000Z",
  "updateTime": "2025-03-27T13:00:00.000000Z"
}
```

### 9.3 交換履歴取得

ユーザーの報酬交換履歴を取得します。

**エンドポイント**: `GET /rewardRedemptions`

**クエリパラメータ**:
- `userId`: ユーザーID（必須）
- `status`: ステータスでフィルタリング
- `pageSize`: 取得する履歴の最大数
- `pageToken`: ページネーショントークン
- `orderBy`: ソート順（例: "createdAt desc"）

**レスポンス**:

```json
{
  "documents": [
    {
      "name": "projects/scouting-app/databases/(default)/documents/rewardRedemptions/redemption1",
      "fields": {
        "userId": { "stringValue": "user1" },
        "rewardId": { "stringValue": "reward1" },
        "status": { "stringValue": "pending" },
        "createdAt": { "timestampValue": "2025-03-27T13:00:00.000000Z" },
        "updatedAt": { "timestampValue": "2025-03-27T13:00:00.000000Z" }
      },
      "createTime": "2025-03-27T13:00:00.000000Z",
      "updateTime": "2025-03-27T13:00:00.000000Z"
    },
    // 他の交換履歴...
  ],
  "nextPageToken": "next_page_token"
}
```

## 10. 分析API

### 10.1 ユーザー統計取得

ユーザーの統計情報を取得します。

**エンドポイント**: `GET /analytics/users/{user_id}`

**レスポンス**:

```json
{
  "totalReports": 15,
  "submittedReports": 12,
  "reviewedReports": 10,
  "totalLikes": 8,
  "totalPoints": 250,
  "averageRating": 4.2,
  "monthlyActivity": [
    {
      "month": "2025-01",
      "reports": 3
    },
    {
      "month": "2025-02",
      "reports": 5
    },
    {
      "month": "2025-03",
      "reports": 7
    }
  ]
}
```

### 10.2 クラブ統計取得

クラブの統計情報を取得します。

**エンドポイント**: `GET /analytics/clubs/{club_id}`

**レスポンス**:

```json
{
  "totalReceivedReports": 120,
  "reviewedReportsRate": 0.85,
  "averageFeedbackTime": 36, // 時間単位
  "positionDistribution": [
    {
      "position": "GK",
      "count": 10
    },
    {
      "position": "DF",
      "count": 35
    },
    {
      "position": "MF",
      "count": 45
    },
    {
      "position": "FW",
      "count": 30
    }
  ],
  "topContributors": [
    {
      "userId": "user1",
      "username": "スカウター1",
      "reports": 15
    },
    {
      "userId": "user2",
      "username": "スカウター2",
      "reports": 12
    },
    {
      "userId": "user3",
      "username": "スカウター3",
      "reports": 10
    }
  ]
}
```

### 10.3 選手分析取得

選手の分析情報を取得します。

**エンドポイント**: `GET /analytics/players/{player_id}`

**レスポンス**:

```json
{
  "totalReports": 25,
  "averageRatings": [
    {
      "itemId": "item1",
      "itemName": "テクニック",
      "average": 4.5
    },
    {
      "itemId": "item2",
      "itemName": "フィジカル",
      "average": 3.8
    },
    {
      "itemId": "item3",
      "itemName": "戦術理解",
      "average": 4.2
    }
  ],
  "strengths": ["テクニック", "ポジショニング"],
  "weaknesses": ["スピード"],
  "clubInterest": [
    {
      "clubId": "club1",
      "clubName": "FC東京",
      "reports": 10
    },
    {
      "clubId": "club2",
      "clubName": "川崎フロンターレ",
      "reports": 8
    }
  ],
  "trendData": [
    {
      "month": "2025-01",
      "average": 3.8
    },
    {
      "month": "2025-02",
      "average": 4.0
    },
    {
      "month": "2025-03",
      "average": 4.3
    }
  ]
}
```

## 11. エラーコード

| コード | ステータス | 説明 |
|--------|------------|------|
| 400 | INVALID_ARGUMENT | リクエストの形式が不正 |
| 401 | UNAUTHENTICATED | 認証エラー |
| 403 | PERMISSION_DENIED | 権限エラー |
| 404 | NOT_FOUND | リソースが見つからない |
| 409 | ALREADY_EXISTS | リソースが既に存在する |
| 429 | RESOURCE_EXHAUSTED | レート制限超過 |
| 500 | INTERNAL | サーバー内部エラー |
| 503 | UNAVAILABLE | サービス利用不可 |

## 12. 認証トークンの取得

Firebase認証トークンを取得するには、以下のエンドポイントを使用します：

**エンドポイント**: `POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={api_key}`

**リクエスト**:

```json
{
  "email": "user@example.com",
  "password": "password",
  "returnSecureToken": true
}
```

**レスポンス**:

```json
{
  "idToken": "firebase_auth_token",
  "email": "user@example.com",
  "refreshToken": "refresh_token",
  "expiresIn": "3600",
  "localId": "user_id"
}
```

## 13. ファイルアップロード

画像などのファイルをアップロードするには、Firebase Storageを使用します。

### 13.1 アップロードURL取得

**エンドポイント**: `POST https://firebasestorage.googleapis.com/v0/b/scouting-app.appspot.com/o?uploadType=resumable&name={path}`

**ヘッダー**:
- `Authorization: Bearer {firebase_auth_token}`
- `Content-Type: application/json`
- `X-Goog-Upload-Protocol: resumable`
- `X-Goog-Upload-Command: start`

**レスポンス**:

アップロードURLがレスポンスヘッダーの `X-Goog-Upload-URL` に含まれます。

### 13.2 ファイルアップロード

**エンドポイント**: `{upload_url}` (13.1で取得したURL)

**ヘッダー**:
- `Content-Type: {file_mime_type}`
- `X-Goog-Upload-Command: upload, finalize`

**リクエストボディ**:
ファイルのバイナリデータ

**レスポンス**:

```json
{
  "name": "{path}",
  "bucket": "scouting-app.appspot.com",
  "generation": "1585234664569",
  "metageneration": "1",
  "contentType": "{file_mime_type}",
  "timeCreated": "2025-03-27T10:00:00.000Z",
  "updated": "2025-03-27T10:00:00.000Z",
  "storageClass": "STANDARD",
  "size": "{file_size}",
  "md5Hash": "{md5_hash}",
  "contentEncoding": "identity",
  "contentDisposition": "inline",
  "downloadTokens": "{download_token}"
}
```

### 13.3 ファイルダウンロードURL

ファイルのダウンロードURLは以下の形式です：

```
https://firebasestorage.googleapis.com/v0/b/scouting-app.appspot.com/o/{encoded_path}?alt=media&token={download_token}
```

## 14. バージョン情報

- API バージョン: 1.0.0
- 最終更新日: 2025年3月27日
