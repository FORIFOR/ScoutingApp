import XCTest
@testable import ScoutingApp

class UITests: XCTestCase {
    
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
    
    func testOnboardingFlow() {
        // オンボーディング画面の表示を確認
        XCTAssertTrue(app.staticTexts["ファンがスカウトマンになれる"].exists)
        
        // 次へボタンをタップ
        app.buttons["次へ"].tap()
        
        // 2ページ目の表示を確認
        XCTAssertTrue(app.staticTexts["試合を観戦してスカウティング"].exists)
        
        // 次へボタンをタップ
        app.buttons["次へ"].tap()
        
        // 3ページ目の表示を確認
        XCTAssertTrue(app.staticTexts["レポートを作成して共有"].exists)
        
        // 次へボタンをタップ
        app.buttons["次へ"].tap()
        
        // 4ページ目の表示を確認
        XCTAssertTrue(app.staticTexts["クラブからの評価でポイント獲得"].exists)
        
        // 始めるボタンをタップ
        app.buttons["始める"].tap()
        
        // 認証画面に遷移したことを確認
        XCTAssertTrue(app.staticTexts["アカウント作成"].exists || app.staticTexts["ログイン"].exists)
    }
    
    func testSignUpFlow() {
        // オンボーディングをスキップ
        if app.staticTexts["ファンがスカウトマンになれる"].exists {
            app.buttons["スキップ"].tap()
        }
        
        // 新規登録タブをタップ
        app.buttons["新規登録"].tap()
        
        // フォームに入力
        let emailTextField = app.textFields["メールアドレス"]
        emailTextField.tap()
        emailTextField.typeText("test@example.com")
        
        let passwordTextField = app.secureTextFields["パスワード"]
        passwordTextField.tap()
        passwordTextField.typeText("password123")
        
        let usernameTextField = app.textFields["ユーザー名"]
        usernameTextField.tap()
        usernameTextField.typeText("テストユーザー")
        
        // 登録ボタンをタップ
        app.buttons["登録する"].tap()
        
        // プロフィール設定画面に遷移したことを確認
        XCTAssertTrue(app.staticTexts["プロフィール設定"].waitForExistence(timeout: 5.0))
    }
    
    func testLoginFlow() {
        // オンボーディングをスキップ
        if app.staticTexts["ファンがスカウトマンになれる"].exists {
            app.buttons["スキップ"].tap()
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
    
    func testHomeTabNavigation() {
        // ログイン処理
        loginToApp()
        
        // ホームタブが選択されていることを確認
        XCTAssertTrue(app.tabBars["タブバー"].buttons["ホーム"].isSelected)
        
        // ホーム画面の要素を確認
        XCTAssertTrue(app.staticTexts["おすすめの試合"].exists)
        XCTAssertTrue(app.staticTexts["最近のレポート"].exists)
        
        // 試合詳細をタップ
        app.cells["matchCell"].firstMatch.tap()
        
        // 試合詳細画面に遷移したことを確認
        XCTAssertTrue(app.navigationBars["試合詳細"].waitForExistence(timeout: 2.0))
        
        // 戻るボタンをタップ
        app.navigationBars["試合詳細"].buttons["戻る"].tap()
        
        // ホーム画面に戻ったことを確認
        XCTAssertTrue(app.staticTexts["おすすめの試合"].exists)
    }
    
    func testScheduleTabNavigation() {
        // ログイン処理
        loginToApp()
        
        // スケジュールタブをタップ
        app.tabBars["タブバー"].buttons["スケジュール"].tap()
        
        // スケジュール画面の要素を確認
        XCTAssertTrue(app.navigationBars["試合スケジュール"].exists)
        XCTAssertTrue(app.buttons["フィルター"].exists)
        
        // フィルターボタンをタップ
        app.buttons["フィルター"].tap()
        
        // フィルターモーダルが表示されたことを確認
        XCTAssertTrue(app.sheets["フィルター設定"].waitForExistence(timeout: 2.0))
        
        // キャンセルボタンをタップ
        app.sheets["フィルター設定"].buttons["キャンセル"].tap()
        
        // 試合セルをタップ
        if app.cells["matchCell"].firstMatch.waitForExistence(timeout: 2.0) {
            app.cells["matchCell"].firstMatch.tap()
            
            // 試合詳細画面に遷移したことを確認
            XCTAssertTrue(app.navigationBars["試合詳細"].waitForExistence(timeout: 2.0))
            
            // レポート作成ボタンをタップ
            app.buttons["レポート作成"].tap()
            
            // レポート作成画面に遷移したことを確認
            XCTAssertTrue(app.navigationBars["レポート作成"].waitForExistence(timeout: 2.0))
        }
    }
    
    func testReportCreationFlow() {
        // ログイン処理
        loginToApp()
        
        // スケジュールタブをタップ
        app.tabBars["タブバー"].buttons["スケジュール"].tap()
        
        // 試合セルをタップ
        if app.cells["matchCell"].firstMatch.waitForExistence(timeout: 2.0) {
            app.cells["matchCell"].firstMatch.tap()
            
            // レポート作成ボタンをタップ
            app.buttons["レポート作成"].tap()
            
            // レポート作成画面の要素を確認
            XCTAssertTrue(app.navigationBars["レポート作成"].exists)
            XCTAssertTrue(app.pickers["選手選択"].exists)
            
            // 選手を選択
            app.pickers["選手選択"].tap()
            app.pickerWheels.element.adjust(toPickerWheelValue: "山田 太郎")
            app.toolbars.buttons["完了"].tap()
            
            // 評価項目を入力
            app.sliders["技術評価"].adjust(toNormalizedSliderPosition: 0.8)
            app.sliders["フィジカル評価"].adjust(toNormalizedSliderPosition: 0.6)
            
            // コメントを入力
            let commentTextView = app.textViews["コメント"]
            commentTextView.tap()
            commentTextView.typeText("素晴らしいテクニックを持っています。将来性のある選手です。")
            
            // 保存ボタンをタップ
            app.navigationBars["レポート作成"].buttons["保存"].tap()
            
            // 保存確認アラートが表示されたことを確認
            XCTAssertTrue(app.alerts["レポートを保存"].waitForExistence(timeout: 2.0))
            
            // 下書き保存をタップ
            app.alerts["レポートを保存"].buttons["下書き保存"].tap()
            
            // 試合詳細画面に戻ったことを確認
            XCTAssertTrue(app.navigationBars["試合詳細"].waitForExistence(timeout: 2.0))
        }
    }
    
    func testReportTabNavigation() {
        // ログイン処理
        loginToApp()
        
        // レポートタブをタップ
        app.tabBars["タブバー"].buttons["レポート"].tap()
        
        // レポート画面の要素を確認
        XCTAssertTrue(app.navigationBars["マイレポート"].exists)
        XCTAssertTrue(app.segmentedControls["レポートフィルター"].exists)
        
        // 下書きセグメントをタップ
        app.segmentedControls["レポートフィルター"].buttons["下書き"].tap()
        
        // レポートセルが存在する場合はタップ
        if app.cells["reportCell"].firstMatch.waitForExistence(timeout: 2.0) {
            app.cells["reportCell"].firstMatch.tap()
            
            // レポート詳細画面に遷移したことを確認
            XCTAssertTrue(app.navigationBars["レポート詳細"].waitForExistence(timeout: 2.0))
            
            // 編集ボタンをタップ
            app.navigationBars["レポート詳細"].buttons["編集"].tap()
            
            // レポート編集画面に遷移したことを確認
            XCTAssertTrue(app.navigationBars["レポート編集"].waitForExistence(timeout: 2.0))
        }
    }
    
    func testProfileTabNavigation() {
        // ログイン処理
        loginToApp()
        
        // プロフィールタブをタップ
        app.tabBars["タブバー"].buttons["プロフィール"].tap()
        
        // プロフィール画面の要素を確認
        XCTAssertTrue(app.staticTexts["マイプロフィール"].exists)
        XCTAssertTrue(app.staticTexts["獲得ポイント"].exists)
        
        // 設定ボタンをタップ
        app.navigationBars["プロフィール"].buttons["設定"].tap()
        
        // 設定画面に遷移したことを確認
        XCTAssertTrue(app.navigationBars["設定"].waitForExistence(timeout: 2.0))
        
        // アカウント設定をタップ
        app.cells["アカウント設定"].tap()
        
        // アカウント設定画面に遷移したことを確認
        XCTAssertTrue(app.navigationBars["アカウント設定"].waitForExistence(timeout: 2.0))
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
