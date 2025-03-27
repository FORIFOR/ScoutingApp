import Foundation
import Combine

// 認証サービスプロトコル
protocol AuthenticationServiceProtocol {
    func signUp(email: String, password: String) -> AnyPublisher<User, Error>
    func signIn(email: String, password: String) -> AnyPublisher<User, Error>
    func signOut() -> AnyPublisher<Void, Error>
    func getCurrentUser() -> User?
    func updateUserProfile(user: User) -> AnyPublisher<User, Error>
}

// 認証サービス実装
class AuthenticationService: AuthenticationServiceProtocol {
    // シングルトンインスタンス
    static let shared = AuthenticationService()
    
    // 現在のユーザー
    private var currentUser: User?
    
    // ユーザーの変更を通知するパブリッシャー
    private let userSubject = PassthroughSubject<User?, Never>()
    var userPublisher: AnyPublisher<User?, Never> {
        return userSubject.eraseToAnyPublisher()
    }
    
    private init() {
        // 初期化処理
        // 実際のアプリではKeychain等からユーザー情報を復元
    }
    
    // サインアップ処理
    func signUp(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            // 実際のアプリではFirebase AuthenticationやAWS Cognitoなどを使用
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let user = User(
                    email: email,
                    username: email.components(separatedBy: "@").first ?? "ユーザー",
                    createdAt: Date(),
                    updatedAt: Date()
                )
                self.currentUser = user
                self.userSubject.send(user)
                promise(.success(user))
            }
        }.eraseToAnyPublisher()
    }
    
    // サインイン処理
    func signIn(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            // 実際のアプリではFirebase AuthenticationやAWS Cognitoなどを使用
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let user = User(
                    email: email,
                    username: email.components(separatedBy: "@").first ?? "ユーザー",
                    favoriteClub: "FC東京",
                    region: "関東",
                    createdAt: Date(),
                    updatedAt: Date(),
                    points: 250
                )
                self.currentUser = user
                self.userSubject.send(user)
                promise(.success(user))
            }
        }.eraseToAnyPublisher()
    }
    
    // サインアウト処理
    func signOut() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            // 実際のアプリではFirebase AuthenticationやAWS Cognitoなどを使用
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.currentUser = nil
                self.userSubject.send(nil)
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    // 現在のユーザーを取得
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    // ユーザープロフィールの更新
    func updateUserProfile(user: User) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            // 実際のアプリではAPIを呼び出してプロフィールを更新
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.currentUser = user
                self.userSubject.send(user)
                promise(.success(user))
            }
        }.eraseToAnyPublisher()
    }
}

// 認証エラー
enum AuthenticationError: Error {
    case invalidCredentials
    case networkError
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "メールアドレスまたはパスワードが正しくありません"
        case .networkError:
            return "ネットワークエラーが発生しました"
        case .userNotFound:
            return "ユーザーが見つかりません"
        case .emailAlreadyInUse:
            return "このメールアドレスは既に使用されています"
        case .weakPassword:
            return "パスワードが脆弱です。8文字以上で設定してください"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
}

// 認証状態を管理するビューモデル
class AuthenticationViewModel: ObservableObject {
    // 認証サービス
    private let authService: AuthenticationServiceProtocol
    
    // 購読を保持するためのセット
    private var cancellables = Set<AnyCancellable>()
    
    // 公開プロパティ
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService.shared) {
        self.authService = authService
        
        // 現在のユーザーを取得
        self.currentUser = authService.getCurrentUser()
        self.isAuthenticated = currentUser != nil
        
        // ユーザーの変更を監視
        if let authService = authService as? AuthenticationService {
            authService.userPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] user in
                    self?.currentUser = user
                    self?.isAuthenticated = user != nil
                }
                .store(in: &cancellables)
        }
    }
    
    // サインアップ処理
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        authService.signUp(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] user in
                    self?.currentUser = user
                    self?.isAuthenticated = true
                }
            )
            .store(in: &cancellables)
    }
    
    // サインイン処理
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        authService.signIn(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] user in
                    self?.currentUser = user
                    self?.isAuthenticated = true
                }
            )
            .store(in: &cancellables)
    }
    
    // サインアウト処理
    func signOut() {
        isLoading = true
        errorMessage = nil
        
        authService.signOut()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.currentUser = nil
                    self?.isAuthenticated = false
                }
            )
            .store(in: &cancellables)
    }
    
    // プロフィール更新処理
    func updateProfile(username: String, favoriteClub: String?, region: String?, bio: String?) {
        guard var user = currentUser else { return }
        
        isLoading = true
        errorMessage = nil
        
        user.username = username
        user.favoriteClub = favoriteClub
        user.region = region
        user.bio = bio
        user.updatedAt = Date()
        
        authService.updateUserProfile(user: user)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] updatedUser in
                    self?.currentUser = updatedUser
                }
            )
            .store(in: &cancellables)
    }
}
