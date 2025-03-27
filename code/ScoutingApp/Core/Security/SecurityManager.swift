import Foundation
import CryptoKit
import KeychainAccess
import Firebase
import FirebaseAuth

// セキュリティマネージャー
class SecurityManager {
    // シングルトンインスタンス
    static let shared = SecurityManager()
    
    // Keychainアクセス
    private let keychain = Keychain(service: "com.scoutingapp.security")
    
    // 初期化
    private init() {
        // 初期化処理
    }
    
    // MARK: - 認証トークン管理
    
    // 認証トークンを保存
    func saveAuthToken(token: String) {
        do {
            try keychain.set(token, key: "authToken")
        } catch {
            print("認証トークン保存エラー: \(error.localizedDescription)")
        }
    }
    
    // 認証トークンを取得
    func getAuthToken() -> String? {
        do {
            return try keychain.get("authToken")
        } catch {
            print("認証トークン取得エラー: \(error.localizedDescription)")
            return nil
        }
    }
    
    // 認証トークンを削除
    func removeAuthToken() {
        do {
            try keychain.remove("authToken")
        } catch {
            print("認証トークン削除エラー: \(error.localizedDescription)")
        }
    }
    
    // MARK: - リフレッシュトークン管理
    
    // リフレッシュトークンを保存
    func saveRefreshToken(token: String) {
        do {
            try keychain.set(token, key: "refreshToken")
        } catch {
            print("リフレッシュトークン保存エラー: \(error.localizedDescription)")
        }
    }
    
    // リフレッシュトークンを取得
    func getRefreshToken() -> String? {
        do {
            return try keychain.get("refreshToken")
        } catch {
            print("リフレッシュトークン取得エラー: \(error.localizedDescription)")
            return nil
        }
    }
    
    // リフレッシュトークンを削除
    func removeRefreshToken() {
        do {
            try keychain.remove("refreshToken")
        } catch {
            print("リフレッシュトークン削除エラー: \(error.localizedDescription)")
        }
    }
    
    // MARK: - ユーザー認証情報管理
    
    // ユーザー認証情報を保存
    func saveUserCredentials(email: String, password: String) {
        do {
            try keychain.set(email, key: "userEmail")
            
            // パスワードは暗号化して保存
            let encryptedPassword = encryptString(password)
            try keychain.set(encryptedPassword, key: "userPassword")
        } catch {
            print("ユーザー認証情報保存エラー: \(error.localizedDescription)")
        }
    }
    
    // ユーザーメールアドレスを取得
    func getUserEmail() -> String? {
        do {
            return try keychain.get("userEmail")
        } catch {
            print("ユーザーメールアドレス取得エラー: \(error.localizedDescription)")
            return nil
        }
    }
    
    // ユーザーパスワードを取得
    func getUserPassword() -> String? {
        do {
            guard let encryptedPassword = try keychain.get("userPassword") else {
                return nil
            }
            
            return decryptString(encryptedPassword)
        } catch {
            print("ユーザーパスワード取得エラー: \(error.localizedDescription)")
            return nil
        }
    }
    
    // ユーザー認証情報を削除
    func removeUserCredentials() {
        do {
            try keychain.remove("userEmail")
            try keychain.remove("userPassword")
        } catch {
            print("ユーザー認証情報削除エラー: \(error.localizedDescription)")
        }
    }
    
    // MARK: - データ暗号化
    
    // 文字列を暗号化
    func encryptString(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else {
            return string
        }
        
        let encryptedData = encryptData(data)
        return encryptedData.base64EncodedString()
    }
    
    // 文字列を復号化
    func decryptString(_ string: String) -> String {
        guard let data = Data(base64Encoded: string) else {
            return string
        }
        
        let decryptedData = decryptData(data)
        return String(data: decryptedData, encoding: .utf8) ?? string
    }
    
    // データを暗号化
    func encryptData(_ data: Data) -> Data {
        do {
            let key = try getEncryptionKey()
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined ?? data
        } catch {
            print("データ暗号化エラー: \(error.localizedDescription)")
            return data
        }
    }
    
    // データを復号化
    func decryptData(_ data: Data) -> Data {
        do {
            let key = try getEncryptionKey()
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            print("データ復号化エラー: \(error.localizedDescription)")
            return data
        }
    }
    
    // 暗号化キーを取得
    private func getEncryptionKey() throws -> SymmetricKey {
        // キーチェーンからキーを取得
        if let keyData = try? keychain.getData("encryptionKey") {
            return SymmetricKey(data: keyData)
        }
        
        // キーが存在しない場合は新しく生成
        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }
        
        do {
            try keychain.set(keyData, key: "encryptionKey")
            return key
        } catch {
            throw error
        }
    }
    
    // MARK: - セキュアなAPI通信
    
    // APIリクエストヘッダーにセキュリティ情報を追加
    func secureAPIHeaders() -> [String: String] {
        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        // 認証トークンがあれば追加
        if let token = getAuthToken() {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        // デバイス情報を追加
        headers["X-Device-ID"] = UIDevice.current.identifierForVendor?.uuidString ?? ""
        headers["X-App-Version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        
        return headers
    }
    
    // MARK: - 個人情報保護
    
    // 個人情報をマスク
    func maskPersonalInfo(_ info: String, type: PersonalInfoType) -> String {
        switch type {
        case .email:
            // メールアドレスをマスク（例: ab***@example.com）
            let components = info.components(separatedBy: "@")
            if components.count == 2 {
                let name = components[0]
                let domain = components[1]
                
                if name.count > 2 {
                    let visiblePart = name.prefix(2)
                    let maskedPart = String(repeating: "*", count: name.count - 2)
                    return "\(visiblePart)\(maskedPart)@\(domain)"
                }
            }
            return info
            
        case .phone:
            // 電話番号をマスク（例: 090-****-1234）
            let digits = info.filter { $0.isNumber }
            if digits.count >= 4 {
                let lastFour = String(digits.suffix(4))
                let maskedPart = String(repeating: "*", count: digits.count - 4)
                return "\(maskedPart)\(lastFour)"
            }
            return info
            
        case .name:
            // 名前をマスク（例: 山田 ****）
            let components = info.components(separatedBy: " ")
            if components.count >= 2 {
                let firstName = components[0]
                let maskedLastName = String(repeating: "*", count: components[1].count)
                return "\(firstName) \(maskedLastName)"
            }
            return info
        }
    }
    
    // MARK: - アクセス制御
    
    // ユーザーの権限を確認
    func checkUserPermission(userId: String, requiredPermission: Permission) -> Bool {
        // 実際のアプリでは、Firestoreからユーザーの権限を取得して確認
        // ここではモックデータを返す
        let userPermissions: [Permission] = [.viewReports, .createReports, .editOwnReports]
        return userPermissions.contains(requiredPermission)
    }
    
    // クラブユーザーかどうかを確認
    func isClubUser(userId: String) -> Bool {
        // 実際のアプリでは、Firestoreからユーザー情報を取得して確認
        // ここではモックデータを返す
        return false
    }
    
    // MARK: - セキュリティ監査
    
    // セキュリティ監査ログを記録
    func logSecurityAudit(action: String, userId: String, details: [String: Any]? = nil) {
        let timestamp = Date()
        let deviceInfo = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        
        let auditLog: [String: Any] = [
            "action": action,
            "userId": userId,
            "timestamp": timestamp,
            "deviceInfo": deviceInfo,
            "details": details ?? [:]
        ]
        
        // 実際のアプリでは、Firestoreに監査ログを保存
        print("セキュリティ監査ログ: \(auditLog)")
    }
    
    // MARK: - バイオメトリック認証
    
    // バイオメトリック認証が利用可能かどうかを確認
    func isBiometricAuthAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    // バイオメトリック認証を実行
    func authenticateWithBiometrics(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        let reason = "アプリへのアクセスを確認します"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
}

// 個人情報の種類
enum PersonalInfoType {
    case email
    case phone
    case name
}

// ユーザー権限
enum Permission {
    case viewReports
    case createReports
    case editOwnReports
    case editAllReports
    case manageUsers
    case manageClubs
    case manageSystem
}

// セキュリティエラー
enum SecurityError: Error {
    case authenticationFailed
    case tokenExpired
    case encryptionFailed
    case decryptionFailed
    case permissionDenied
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .authenticationFailed:
            return "認証に失敗しました"
        case .tokenExpired:
            return "認証トークンの有効期限が切れています"
        case .encryptionFailed:
            return "暗号化に失敗しました"
        case .decryptionFailed:
            return "復号化に失敗しました"
        case .permissionDenied:
            return "権限がありません"
        case .unknown:
            return "不明なセキュリティエラーが発生しました"
        }
    }
}

// MARK: - セキュリティ拡張

// Firebaseセキュリティルール
/*
// Firestoreセキュリティルール
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // ユーザー認証が必要
    match /{document=**} {
      allow read, write: if false;
    }
    
    // ユーザーコレクション
    match /users/{userId} {
      // 自分のデータのみ読み取り可能
      allow read: if request.auth != null && request.auth.uid == userId;
      // 自分のデータのみ更新可能
      allow update: if request.auth != null && request.auth.uid == userId;
      // 新規作成は認証済みユーザーのみ
      allow create: if request.auth != null;
    }
    
    // クラブコレクション
    match /clubs/{clubId} {
      // 読み取りは認証済みユーザーのみ
      allow read: if request.auth != null;
      // 更新はクラブ管理者のみ
      allow write: if request.auth != null && exists(/databases/$(database)/documents/users/$(request.auth.uid)) && 
                    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isClubUser == true;
    }
    
    // 試合コレクション
    match /matches/{matchId} {
      // 読み取りは認証済みユーザーのみ
      allow read: if request.auth != null;
      // 更新はクラブ管理者のみ
      allow write: if request.auth != null && exists(/databases/$(database)/documents/users/$(request.auth.uid)) && 
                    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isClubUser == true;
    }
    
    // レポートコレクション
    match /reports/{reportId} {
      // 読み取り条件
      allow read: if request.auth != null && (
                    // 自分が作成したレポート
                    resource.data.userId == request.auth.uid ||
                    // または自分のクラブ宛のレポート
                    (exists(/databases/$(database)/documents/users/$(request.auth.uid)) && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isClubUser == true && 
                     resource.data.clubId == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.favoriteClub)
                  );
      
      // 作成条件
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      
      // 更新条件
      allow update: if request.auth != null && (
                      // 自分が作成したレポートで、ステータスが下書きまたは提出済み
                      (resource.data.userId == request.auth.uid && 
                       (resource.data.status == "draft" || resource.data.status == "submitted")) ||
                      // または自分のクラブ宛のレポートで、いいねやフィードバックを更新
                      (exists(/databases/$(database)/documents/users/$(request.auth.uid)) && 
                       get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isClubUser == true && 
                       resource.data.clubId == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.favoriteClub)
                    );
    }
    
    // ポイント履歴コレクション
    match /pointHistory/{historyId} {
      // 自分の履歴のみ読み取り可能
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      // 作成はシステムのみ（クライアントからは不可）
      allow write: if false;
    }
    
    // 報酬アイテムコレクション
    match /rewardItems/{itemId} {
      // 読み取りは認証済みユーザーのみ
      allow read: if request.auth != null;
      // 更新はシステム管理者のみ（クライアントからは不可）
      allow write: if false;
    }
  }
}

// Storageセキュリティルール
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // デフォルトで拒否
    match /{allPaths=**} {
      allow read, write: if false;
    }
    
    // プロフィール画像
    match /profiles/{userId}/{fileName} {
      // 自分の画像のみ読み書き可能
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // レポート添付画像
    match /reports/{reportId}/{fileName} {
      // 読み取り条件
      allow read: if request.auth != null && (
                    // レポート作成者
                    exists(/databases/$(database)/documents/reports/$(reportId)) && 
                    get(/databases/$(database)/documents/reports/$(reportId)).data.userId == request.auth.uid ||
                    // またはレポート宛先クラブのユーザー
                    (exists(/databases/$(database)/documents/reports/$(reportId)) && 
                     exists(/databases/$(database)/documents/users/$(request.auth.uid)) && 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isClubUser == true && 
                     get(/databases/$(database)/documents/reports/$(reportId)).data.clubId == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.favoriteClub)
                  );
      
      // アップロード条件
      allow write: if request.auth != null && 
                    exists(/databases/$(database)/documents/reports/$(reportId)) && 
                    get(/databases/$(database)/documents/reports/$(reportId)).data.userId == request.auth.uid;
    }
  }
}
*/

// MARK: - UIKit拡張

import UIKit
import LocalAuthentication

// UIApplicationの拡張
extension UIApplication {
    // 現在のUIWindowを取得
    var currentWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }
}

// セキュリティ関連のUIViewController拡張
extension UIViewController {
    // バイオメトリック認証を表示
    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        SecurityManager.shared.authenticateWithBiometrics { success, error in
            if success {
                completion(true)
            } else {
                if let error = error as? LAError {
                    switch error.code {
                    case .userCancel, .userFallback, .systemCancel:
                        // ユーザーがキャンセルした場合は何もしない
                        break
                    default:
                        // その他のエラーの場合はアラートを表示
                        self.showAlert(title: "認証エラー", message: error.localizedDescription)
                    }
                }
                completion(false)
            }
        }
    }
    
    // アラートを表示
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - SwiftUI拡張

import SwiftUI

// セキュリティ関連のView拡張
extension View {
    // バイオメトリック認証を表示
    func biometricAuthentication(isAuthenticated: Binding<Bool>) -> some View {
        self.onAppear {
            if !isAuthenticated.wrappedValue {
                SecurityManager.shared.authenticateWithBiometrics { success, _ in
                    isAuthenticated.wrappedValue = success
                }
            }
        }
    }
    
    // セキュアモード（スクリーンショット防止）
    func secureMode() -> some View {
        self.onAppear {
            // スクリーンショット検出の通知を登録
            NotificationCenter.default.addObserver(forName: UIApplication.userDidTakeScreenshotNotification, object: nil, queue: .main) { _ in
                // スクリーンショットが撮影された場合の処理
                print("スクリーンショットが検出されました")
                // 必要に応じてセキュリティ監査ログを記録
                if let userId = SecurityManager.shared.getUserEmail() {
                    SecurityManager.shared.logSecurityAudit(action: "screenshot_detected", userId: userId)
                }
            }
        }
    }
}
