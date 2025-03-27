import XCTest
@testable import ScoutingApp

class UsabilityTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDown() {
        app = nil
        super.tearDown()
    }
    
    func testOnboardingUsability() {
        // オンボーディングの使いやすさをテスト
        
        // 1. 初期画面の表示を確認
        XCTAssertTrue(app.staticTexts["ファンがスカウトマンになれる"].exists)
        XCTAssertTrue(app.buttons["次へ"].exists)
        XCTAssertTrue(app.buttons["スキップ"].exists)
        
        // 2. 進行状況インジケータの表示を確認
        XCTAssertTrue(app.pageIndicators["ページインジケータ"].exists)
        
        // 3. スワイプジェスチャーでの画面遷移をテスト
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["試合を観戦してスカウティング"].exists)
        
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["レポートを作成して共有"].exists)
        
        app.swipeLeft()
        XCTAssertTrue(app.staticTexts["クラブからの評価でポイント獲得"].exists)
        
        // 4. 戻るジェスチャーをテスト
        app.swipeRight()
        XCTAssertTrue(app.staticTexts["レポートを作成して共有"].exists)
        
        // 5. 「始める」ボタンの表示と機能をテスト
        app.swipeLeft()
        app.swipeLeft()
        XCTAssertTrue(app.buttons["始める"].exists)
        app.buttons["始める"].tap()
        
        // 認証画面に遷移したことを確認
        XCTAssertTrue(app.staticTexts["アカウント作成"].exists || app.staticTexts["ログイン"].exists)
    }
    
    func testAuthenticationFormUsability() {
        // 認証フォームの使いやすさをテスト
        
        // オンボーディングをスキップ
        if app.staticTexts["ファンがスカウトマンになれる"].exists {
            app.buttons["スキップ"].tap()
        }
        
        // 1. タブ切り替えの使いやすさをテスト
        XCTAssertTrue(app.buttons["新規登録"].exists)
        XCTAssertTrue(app.buttons["ログイン"].exists)
        
        app.buttons["新規登録"].tap()
        XCTAssertTrue(app.textFields["メールアドレス"].exists)
        XCTAssertTrue(app.secureTextFields["パスワード"].exists)
        XCTAssertTrue(app.textFields["ユーザー名"].exists)
        
        app.buttons["ログイン"].tap()
        XCTAssertTrue(app.textFields["メールアドレス"].exists)
        XCTAssertTrue(app.secureTextFields["パスワード"].exists)
        XCTAssertFalse(app.textFields["ユーザー名"].exists)
        
        // 2. フォーム入力の使いやすさをテスト
        let emailTextField = app.textFields["メールアドレス"]
        emailTextField.tap()
        emailTextField.typeText("test@example.com")
        
        // キーボードの「次へ」ボタンをタップ
        app.buttons["次へ"].tap()
        
        // パスワードフィールドにフォーカスが移ったことを確認
        XCTAssertTrue(app.secureTextFields["パスワード"].isSelected)
        
        // 3. エラー表示の確認
        app.buttons["ログイン"].tap()
        
        // エラーメッセージが表示されることを確認
        XCTAssertTrue(app.staticTexts["パスワードを入力してください"].waitForExistence(timeout: 2.0))
        
        // 4. パスワード表示切り替えの確認
        app.secureTextFields["パスワード"].tap()
        app.secureTextFields["パスワード"].typeText("password123")
        
        // パスワード表示ボタンをタップ
        app.buttons["パスワード表示"].tap()
        
        // パスワードが表示されることを確認（UIテストでは実際の表示は確認できないが、ボタンの状態変化を確認）
        XCTAssertTrue(app.buttons["パスワード非表示"].exists)
    }
    
    func testTabBarUsability() {
        // タブバーの使いやすさをテスト
        
        // ログイン処理
        loginToApp()
        
        // 1. 各タブの存在を確認
        XCTAssertTrue(app.tabBars["タブバー"].buttons["ホーム"].exists)
        XCTAssertTrue(app.tabBars["タブバー"].buttons["スケジュール"].exists)
        XCTAssertTrue(app.tabBars["タブバー"].buttons["レポート"].exists)
        XCTAssertTrue(app.tabBars["タブバー"].buttons["プロフィール"].exists)
        
        // 2. タブ切り替えの使いやすさをテスト
        app.tabBars["タブバー"].buttons["スケジュール"].tap()
        XCTAssertTrue(app.navigationBars["試合スケジュール"].exists)
        
        app.tabBars["タブバー"].buttons["レポート"].tap()
        XCTAssertTrue(app.navigationBars["マイレポート"].exists)
        
        app.tabBars["タブバー"].buttons["プロフィール"].tap()
        XCTAssertTrue(app.staticTexts["マイプロフィール"].exists)
        
        app.tabBars["タブバー"].buttons["ホーム"].tap()
        XCTAssertTrue(app.staticTexts["おすすめの試合"].exists)
        
        // 3. タブバーのアイコンとラベルの視認性を確認
        // （実際の視認性は自動テストでは確認できないが、存在確認は可能）
        XCTAssertTrue(app.tabBars["タブバー"].buttons["ホーム"].images["ホームアイコン"].exists)
        XCTAssertTrue(app.tabBars["タブバー"].buttons["スケジュール"].images["スケジュールアイコン"].exists)
        XCTAssertTrue(app.tabBars["タブバー"].buttons["レポート"].images["レポートアイコン"].exists)
        XCTAssertTrue(app.tabBars["タブバー"].buttons["プロフィール"].images["プロフィールアイコン"].exists)
    }
    
    func testScheduleScreenUsability() {
        // スケジュール画面の使いやすさをテスト
        
        // ログイン処理
        loginToApp()
        
        // スケジュールタブをタップ
        app.tabBars["タブバー"].buttons["スケジュール"].tap()
        
        // 1. フィルター機能の使いやすさをテスト
        app.buttons["フィルター"].tap()
        
        // フィルターモーダルの表示を確認
        XCTAssertTrue(app.sheets["フィルター設定"].waitForExistence(timeout: 2.0))
        
        // 地域フィルターの操作
        app.sheets["フィルター設定"].segmentedControls["地域フィルター"].buttons["関東"].tap()
        
        // カテゴリフィルターの操作
        app.sheets["フィルター設定"].segmentedControls["カテゴリフィルター"].buttons["J1"].tap()
        
        // 適用ボタンをタップ
        app.sheets["フィルター設定"].buttons["適用"].tap()
        
        // フィルター適用後の表示を確認
        XCTAssertTrue(app.staticTexts["フィルター: 関東, J1"].waitForExistence(timeout: 2.0))
        
        // 2. 日付セクションの使いやすさをテスト
        if app.collectionViews["日付セレクタ"].exists {
            // 日付セレクタの操作
            app.collectionViews["日付セレクタ"].cells.element(boundBy: 2).tap()
            
            // 日付選択後の表示を確認
            XCTAssertTrue(app.staticTexts["選択日: "].exists)
        }
        
        // 3. 試合リストの使いやすさをテスト
        if app.tables["試合リスト"].cells.count > 0 {
            // スクロール操作
            app.tables["試合リスト"].swipeUp()
            app.tables["試合リスト"].swipeDown()
            
            // 試合セルのタップ
            app.tables["試合リスト"].cells.element(boundBy: 0).tap()
            
            // 試合詳細画面に遷移したことを確認
            XCTAssertTrue(app.navigationBars["試合詳細"].waitForExistence(timeout: 2.0))
        }
    }
    
    func testReportCreationUsability() {
        // レポート作成画面の使いやすさをテスト
        
        // ログイン処理
        loginToApp()
        
        // スケジュールタブをタップ
        app.tabBars["タブバー"].buttons["スケジュール"].tap()
        
        // 試合セルをタップ
        if app.tables["試合リスト"].cells.count > 0 {
            app.tables["試合リスト"].cells.element(boundBy: 0).tap()
            
            // レポート作成ボタンをタップ
            app.buttons["レポート作成"].tap()
            
            // 1. 選手選択の使いやすさをテスト
            XCTAssertTrue(app.pickers["選手選択"].exists)
            app.pickers["選手選択"].tap()
            
            // ピッカーの操作
            app.pickerWheels.element.adjust(toPickerWheelValue: "山田 太郎")
            app.toolbars.buttons["完了"].tap()
            
            // 2. 評価項目の使いやすさをテスト
            XCTAssertTrue(app.sliders["技術評価"].exists)
            app.sliders["技術評価"].adjust(toNormalizedSliderPosition: 0.8)
            
            // 評価値の表示を確認
            XCTAssertTrue(app.staticTexts["4"].exists)
            
            // 3. コメント入力の使いやすさをテスト
            let commentTextView = app.textViews["コメント"]
            XCTAssertTrue(commentTextView.exists)
            commentTextView.tap()
            commentTextView.typeText("素晴らしいテクニックを持っています。将来性のある選手です。")
            
            // キーボードを閉じる
            app.buttons["完了"].tap()
            
            // 4. 画像添付の使いやすさをテスト
            XCTAssertTrue(app.buttons["画像添付"].exists)
            
            // 5. 保存/提出ボタンの使いやすさをテスト
            XCTAssertTrue(app.navigationBars["レポート作成"].buttons["保存"].exists)
            app.navigationBars["レポート作成"].buttons["保存"].tap()
            
            // 保存オプションの表示を確認
            XCTAssertTrue(app.alerts["レポートを保存"].waitForExistence(timeout: 2.0))
            XCTAssertTrue(app.alerts["レポートを保存"].buttons["下書き保存"].exists)
            XCTAssertTrue(app.alerts["レポートを保存"].buttons["提出"].exists)
            XCTAssertTrue(app.alerts["レポートを保存"].buttons["キャンセル"].exists)
            
            // キャンセルをタップ
            app.alerts["レポートを保存"].buttons["キャンセル"].tap()
        }
    }
    
    func testProfileScreenUsability() {
        // プロフィール画面の使いやすさをテスト
        
        // ログイン処理
        loginToApp()
        
        // プロフィールタブをタップ
        app.tabBars["タブバー"].buttons["プロフィール"].tap()
        
        // 1. プロフィール情報の表示を確認
        XCTAssertTrue(app.staticTexts["マイプロフィール"].exists)
        XCTAssertTrue(app.staticTexts["獲得ポイント"].exists)
        
        // 2. 実績セクションの使いやすさをテスト
        if app.collectionViews["実績リスト"].exists {
            // スクロール操作
            app.collectionViews["実績リスト"].swipeLeft()
            app.collectionViews["実績リスト"].swipeRight()
        }
        
        // 3. 最近のレポートセクションの使いやすさをテスト
        if app.tables["最近のレポート"].exists {
            // スクロール操作
            app.tables["最近のレポート"].swipeUp()
            app.tables["最近のレポート"].swipeDown()
            
            // レポートセルのタップ
            if app.tables["最近のレポート"].cells.count > 0 {
                app.tables["最近のレポート"].cells.element(boundBy: 0).tap()
                
                // レポート詳細画面に遷移したことを確認
                XCTAssertTrue(app.navigationBars["レポート詳細"].waitForExistence(timeout: 2.0))
                
                // 戻るボタンをタップ
                app.navigationBars["レポート詳細"].buttons["戻る"].tap()
            }
        }
        
        // 4. 設定ボタンの使いやすさをテスト
        XCTAssertTrue(app.navigationBars["プロフィール"].buttons["設定"].exists)
        app.navigationBars["プロフィール"].buttons["設定"].tap()
        
        // 設定画面に遷移したことを確認
        XCTAssertTrue(app.navigationBars["設定"].waitForExistence(timeout: 2.0))
    }
    
    func testAccessibilityFeatures() {
        // アクセシビリティ機能のテスト
        
        // ログイン処理
        loginToApp()
        
        // 1. VoiceOverのラベル設定を確認
        XCTAssertEqual(app.tabBars["タブバー"].buttons["ホーム"].label, "ホーム")
        XCTAssertEqual(app.tabBars["タブバー"].buttons["スケジュール"].label, "スケジュール")
        XCTAssertEqual(app.tabBars["タブバー"].buttons["レポート"].label, "レポート")
        XCTAssertEqual(app.tabBars["タブバー"].buttons["プロフィール"].label, "プロフィール")
        
        // スケジュールタブをタップ
        app.tabBars["タブバー"].buttons["スケジュール"].tap()
        
        // 2. ボタンのアクセシビリティラベルを確認
        XCTAssertEqual(app.buttons["フィルター"].label, "フィルター")
        
        // 3. テーブルセルのアクセシビリティラベルを確認
        if app.tables["試合リスト"].cells.count > 0 {
            let firstCell = app.tables["試合リスト"].cells.element(boundBy: 0)
            XCTAssertTrue(firstCell.label.contains("試合"))
        }
        
        // 4. ダイナミックタイプ（文字サイズ）のサポートは自動テストでは確認困難
        
        // 5. コントラスト比のテストは自動テストでは確認困難
    }
    
    // ヘルパーメソッド
    private func loginToApp() {
        // オンボーディングをスキップ
        if app.staticTexts["ファンがスカウトマンになれる"].exists {
            app.buttons["スキップ"].tap()
        }
        
        // 既にログイン済みの場合はスキップ
        if app.tabBars["タブバー"].buttons["ホーム"].exists {
            return
        }
        
        // ログインタブをタップ
        app.buttons["ログイン"].tap()
        
        // フォームに入力
        let emailTextField = app.textFields["メールアドレス"]
        emailTextField.tap()
        emailTextField.typeText("existing@example.com")
        
        let passwordTextField = app.secureTextFields["パスワード"]
        passwordTextField.tap()
        passwordTextField.typeText("password123")
        
        // ログインボタンをタップ
        app.buttons["ログイン"].tap()
        
        // ホーム画面に遷移したことを確認
        XCTAssertTrue(app.tabBars["タブバー"].buttons["ホーム"].waitForExistence(timeout: 5.0))
    }
}
