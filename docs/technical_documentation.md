# 技術ドキュメント：「ファンがスカウトマンになれる」スポーツビジネスサービス

## 1. システム概要

### 1.1 プロジェクト概要
「ファンがスカウトマンになれる」スポーツビジネスサービスは、サッカークラブのスカウティング活動を効率化し、ファンの参加を促進するプラットフォームです。ファンがスカウティングレポートの作成を支援することで、クラブのスカウト負荷を削減し、より質の高いスカウティングを実現します。

### 1.2 システムアーキテクチャ
本アプリケーションはiOS向けに開発され、以下のアーキテクチャを採用しています：

- **アーキテクチャパターン**: MVVM（Model-View-ViewModel）
- **UI実装**: SwiftUI
- **データバインディング**: Combine
- **バックエンド**: Firebase（Authentication, Firestore, Storage, Cloud Functions）
- **オフラインサポート**: ローカルデータベース（CoreData）

### 1.3 技術スタック
- **言語**: Swift 5.5+
- **最小iOS要件**: iOS 15.0
- **フレームワーク**:
  - SwiftUI
  - Combine
  - CoreData
  - Firebase SDK
  - KeychainAccess
  - CryptoKit

## 2. システム構成

### 2.1 モジュール構成
アプリケーションは以下の主要モジュールで構成されています：

#### 2.1.1 Presentation層
- **Views**: SwiftUIを使用したユーザーインターフェース
- **ViewModels**: ビジネスロジックとUIの橋渡し役
- **UIComponents**: 再利用可能なUIコンポーネント

#### 2.1.2 Domain層
- **Models**: アプリケーションのデータモデル
- **Services**: ビジネスロジックを実装するサービス
- **Repositories**: データアクセスの抽象化

#### 2.1.3 Data層
- **FirebaseManager**: Firebaseとの通信を担当
- **SyncManager**: オンライン/オフラインデータ同期を管理
- **LocalDataManager**: ローカルデータの永続化を担当
- **SecurityManager**: セキュリティ機能を提供

### 2.2 データモデル
主要なデータモデルは以下の通りです：

#### 2.2.1 User
```swift
struct User: Identifiable, Codable {
    var id: String
    var email: String
    var username: String
    var favoriteClub: String?
    var isClubUser: Bool
    var profileImageUrl: String?
    var createdAt: Date
    var updatedAt: Date
}
```

#### 2.2.2 Club
```swift
struct Club: Identifiable, Codable {
    var id: String
    var name: String
    var category: String
    var region: String
    var logoUrl: String?
    var description: String
    var createdAt: Date
    var updatedAt: Date
}
```

#### 2.2.3 Match
```swift
struct Match: Identifiable, Codable {
    var id: String
    var homeTeamId: String
    var awayTeamId: String
    var date: Date
    var venue: String
    var category: String
    var status: MatchStatus
    var createdAt: Date
    var updatedAt: Date
}

enum MatchStatus: String, Codable {
    case scheduled
    case inProgress
    case completed
    case cancelled
}
```

#### 2.2.4 Player
```swift
struct Player: Identifiable, Codable {
    var id: String
    var name: String
    var teamId: String
    var position: String
    var jerseyNumber: Int
    var dateOfBirth: Date?
    var height: Int?
    var weight: Int?
    var profileImageUrl: String?
    var createdAt: Date
    var updatedAt: Date
}
```

#### 2.2.5 ScoutingReport
```swift
struct ScoutingReport: Identifiable, Codable {
    var id: String
    var userId: String
    var clubId: String
    var playerId: String
    var matchId: String
    var templateId: String
    var status: ReportStatus
    var evaluations: [Evaluation]
    var overallComment: String
    var mediaUrls: [String]
    var likes: Int
    var feedback: String?
    var pointsAwarded: Int
    var createdAt: Date
    var updatedAt: Date
}

enum ReportStatus: String, Codable {
    case draft
    case submitted
    case reviewed
    case rejected
}

struct Evaluation: Identifiable, Codable {
    var id: String
    var itemId: String
    var rating: Int
    var comment: String
}
```

#### 2.2.6 ReportTemplate
```swift
struct ReportTemplate: Identifiable, Codable {
    var id: String
    var clubId: String
    var name: String
    var description: String
    var evaluationItems: [EvaluationItem]
    var createdAt: Date
    var updatedAt: Date
}

struct EvaluationItem: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var category: String
}
```

#### 2.2.7 PointHistory
```swift
struct PointHistory: Identifiable, Codable {
    var id: String
    var userId: String
    var amount: Int
    var type: PointType
    var description: String
    var relatedId: String?
    var createdAt: Date
}

enum PointType: String, Codable {
    case earned
    case redeemed
    case bonus
}
```

#### 2.2.8 RewardItem
```swift
struct RewardItem: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var pointCost: Int
    var category: RewardCategory
    var imageUrl: String?
    var createdAt: Date
    var updatedAt: Date
}

enum RewardCategory: String, Codable {
    case ticket
    case goods
    case experience
    case other
}
```

## 3. 主要機能の実装

### 3.1 認証システム
認証システムはFirebase Authenticationを使用して実装されています。

#### 3.1.1 AuthenticationService
```swift
class AuthenticationService {
    private let firebaseManager: FirebaseManagerProtocol
    
    init(firebaseManager: FirebaseManagerProtocol = FirebaseManager.shared) {
        self.firebaseManager = firebaseManager
    }
    
    func signUp(email: String, password: String) -> AnyPublisher<User, Error> {
        return firebaseManager.registerUser(email: email, password: password)
    }
    
    func signIn(email: String, password: String) -> AnyPublisher<User, Error> {
        return firebaseManager.loginUser(email: email, password: password)
    }
    
    func signOut() -> AnyPublisher<Void, Error> {
        return firebaseManager.logoutUser()
    }
}
```

#### 3.1.2 AuthenticationViewModel
```swift
class AuthenticationViewModel: ObservableObject {
    private let authService: AuthenticationService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(authService: AuthenticationService = AuthenticationService()) {
        self.authService = authService
        checkAuthenticationState()
    }
    
    func signUp(email: String, password: String, username: String) {
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
    
    private func checkAuthenticationState() {
        // Firebase Auth状態監視
    }
}
```

### 3.2 試合スケジュール管理
試合スケジュール管理機能はFirestoreからデータを取得し、フィルタリングや表示を行います。

#### 3.2.1 ScheduleService
```swift
class ScheduleService {
    private let firebaseManager: FirebaseManagerProtocol
    
    init(firebaseManager: FirebaseManagerProtocol = FirebaseManager.shared) {
        self.firebaseManager = firebaseManager
    }
    
    func getMatches(region: String? = nil, date: DateFilter? = nil, category: String? = nil) -> AnyPublisher<[Match], Error> {
        return firebaseManager.getMatches(region: region, date: date, category: category)
    }
    
    func getMatch(matchId: String) -> AnyPublisher<Match, Error> {
        return firebaseManager.getMatch(matchId: matchId)
    }
}
```

#### 3.2.2 ScheduleViewModel
```swift
class ScheduleViewModel: ObservableObject {
    private let scheduleService: ScheduleService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var matches: [Match] = []
    @Published var filteredMatches: [Match] = []
    @Published var selectedMatch: Match?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // フィルター状態
    @Published var selectedRegion: String?
    @Published var selectedDate: DateFilter?
    @Published var selectedCategory: String?
    
    init(scheduleService: ScheduleService = ScheduleService()) {
        self.scheduleService = scheduleService
        loadMatches()
    }
    
    func loadMatches() {
        isLoading = true
        errorMessage = nil
        
        scheduleService.getMatches(region: selectedRegion, date: selectedDate, category: selectedCategory)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] matches in
                    self?.matches = matches
                    self?.filteredMatches = matches
                }
            )
            .store(in: &cancellables)
    }
    
    func loadMatchDetails(matchId: String) {
        isLoading = true
        errorMessage = nil
        
        scheduleService.getMatch(matchId: matchId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] match in
                    self?.selectedMatch = match
                }
            )
            .store(in: &cancellables)
    }
    
    func applyFilters(region: String?, date: DateFilter?, category: String?) {
        selectedRegion = region
        selectedDate = date
        selectedCategory = category
        loadMatches()
    }
}
```

### 3.3 スカウティングレポート機能
スカウティングレポート機能は、レポートの作成、編集、提出、評価を管理します。

#### 3.3.1 ReportService
```swift
class ReportService {
    private let firebaseManager: FirebaseManagerProtocol
    
    init(firebaseManager: FirebaseManagerProtocol = FirebaseManager.shared) {
        self.firebaseManager = firebaseManager
    }
    
    func getReportTemplates(clubId: String) -> AnyPublisher<[ReportTemplate], Error> {
        return firebaseManager.getReportTemplates(clubId: clubId)
    }
    
    func createReport(report: ScoutingReport) -> AnyPublisher<ScoutingReport, Error> {
        return firebaseManager.createReport(report: report)
    }
    
    func updateReport(report: ScoutingReport, newStatus: ReportStatus? = nil) -> AnyPublisher<ScoutingReport, Error> {
        var updatedReport = report
        if let newStatus = newStatus {
            updatedReport.status = newStatus
        }
        return firebaseManager.updateReport(report: updatedReport)
    }
    
    func getUserReports(userId: String, status: ReportStatus? = nil) -> AnyPublisher<[ScoutingReport], Error> {
        return firebaseManager.getReportsByUser(userId: userId, status: status)
    }
    
    func getClubReports(clubId: String) -> AnyPublisher<[ScoutingReport], Error> {
        return firebaseManager.getReportsByClub(clubId: clubId)
    }
    
    func likeReport(reportId: String, clubId: String) -> AnyPublisher<ScoutingReport, Error> {
        return firebaseManager.likeReport(reportId: reportId, clubId: clubId)
    }
    
    func addFeedback(reportId: String, feedback: String, pointsAwarded: Int) -> AnyPublisher<ScoutingReport, Error> {
        return firebaseManager.addFeedback(reportId: reportId, feedback: feedback, pointsAwarded: pointsAwarded)
    }
}
```

#### 3.3.2 ReportViewModel
```swift
class ReportViewModel: ObservableObject {
    private let reportService: ReportService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var userReports: [ScoutingReport] = []
    @Published var clubReports: [ScoutingReport] = []
    @Published var currentReport: ScoutingReport?
    @Published var reportTemplates: [ReportTemplate] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(reportService: ReportService = ReportService()) {
        self.reportService = reportService
    }
    
    func loadUserReports(userId: String, status: ReportStatus? = nil) {
        isLoading = true
        errorMessage = nil
        
        reportService.getUserReports(userId: userId, status: status)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] reports in
                    self?.userReports = reports
                }
            )
            .store(in: &cancellables)
    }
    
    func loadClubReports(clubId: String) {
        isLoading = true
        errorMessage = nil
        
        reportService.getClubReports(clubId: clubId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] reports in
                    self?.clubReports = reports
                }
            )
            .store(in: &cancellables)
    }
    
    func createNewReport(userId: String, clubId: String, playerId: String, matchId: String, templateId: String) {
        let newReport = ScoutingReport(
            id: "",
            userId: userId,
            clubId: clubId,
            playerId: playerId,
            matchId: matchId,
            templateId: templateId,
            status: .draft,
            evaluations: [],
            overallComment: "",
            mediaUrls: [],
            likes: 0,
            feedback: nil,
            pointsAwarded: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        isLoading = true
        errorMessage = nil
        
        reportService.createReport(report: newReport)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] report in
                    self?.currentReport = report
                }
            )
            .store(in: &cancellables)
    }
    
    func submitReport(report: ScoutingReport) {
        isLoading = true
        errorMessage = nil
        
        reportService.updateReport(report: report, newStatus: .submitted)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] report in
                    self?.currentReport = report
                    if let index = self?.userReports.firstIndex(where: { $0.id == report.id }) {
                        self?.userReports[index] = report
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func likeReport(reportId: String, clubId: String) {
        isLoading = true
        errorMessage = nil
        
        reportService.likeReport(reportId: reportId, clubId: clubId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] report in
                    if let index = self?.clubReports.firstIndex(where: { $0.id == report.id }) {
                        self?.clubReports[index] = report
                    }
                    if self?.currentReport?.id == report.id {
                        self?.currentReport = report
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func addFeedback(reportId: String, feedback: String, pointsAwarded: Int) {
        isLoading = true
        errorMessage = nil
        
        reportService.addFeedback(reportId: reportId, feedback: feedback, pointsAwarded: pointsAwarded)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] report in
                    if let index = self?.clubReports.firstIndex(where: { $0.id == report.id }) {
                        self?.clubReports[index] = report
                    }
                    if self?.currentReport?.id == report.id {
                        self?.currentReport = report
                    }
                }
            )
            .store(in: &cancellables)
    }
}
```

### 3.4 報酬システム
報酬システムはポイント管理と報酬交換を担当します。

#### 3.4.1 RewardService
```swift
class RewardService {
    private let firebaseManager: FirebaseManagerProtocol
    
    init(firebaseManager: FirebaseManagerProtocol = FirebaseManager.shared) {
        self.firebaseManager = firebaseManager
    }
    
    func getUserPoints(userId: String) -> AnyPublisher<Int, Error> {
        return firebaseManager.getUserPoints(userId: userId)
    }
    
    func getPointHistory(userId: String) -> AnyPublisher<[PointHistory], Error> {
        return firebaseManager.getPointHistory(userId: userId)
    }
    
    func getRewardItems() -> AnyPublisher<[RewardItem], Error> {
        return firebaseManager.getRewardItems()
    }
    
    func redeemReward(userId: String, rewardId: String) -> AnyPublisher<RewardRedemption, Error> {
        return firebaseManager.redeemReward(userId: userId, rewardId: rewardId)
    }
}
```

#### 3.4.2 RewardViewModel
```swift
class RewardViewModel: ObservableObject {
    private let rewardService: RewardService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var userPoints: Int = 0
    @Published var pointHistory: [PointHistory] = []
    @Published var rewardItems: [RewardItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(rewardService: RewardService = RewardService()) {
        self.rewardService = rewardService
    }
    
    func loadUserPoints(userId: String) {
        isLoading = true
        errorMessage = nil
        
        rewardService.getUserPoints(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] points in
                    self?.userPoints = points
                }
            )
            .store(in: &cancellables)
    }
    
    func loadPointHistory(userId: String) {
        isLoading = true
        errorMessage = nil
        
        rewardService.getPointHistory(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] history in
                    self?.pointHistory = history
                }
            )
            .store(in: &cancellables)
    }
    
    func loadRewardItems() {
        isLoading = true
        errorMessage = nil
        
        rewardService.getRewardItems()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] items in
                    self?.rewardItems = items
                }
            )
            .store(in: &cancellables)
    }
    
    func redeemReward(userId: String, rewardId: String) {
        isLoading = true
        errorMessage = nil
        
        rewardService.redeemReward(userId: userId, rewardId: rewardId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.loadUserPoints(userId: userId)
                    self?.loadPointHistory(userId: userId)
                }
            )
            .store(in: &cancellables)
    }
}
```

### 3.5 データ同期メカニズム
データ同期メカニズムはオンライン/オフラインの状態を管理し、データの同期を行います。

#### 3.5.1 SyncManager
```swift
class SyncManager {
    private let firebaseManager: FirebaseManagerProtocol
    private let localDataManager: LocalDataManager
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: Error?
    
    init(firebaseManager: FirebaseManagerProtocol = FirebaseManager.shared, localDataManager: LocalDataManager = LocalDataManager.shared) {
        self.firebaseManager = firebaseManager
        self.localDataManager = localDataManager
    }
    
    func syncAllData(userId: String) -> AnyPublisher<Void, Error> {
        isSyncing = true
        syncError = nil
        
        let userPublisher = firebaseManager.getUser(userId: userId)
        let matchesPublisher = firebaseManager.getMatches()
        let reportsPublisher = firebaseManager.getReportsByUser(userId: userId)
        let pointHistoryPublisher = firebaseManager.getPointHistory(userId: userId)
        let rewardItemsPublisher = firebaseManager.getRewardItems()
        
        return Publishers.Zip5(
            userPublisher,
            matchesPublisher,
            reportsPublisher,
            pointHistoryPublisher,
            rewardItemsPublisher
        )
        .map { user, matches, reports, pointHistory, rewardItems in
            // ローカルデータベースに保存
            self.localDataManager.saveUser(user)
            self.localDataManager.saveMatches(matches)
            self.localDataManager.saveReports(reports)
            self.localDataManager.savePointHistory(pointHistory)
            self.localDataManager.saveRewardItems(rewardItems)
            
            self.lastSyncDate = Date()
            self.isSyncing = false
            return ()
        }
        .catch { error in
            self.syncError = error
            self.isSyncing = false
            return Fail(error: error).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    func syncOfflineReports(userId: String) -> AnyPublisher<Void, Error> {
        let unsyncedReports = localDataManager.getUnsyncedReports()
        
        if unsyncedReports.isEmpty {
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        isSyncing = true
        syncError = nil
        
        let publishers = unsyncedReports.map { report in
            return firebaseManager.createReport(report: report)
        }
        
        return Publishers.MergeMany(publishers)
            .collect()
            .map { _ in
                self.localDataManager.markReportsAsSynced(reports: unsyncedReports)
                self.isSyncing = false
                return ()
            }
            .catch { error in
                self.syncError = error
                self.isSyncing = false
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
```

### 3.6 セキュリティ機能
セキュリティ機能はデータの暗号化、認証トークン管理、アクセス制御を担当します。

#### 3.6.1 SecurityManager
```swift
class SecurityManager {
    static let shared = SecurityManager()
    
    private let keychain = Keychain(service: "com.scoutingapp.security")
    
    private init() {}
    
    // 認証トークン管理
    func saveAuthToken(token: String) {
        do {
            try keychain.set(token, key: "authToken")
        } catch {
            print("認証トークン保存エラー: \(error.localizedDescription)")
        }
    }
    
    func getAuthToken() -> String? {
        do {
            return try keychain.get("authToken")
        } catch {
            print("認証トークン取得エラー: \(error.localizedDescription)")
            return nil
        }
    }
    
    func removeAuthToken() {
        do {
            try keychain.remove("authToken")
        } catch {
            print("認証トークン削除エラー: \(error.localizedDescription)")
        }
    }
    
    // データ暗号化
    func encryptString(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else {
            return string
        }
        
        let encryptedData = encryptData(data)
        return encryptedData.base64EncodedString()
    }
    
    func decryptString(_ string: String) -> String {
        guard let data = Data(base64Encoded: string) else {
            return string
        }
        
        let decryptedData = decryptData(data)
        return String(data: decryptedData, encoding: .utf8) ?? string
    }
    
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
    
    private func getEncryptionKey() throws -> SymmetricKey {
        if let keyData = try? keychain.getData("encryptionKey") {
            return SymmetricKey(data: keyData)
        }
        
        let key = SymmetricKey(size: .bits256)
        let keyData = key.withUnsafeBytes { Data($0) }
        
        do {
            try keychain.set(keyData, key: "encryptionKey")
            return key
        } catch {
            throw error
        }
    }
}
```

## 4. データベース設計

### 4.1 Firestore構造
Firestoreデータベースは以下のコレクション構造で設計されています：

```
/users/{userId}
    - email: string
    - username: string
    - favoriteClub: string (optional)
    - isClubUser: boolean
    - profileImageUrl: string (optional)
    - createdAt: timestamp
    - updatedAt: timestamp

/clubs/{clubId}
    - name: string
    - category: string
    - region: string
    - logoUrl: string (optional)
    - description: string
    - createdAt: timestamp
    - updatedAt: timestamp

/matches/{matchId}
    - homeTeamId: string
    - awayTeamId: string
    - date: timestamp
    - venue: string
    - category: string
    - status: string (scheduled, inProgress, completed, cancelled)
    - createdAt: timestamp
    - updatedAt: timestamp

/players/{playerId}
    - name: string
    - teamId: string
    - position: string
    - jerseyNumber: number
    - dateOfBirth: timestamp (optional)
    - height: number (optional)
    - weight: number (optional)
    - profileImageUrl: string (optional)
    - createdAt: timestamp
    - updatedAt: timestamp

/reports/{reportId}
    - userId: string
    - clubId: string
    - playerId: string
    - matchId: string
    - templateId: string
    - status: string (draft, submitted, reviewed, rejected)
    - evaluations: array
        - id: string
        - itemId: string
        - rating: number
        - comment: string
    - overallComment: string
    - mediaUrls: array<string>
    - likes: number
    - feedback: string (optional)
    - pointsAwarded: number
    - createdAt: timestamp
    - updatedAt: timestamp

/reportTemplates/{templateId}
    - clubId: string
    - name: string
    - description: string
    - evaluationItems: array
        - id: string
        - name: string
        - description: string
        - category: string
    - createdAt: timestamp
    - updatedAt: timestamp

/pointHistory/{historyId}
    - userId: string
    - amount: number
    - type: string (earned, redeemed, bonus)
    - description: string
    - relatedId: string (optional)
    - createdAt: timestamp

/rewardItems/{itemId}
    - name: string
    - description: string
    - pointCost: number
    - category: string (ticket, goods, experience, other)
    - imageUrl: string (optional)
    - createdAt: timestamp
    - updatedAt: timestamp

/rewardRedemptions/{redemptionId}
    - userId: string
    - rewardId: string
    - status: string (pending, completed, cancelled)
    - createdAt: timestamp
    - updatedAt: timestamp
```

### 4.2 Firebase Storage構造
Firebase Storageは以下の構造で設計されています：

```
/profiles/{userId}/{filename}  // プロフィール画像
/reports/{reportId}/{filename}  // レポート添付画像
/clubs/{clubId}/{filename}  // クラブロゴ画像
/players/{playerId}/{filename}  // 選手プロフィール画像
/rewards/{rewardId}/{filename}  // 報酬アイテム画像
```

## 5. セキュリティ対策

### 5.1 認証とアクセス制御
- Firebase Authenticationによるユーザー認証
- Firestoreセキュリティルールによるデータアクセス制御
- ユーザーロールに基づいた権限管理

### 5.2 データ保護
- AES-GCMアルゴリズムによるデータ暗号化
- キーチェーンを使用した認証情報の安全な保管
- 個人情報のマスキング処理

### 5.3 通信セキュリティ
- HTTPS通信の強制
- トークンベースの認証ヘッダー
- デバイス情報の検証

### 5.4 入力検証
- メールアドレス、パスワードのバリデーション
- SQLインジェクション対策
- XSS対策

## 6. テスト戦略

### 6.1 ユニットテスト
各コンポーネントの個別機能をテストします：
- 認証機能
- レポート機能
- 同期機能

### 6.2 統合テスト
複数のコンポーネントを組み合わせた機能をテストします：
- ユーザー認証からレポート作成、同期までのフロー
- レポート提出からフィードバック追加までのフロー
- オフラインレポート作成から同期までのフロー

### 6.3 UIテスト
ユーザーインターフェースの動作をテストします：
- 画面遷移
- ユーザー操作
- 表示内容

### 6.4 パフォーマンステスト
アプリケーションのパフォーマンスをテストします：
- 大量データ処理時の応答速度
- メモリ使用量
- 画像処理やデータ同期の負荷

### 6.5 セキュリティテスト
セキュリティ機能をテストします：
- データ暗号化
- 認証トークン管理
- 入力バリデーション
- アクセス制御

### 6.6 ユーザビリティテスト
ユーザー体験をテストします：
- 各画面の使いやすさ
- アクセシビリティ
- 操作フロー

## 7. 今後の拡張計画

### 7.1 機能拡張
- AIを活用した選手分析機能
- ビデオ分析機能
- チーム間のスカウト情報共有機能
- 選手成長追跡機能

### 7.2 プラットフォーム拡張
- Android版の開発
- Webアプリケーション版の開発
- タブレット最適化版の開発

### 7.3 ビジネスモデル拡張
- プレミアム機能の導入
- クラブ向け有料プラン
- スカウト育成プログラムの提供

## 8. 参考資料

### 8.1 使用ライブラリ
- Firebase SDK: https://firebase.google.com/docs/ios/setup
- KeychainAccess: https://github.com/kishikawakatsumi/KeychainAccess
- CryptoKit: https://developer.apple.com/documentation/cryptokit

### 8.2 開発リソース
- Apple Developer Documentation: https://developer.apple.com/documentation/
- SwiftUI Documentation: https://developer.apple.com/documentation/swiftui/
- Combine Documentation: https://developer.apple.com/documentation/combine
