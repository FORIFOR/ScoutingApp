import XCTest
@testable import ScoutingApp

class SecurityTests: XCTestCase {
    
    var securityManager: SecurityManager!
    
    override func setUp() {
        super.setUp()
        securityManager = SecurityManager.shared
    }
    
    override func tearDown() {
        // セキュリティテスト後のクリーンアップ
        securityManager.removeAuthToken()
        securityManager.removeRefreshToken()
        securityManager.removeUserCredentials()
        super.tearDown()
    }
    
    func testTokenManagement() {
        // テスト用データ
        let authToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IlRlc3QgVXNlciIsImlhdCI6MTUxNjIzOTAyMn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
        let refreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IlRlc3QgVXNlciIsImlhdCI6MTUxNjIzOTAyMn0.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
        
        // 認証トークンの保存と取得をテスト
        securityManager.saveAuthToken(token: authToken)
        let retrievedAuthToken = securityManager.getAuthToken()
        XCTAssertEqual(retrievedAuthToken, authToken)
        
        // リフレッシュトークンの保存と取得をテスト
        securityManager.saveRefreshToken(token: refreshToken)
        let retrievedRefreshToken = securityManager.getRefreshToken()
        XCTAssertEqual(retrievedRefreshToken, refreshToken)
        
        // トークンの削除をテスト
        securityManager.removeAuthToken()
        securityManager.removeRefreshToken()
        XCTAssertNil(securityManager.getAuthToken())
        XCTAssertNil(securityManager.getRefreshToken())
    }
    
    func testUserCredentialsManagement() {
        // テスト用データ
        let email = "test@example.com"
        let password = "SecurePassword123!"
        
        // ユーザー認証情報の保存と取得をテスト
        securityManager.saveUserCredentials(email: email, password: password)
        let retrievedEmail = securityManager.getUserEmail()
        let retrievedPassword = securityManager.getUserPassword()
        
        XCTAssertEqual(retrievedEmail, email)
        XCTAssertEqual(retrievedPassword, password)
        
        // 認証情報の削除をテスト
        securityManager.removeUserCredentials()
        XCTAssertNil(securityManager.getUserEmail())
        XCTAssertNil(securityManager.getUserPassword())
    }
    
    func testDataEncryption() {
        // テスト用データ
        let sensitiveData = "This is sensitive information that should be encrypted"
        
        // 文字列の暗号化と復号化をテスト
        let encryptedString = securityManager.encryptString(sensitiveData)
        XCTAssertNotEqual(encryptedString, sensitiveData)
        
        let decryptedString = securityManager.decryptString(encryptedString)
        XCTAssertEqual(decryptedString, sensitiveData)
        
        // データの暗号化と復号化をテスト
        guard let data = sensitiveData.data(using: .utf8) else {
            XCTFail("データ変換に失敗しました")
            return
        }
        
        let encryptedData = securityManager.encryptData(data)
        XCTAssertNotEqual(encryptedData, data)
        
        let decryptedData = securityManager.decryptData(encryptedData)
        XCTAssertEqual(decryptedData, data)
    }
    
    func testPersonalInfoMasking() {
        // テスト用データ
        let email = "john.doe@example.com"
        let phone = "090-1234-5678"
        let name = "山田 太郎"
        
        // メールアドレスのマスキングをテスト
        let maskedEmail = securityManager.maskPersonalInfo(email, type: .email)
        XCTAssertNotEqual(maskedEmail, email)
        XCTAssertTrue(maskedEmail.contains("@example.com"))
        XCTAssertTrue(maskedEmail.contains("jo"))
        XCTAssertTrue(maskedEmail.contains("*"))
        
        // 電話番号のマスキングをテスト
        let maskedPhone = securityManager.maskPersonalInfo(phone, type: .phone)
        XCTAssertNotEqual(maskedPhone, phone)
        XCTAssertTrue(maskedPhone.contains("5678"))
        XCTAssertTrue(maskedPhone.contains("*"))
        
        // 名前のマスキングをテスト
        let maskedName = securityManager.maskPersonalInfo(name, type: .name)
        XCTAssertNotEqual(maskedName, name)
        XCTAssertTrue(maskedName.contains("山田"))
        XCTAssertTrue(maskedName.contains("*"))
    }
    
    func testSecureAPIHeaders() {
        // 認証トークンなしの場合のヘッダーをテスト
        var headers = securityManager.secureAPIHeaders()
        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertEqual(headers["Accept"], "application/json")
        XCTAssertNil(headers["Authorization"])
        
        // 認証トークンありの場合のヘッダーをテスト
        let authToken = "test_auth_token"
        securityManager.saveAuthToken(token: authToken)
        
        headers = securityManager.secureAPIHeaders()
        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertEqual(headers["Accept"], "application/json")
        XCTAssertEqual(headers["Authorization"], "Bearer \(authToken)")
        
        // デバイス情報が含まれていることを確認
        XCTAssertNotNil(headers["X-Device-ID"])
        XCTAssertNotNil(headers["X-App-Version"])
    }
    
    func testUserPermissions() {
        // テスト用データ
        let userId = "user1"
        
        // 権限チェックをテスト
        let hasViewPermission = securityManager.checkUserPermission(userId: userId, requiredPermission: .viewReports)
        XCTAssertTrue(hasViewPermission)
        
        let hasCreatePermission = securityManager.checkUserPermission(userId: userId, requiredPermission: .createReports)
        XCTAssertTrue(hasCreatePermission)
        
        let hasEditOwnPermission = securityManager.checkUserPermission(userId: userId, requiredPermission: .editOwnReports)
        XCTAssertTrue(hasEditOwnPermission)
        
        let hasEditAllPermission = securityManager.checkUserPermission(userId: userId, requiredPermission: .editAllReports)
        XCTAssertFalse(hasEditAllPermission)
        
        let hasManageSystemPermission = securityManager.checkUserPermission(userId: userId, requiredPermission: .manageSystem)
        XCTAssertFalse(hasManageSystemPermission)
    }
    
    func testSecurityAuditLogging() {
        // テスト用データ
        let userId = "user1"
        let action = "login_attempt"
        let details: [String: Any] = ["ip": "192.168.1.1", "device": "iPhone", "success": true]
        
        // 監査ログ記録をテスト（実際の動作は確認できないが、クラッシュしないことを確認）
        XCTAssertNoThrow(securityManager.logSecurityAudit(action: action, userId: userId, details: details))
    }
    
    func testInputValidation() {
        // メールアドレスのバリデーション
        XCTAssertTrue(isValidEmail("test@example.com"))
        XCTAssertTrue(isValidEmail("user.name+tag@example.co.jp"))
        XCTAssertFalse(isValidEmail("invalid-email"))
        XCTAssertFalse(isValidEmail("test@"))
        XCTAssertFalse(isValidEmail("@example.com"))
        
        // パスワードのバリデーション
        XCTAssertTrue(isValidPassword("Password123!"))
        XCTAssertTrue(isValidPassword("Abcd1234$"))
        XCTAssertFalse(isValidPassword("password")) // 大文字なし、数字なし
        XCTAssertFalse(isValidPassword("12345678")) // 大文字なし、小文字なし
        XCTAssertFalse(isValidPassword("Pass1")) // 8文字未満
        
        // ユーザー名のバリデーション
        XCTAssertTrue(isValidUsername("user123"))
        XCTAssertTrue(isValidUsername("山田太郎"))
        XCTAssertFalse(isValidUsername("a")) // 2文字未満
        XCTAssertFalse(isValidUsername("user name")) // スペースを含む
        
        // SQLインジェクション対策
        XCTAssertTrue(containsSQLInjection("SELECT * FROM users"))
        XCTAssertTrue(containsSQLInjection("1' OR '1'='1"))
        XCTAssertFalse(containsSQLInjection("正常なテキスト"))
        XCTAssertFalse(containsSQLInjection("ユーザー123"))
    }
    
    func testXSSPrevention() {
        // XSS攻撃文字列
        let xssString = "<script>alert('XSS')</script>"
        let htmlString = "<b>Bold text</b>"
        
        // サニタイズ処理をテスト
        let sanitizedXSS = sanitizeHTML(xssString)
        XCTAssertNotEqual(sanitizedXSS, xssString)
        XCTAssertFalse(sanitizedXSS.contains("<script>"))
        
        let sanitizedHTML = sanitizeHTML(htmlString)
        XCTAssertNotEqual(sanitizedHTML, htmlString)
        XCTAssertFalse(sanitizedHTML.contains("<b>"))
    }
    
    // ヘルパーメソッド
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // 8文字以上、大文字小文字数字を含む
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    private func isValidUsername(_ username: String) -> Bool {
        // 2文字以上、スペースなし
        return username.count >= 2 && !username.contains(" ")
    }
    
    private func containsSQLInjection(_ input: String) -> Bool {
        // 簡易的なSQLインジェクションチェック
        let sqlPatterns = ["SELECT", "INSERT", "UPDATE", "DELETE", "DROP", "UNION", "OR '1'='1", "OR 1=1"]
        let uppercaseInput = input.uppercased()
        
        for pattern in sqlPatterns {
            if uppercaseInput.contains(pattern) {
                return true
            }
        }
        
        return false
    }
    
    private func sanitizeHTML(_ input: String) -> String {
        // HTML特殊文字をエスケープ
        var sanitized = input
        let replacements = [
            "<": "&lt;",
            ">": "&gt;",
            "\"": "&quot;",
            "'": "&#39;",
            "&": "&amp;"
        ]
        
        for (key, value) in replacements {
            sanitized = sanitized.replacingOccurrences(of: key, with: value)
        }
        
        return sanitized
    }
}
