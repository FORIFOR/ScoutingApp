# 「ファンがスカウトマンになれる」スポーツビジネスサービス デザインガイドライン

## 1. ブランドアイデンティティ

### 1.1 ブランドコンセプト
「ファンの情熱とクラブの専門性を繋ぐ、革新的なスカウティングプラットフォーム」

### 1.2 ブランド価値
- **信頼性**: 正確で価値あるスカウティング情報
- **コミュニティ**: ファンとクラブの協力関係の構築
- **革新性**: サッカー界の古い慣習を変革する新しいアプローチ
- **専門性**: プロフェッショナルな視点と知識の共有
- **報酬**: 貢献に対する適切な評価と還元

### 1.3 ブランドボイス
- 専門的だが親しみやすい
- 情熱的だが客観的
- 革新的だが信頼できる
- 簡潔だが詳細

## 2. カラーパレット

### 2.1 プライマリカラー
- **メインブルー**: #1A73E8
  - 使用箇所: ナビゲーションバー、プライマリボタン、アクセント
  - 意味: 信頼性、専門性、安定感

- **アクセントグリーン**: #34A853
  - 使用箇所: アクション完了、ポジティブフィードバック、成功表示
  - 意味: 成長、前進、ポジティブな変化

### 2.2 セカンダリカラー
- **サポートレッド**: #EA4335
  - 使用箇所: 警告、エラー、重要通知
  - 意味: 注意喚起、重要性

- **サポートイエロー**: #FBBC05
  - 使用箇所: ハイライト、注目要素、進行中の状態
  - 意味: エネルギー、熱意、注目

### 2.3 ニュートラルカラー
- **ダークグレー**: #202124
  - 使用箇所: 主要テキスト、ヘッダー
  
- **ミディアムグレー**: #5F6368
  - 使用箇所: セカンダリテキスト、アイコン
  
- **ライトグレー**: #E8EAED
  - 使用箇所: 背景、区切り線、非アクティブ要素
  
- **ホワイト**: #FFFFFF
  - 使用箇所: 背景、カード、コントラスト要素

### 2.4 カラーの使用ルール
- コントラスト比は最低4.5:1を維持し、アクセシビリティを確保
- プライマリカラーは全体の60%、セカンダリカラーは30%、アクセントカラーは10%の割合で使用
- 重要な情報や行動喚起にはプライマリカラーを使用
- 警告やエラーには一貫してサポートレッドを使用

## 3. タイポグラフィ

### 3.1 フォントファミリー
- **見出し**: SF Pro Display (iOS)
- **本文**: SF Pro Text (iOS)
- **アクセント**: SF Pro Rounded (特別な強調箇所)

### 3.2 フォントサイズ階層
- **大見出し (H1)**: 28pt / Bold
- **中見出し (H2)**: 22pt / Semibold
- **小見出し (H3)**: 20pt / Medium
- **サブ見出し (H4)**: 17pt / Medium
- **本文 (Body)**: 17pt / Regular
- **セカンダリテキスト**: 15pt / Regular
- **キャプション**: 13pt / Regular
- **小さいテキスト**: 11pt / Regular

### 3.3 行間
- 見出し: 1.2倍
- 本文: 1.4倍
- リスト: 1.5倍

### 3.4 文字間隔
- 見出し: -0.5pt
- 本文: 0pt
- 小さいテキスト: 0.5pt

### 3.5 テキストカラー
- 主要テキスト: ダークグレー (#202124)
- セカンダリテキスト: ミディアムグレー (#5F6368)
- 反転テキスト: ホワイト (#FFFFFF)
- リンク: メインブルー (#1A73E8)

## 4. アイコノグラフィ

### 4.1 アイコンスタイル
- **スタイル**: SF Symbols (iOS標準)
- **線の太さ**: Regular
- **サイズ**: 24pt (標準)、20pt (小)、28pt (大)
- **カラー**: プライマリカラーまたはニュートラルカラー

### 4.2 主要アイコン
- ホーム: house
- スケジュール: calendar
- レポート: doc.text
- プロフィール: person.circle
- 検索: magnifyingglass
- 通知: bell
- 設定: gear
- いいね: heart
- 追加: plus
- 編集: pencil
- 削除: trash
- 戻る: chevron.left
- 進む: chevron.right
- メニュー: ellipsis

### 4.3 アイコン使用ガイドライン
- 一貫したスタイルを維持
- 意味が明確で直感的なアイコンを選択
- 必要に応じてラベルテキストを併用
- タップ領域は最低44x44ptを確保

## 5. コンポーネント

### 5.1 ボタン

#### プライマリボタン
- 背景: メインブルー (#1A73E8)
- テキスト: ホワイト (#FFFFFF)
- フォント: SF Pro Text / Semibold / 17pt
- 角丸: 8pt
- パディング: 水平16pt、垂直12pt
- 状態変化:
  - プレス時: 不透明度80%
  - 無効時: 不透明度50%

#### セカンダリボタン
- 背景: 透明
- ボーダー: メインブルー (#1A73E8) / 1pt
- テキスト: メインブルー (#1A73E8)
- フォント: SF Pro Text / Semibold / 17pt
- 角丸: 8pt
- パディング: 水平16pt、垂直12pt
- 状態変化:
  - プレス時: 背景色メインブルー10%不透明度
  - 無効時: 不透明度50%

#### テキストボタン
- 背景: 透明
- テキスト: メインブルー (#1A73E8)
- フォント: SF Pro Text / Medium / 17pt
- パディング: 水平8pt、垂直8pt
- 状態変化:
  - プレス時: 不透明度70%
  - 無効時: 不透明度50%

#### アクションボタン (FAB)
- 形状: 円形
- 背景: メインブルー (#1A73E8)
- アイコン: ホワイト (#FFFFFF) / 24pt
- サイズ: 56pt x 56pt
- 影: Y方向2pt、ぼかし4pt、不透明度20%

### 5.2 入力フィールド

#### テキスト入力
- 背景: ホワイト (#FFFFFF)
- ボーダー: ライトグレー (#E8EAED) / 1pt
- テキスト: ダークグレー (#202124)
- プレースホルダー: ミディアムグレー (#5F6368)
- フォント: SF Pro Text / Regular / 17pt
- 角丸: 8pt
- パディング: 水平16pt、垂直12pt
- フォーカス時: ボーダーメインブルー (#1A73E8) / 2pt
- エラー時: ボーダーサポートレッド (#EA4335) / 2pt

#### 検索フィールド
- 背景: ライトグレー (#E8EAED)
- アイコン: ミディアムグレー (#5F6368) / 20pt
- テキスト: ダークグレー (#202124)
- フォント: SF Pro Text / Regular / 17pt
- 角丸: 20pt
- パディング: 水平12pt、垂直8pt

#### セレクター
- 背景: ホワイト (#FFFFFF)
- ボーダー: ライトグレー (#E8EAED) / 1pt
- テキスト: ダークグレー (#202124)
- アイコン: ミディアムグレー (#5F6368) / 20pt (下向き矢印)
- フォント: SF Pro Text / Regular / 17pt
- 角丸: 8pt
- パディング: 水平16pt、垂直12pt

### 5.3 カード

#### 標準カード
- 背景: ホワイト (#FFFFFF)
- ボーダー: なし
- 角丸: 12pt
- 影: Y方向2pt、ぼかし8pt、不透明度10%
- パディング: 16pt
- マージン: 底部8pt

#### リストカード
- 背景: ホワイト (#FFFFFF)
- ボーダー: 底部のみライトグレー (#E8EAED) / 1pt
- 角丸: なし
- 影: なし
- パディング: 水平16pt、垂直12pt

#### 強調カード
- 背景: ホワイト (#FFFFFF)
- ボーダー: 左側メインブルー (#1A73E8) / 4pt
- 角丸: 12pt
- 影: Y方向2pt、ぼかし8pt、不透明度10%
- パディング: 16pt
- マージン: 底部8pt

### 5.4 タブバー

#### 標準タブバー
- 背景: ホワイト (#FFFFFF)
- 上部ボーダー: ライトグレー (#E8EAED) / 1pt
- アイコン: 非選択時ミディアムグレー (#5F6368)、選択時メインブルー (#1A73E8)
- ラベル: 非選択時ミディアムグレー (#5F6368)、選択時メインブルー (#1A73E8)
- フォント: SF Pro Text / Medium / 10pt
- パディング: 上部6pt、下部8pt (iPhoneXシリーズ以降は安全領域を考慮)

### 5.5 ナビゲーションバー

#### 標準ナビゲーションバー
- 背景: ホワイト (#FFFFFF)
- 底部ボーダー: ライトグレー (#E8EAED) / 1pt
- タイトル: ダークグレー (#202124)
- フォント: SF Pro Text / Semibold / 17pt
- ボタン: メインブルー (#1A73E8)
- 高さ: 44pt (ステータスバー除く)

### 5.6 リスト

#### 標準リスト
- 区切り線: ライトグレー (#E8EAED) / 1pt
- 背景: ホワイト (#FFFFFF)
- 見出し: ミディアムグレー (#5F6368)
- 見出しフォント: SF Pro Text / Medium / 13pt
- アイテムテキスト: ダークグレー (#202124)
- アイテムフォント: SF Pro Text / Regular / 17pt
- パディング: 水平16pt、垂直12pt

#### グループリスト
- セクション間隔: 24pt
- セクション見出し: ミディアムグレー (#5F6368)
- 見出しフォント: SF Pro Text / Medium / 13pt
- 背景: ライトグレー (#E8EAED)
- アイテム背景: ホワイト (#FFFFFF)
- 角丸: 最初と最後のアイテムのみ8pt

### 5.7 評価表示

#### 星評価
- 非選択星: ライトグレー (#E8EAED)
- 選択星: サポートイエロー (#FBBC05)
- サイズ: 24pt (標準)、20pt (小)、28pt (大)
- 間隔: 4pt

#### スコアバッジ
- 背景: メインブルー (#1A73E8)
- テキスト: ホワイト (#FFFFFF)
- フォント: SF Pro Text / Bold / 15pt
- 形状: 円形または角丸四角形
- サイズ: 28pt x 28pt (円形)、28pt x 20pt (角丸四角形)

### 5.8 通知

#### インアプリ通知
- 背景: ダークグレー (#202124) / 90%不透明度
- テキスト: ホワイト (#FFFFFF)
- フォント: SF Pro Text / Regular / 15pt
- 角丸: 12pt
- パディング: 水平16pt、垂直12pt
- 表示時間: 3秒
- アニメーション: フェードイン・フェードアウト

#### アラートダイアログ
- 背景: ホワイト (#FFFFFF)
- タイトル: ダークグレー (#202124)
- タイトルフォント: SF Pro Text / Semibold / 17pt
- メッセージ: ダークグレー (#202124)
- メッセージフォント: SF Pro Text / Regular / 15pt
- ボタン: メインブルー (#1A73E8)
- 角丸: 12pt
- パディング: 24pt

## 6. レイアウト

### 6.1 グリッドシステム
- 基本単位: 8pt
- 水平マージン: 16pt (画面端)
- 垂直マージン: 16pt (セクション間)
- 要素間隔: 8pt (小)、16pt (中)、24pt (大)

### 6.2 レスポンシブ設計
- iPhone SE (小): 320pt幅
- iPhone標準: 375pt幅
- iPhone Plus/Max: 414pt幅以上
- 要素サイズは相対値を使用し、画面サイズに応じて調整

### 6.3 安全領域
- ノッチ付きiPhone: 上部44pt、下部34pt
- 標準iPhone: 上部20pt、下部0pt
- コンテンツは常に安全領域内に配置

## 7. アニメーションとトランジション

### 7.1 トランジション
- 画面遷移: スライドイン (水平方向)
- モーダル表示: スライドアップ (垂直方向)
- ポップアップ: フェードイン
- タブ切替: クロスフェード

### 7.2 アニメーション
- 持続時間: 0.3秒 (標準)、0.5秒 (強調)、0.2秒 (軽微)
- イージング: イーズイン・アウト (標準)、イーズアウト (強調)
- ローディング: 回転スピナー (メインブルー)
- ボタンフィードバック: スケール縮小 (95%) + 不透明度変化

### 7.3 マイクロインタラクション
- いいねボタン: 心臓の鼓動アニメーション
- 評価入力: 星が輝くアニメーション
- 成功フィードバック: チェックマークのスケールアニメーション
- プルトゥリフレッシュ: カスタムローディングアニメーション

## 8. 画像とメディア

### 8.1 写真スタイル
- 選手写真: アクション中のダイナミックなショット
- プロフィール写真: 正方形、アスペクト比1:1
- 背景写真: 低コントラスト、テキストオーバーレイ用に暗め

### 8.2 イラストスタイル
- フラットデザイン
- 単色または2〜3色の配色
- 線の太さ一定
- 角丸の形状
- スポーツをテーマにした親しみやすいスタイル

### 8.3 アスペクト比
- プロフィール画像: 1:1 (正方形)
- 選手アクション写真: 16:9 (横長)
- チームロゴ: 1:1 (正方形)
- バナー画像: 2:1 (横長)

### 8.4 画像処理
- 解像度: @2x (標準)、@3x (高解像度ディスプレイ)
- フォーマット: PNG (UI要素、透過必要)、JPEG (写真)、SVG (アイコン、ロゴ)
- 圧縮: 画質80%以上を維持

## 9. アクセシビリティ

### 9.1 コントラスト
- テキストと背景のコントラスト比: 最低4.5:1
- 大きなテキスト (18pt以上): 最低3:1
- UI要素と背景のコントラスト比: 最低3:1

### 9.2 タッチターゲット
- 最小サイズ: 44pt x 44pt
- 間隔: 最低8pt

### 9.3 テキストサイズ
- Dynamic Type対応
- テキストは最大200%まで拡大可能に設計

### 9.4 支援技術
- VoiceOver対応
- 全ての画像に代替テキスト
- フォームラベルの明示
- セマンティックな要素の使用

## 10. 実装ガイドライン

### 10.1 コード規約
- SwiftUIとUIKitのハイブリッド使用
- コンポーネントの再利用性を重視
- 命名規則の一貫性を維持

### 10.2 アセット管理
- アセットカタログの使用
- 命名規則: 機能_要素_状態
- カラーセットの活用
- シンボルイメージの活用

### 10.3 ダークモード対応
- 全てのカラーはカラーアセットで管理
- ダークモード用の代替カラー設定
- コントラスト比の維持
- 画像の自動調整

### 10.4 国際化対応
- 全てのテキストはローカライズファイルで管理
- 右から左へ (RTL) 言語のレイアウト対応
- 可変長テキストに対応したレイアウト
- 日付と時刻のローカライズ
