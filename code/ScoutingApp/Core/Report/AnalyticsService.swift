import Foundation
import Combine

// 分析・統計サービスプロトコル
protocol AnalyticsServiceProtocol {
    func getUserStats(userId: String) -> AnyPublisher<UserStats, Error>
    func getClubStats(clubId: String) -> AnyPublisher<ClubStats, Error>
    func getLeaderboard() -> AnyPublisher<[LeaderboardEntry], Error>
    func getPlayerAnalytics(playerId: String) -> AnyPublisher<PlayerAnalytics, Error>
    func getSystemStats() -> AnyPublisher<SystemStats, Error>
}

// ユーザー統計モデル
struct UserStats: Codable {
    var userId: String
    var totalReports: Int
    var submittedReports: Int
    var reviewedReports: Int
    var averageLikes: Double
    var totalPoints: Int
    var totalRedeemed: Int
    var reportsByMonth: [MonthlyReportCount]
    var pointsByMonth: [MonthlyPointCount]
    var topRatedReports: [ScoutingReport]
    
    struct MonthlyReportCount: Codable, Identifiable {
        var id: String { "\(year)-\(month)" }
        var year: Int
        var month: Int
        var count: Int
    }
    
    struct MonthlyPointCount: Codable, Identifiable {
        var id: String { "\(year)-\(month)" }
        var year: Int
        var month: Int
        var earned: Int
        var redeemed: Int
    }
}

// クラブ統計モデル
struct ClubStats: Codable {
    var clubId: String
    var totalReceivedReports: Int
    var reviewedReports: Int
    var averageFeedbackTime: Double // 時間単位
    var topContributors: [UserContribution]
    var reportsByPosition: [PositionReportCount]
    var reportsByMonth: [MonthlyReportCount]
    var mostScoutedPlayers: [PlayerScoutCount]
    
    struct UserContribution: Codable, Identifiable {
        var id: String { userId }
        var userId: String
        var username: String
        var reportCount: Int
        var averageLikes: Double
    }
    
    struct PositionReportCount: Codable, Identifiable {
        var id: String { position }
        var position: String
        var count: Int
    }
    
    struct MonthlyReportCount: Codable, Identifiable {
        var id: String { "\(year)-\(month)" }
        var year: Int
        var month: Int
        var count: Int
    }
    
    struct PlayerScoutCount: Codable, Identifiable {
        var id: String { playerId }
        var playerId: String
        var playerName: String
        var reportCount: Int
    }
}

// リーダーボードエントリーモデル
struct LeaderboardEntry: Codable, Identifiable {
    var id: String { userId }
    var userId: String
    var username: String
    var profileImageUrl: String?
    var reportCount: Int
    var likeCount: Int
    var points: Int
    var rank: Int
}

// 選手分析モデル
struct PlayerAnalytics: Codable {
    var playerId: String
    var playerName: String
    var totalReports: Int
    var averageRatings: [ItemRating]
    var ratingTrend: [MonthlyRating]
    var strengthsAndWeaknesses: StrengthWeakness
    var interestedClubs: [ClubInterest]
    
    struct ItemRating: Codable, Identifiable {
        var id: String { itemId }
        var itemId: String
        var itemName: String
        var averageRating: Double
    }
    
    struct MonthlyRating: Codable, Identifiable {
        var id: String { "\(year)-\(month)" }
        var year: Int
        var month: Int
        var averageRating: Double
    }
    
    struct StrengthWeakness: Codable {
        var strengths: [String]
        var weaknesses: [String]
    }
    
    struct ClubInterest: Codable, Identifiable {
        var id: String { clubId }
        var clubId: String
        var clubName: String
        var interestLevel: Int // 1-5
    }
}

// システム統計モデル
struct SystemStats: Codable {
    var totalUsers: Int
    var totalClubs: Int
    var totalReports: Int
    var totalMatches: Int
    var activeUsers: Int
    var usersByRegion: [RegionCount]
    var reportsByStatus: [StatusCount]
    var pointsAwarded: Int
    var pointsRedeemed: Int
    
    struct RegionCount: Codable, Identifiable {
        var id: String { region }
        var region: String
        var count: Int
    }
    
    struct StatusCount: Codable, Identifiable {
        var id: String { status.rawValue }
        var status: ReportStatus
        var count: Int
    }
}

// 分析・統計サービス実装
class AnalyticsService: AnalyticsServiceProtocol {
    // シングルトンインスタンス
    static let shared = AnalyticsService()
    
    private init() {
        // 初期化処理
    }
    
    // ユーザー統計を取得
    func getUserStats(userId: String) -> AnyPublisher<UserStats, Error> {
        return Future<UserStats, Error> { promise in
            // 実際のアプリではAPIを呼び出してユーザー統計を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let stats = self.generateMockUserStats(userId: userId)
                promise(.success(stats))
            }
        }.eraseToAnyPublisher()
    }
    
    // クラブ統計を取得
    func getClubStats(clubId: String) -> AnyPublisher<ClubStats, Error> {
        return Future<ClubStats, Error> { promise in
            // 実際のアプリではAPIを呼び出してクラブ統計を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let stats = self.generateMockClubStats(clubId: clubId)
                promise(.success(stats))
            }
        }.eraseToAnyPublisher()
    }
    
    // リーダーボードを取得
    func getLeaderboard() -> AnyPublisher<[LeaderboardEntry], Error> {
        return Future<[LeaderboardEntry], Error> { promise in
            // 実際のアプリではAPIを呼び出してリーダーボードを取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let leaderboard = self.generateMockLeaderboard()
                promise(.success(leaderboard))
            }
        }.eraseToAnyPublisher()
    }
    
    // 選手分析を取得
    func getPlayerAnalytics(playerId: String) -> AnyPublisher<PlayerAnalytics, Error> {
        return Future<PlayerAnalytics, Error> { promise in
            // 実際のアプリではAPIを呼び出して選手分析を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let analytics = self.generateMockPlayerAnalytics(playerId: playerId)
                promise(.success(analytics))
            }
        }.eraseToAnyPublisher()
    }
    
    // システム統計を取得
    func getSystemStats() -> AnyPublisher<SystemStats, Error> {
        return Future<SystemStats, Error> { promise in
            // 実際のアプリではAPIを呼び出してシステム統計を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let stats = self.generateMockSystemStats()
                promise(.success(stats))
            }
        }.eraseToAnyPublisher()
    }
    
    // モックデータ生成（ユーザー統計）
    private func generateMockUserStats(userId: String) -> UserStats {
        return UserStats(
            userId: userId,
            totalReports: 12,
            submittedReports: 10,
            reviewedReports: 8,
            averageLikes: 3.5,
            totalPoints: 250,
            totalRedeemed: 100,
            reportsByMonth: [
                UserStats.MonthlyReportCount(year: 2025, month: 1, count: 2),
                UserStats.MonthlyReportCount(year: 2025, month: 2, count: 3),
                UserStats.MonthlyReportCount(year: 2025, month: 3, count: 7)
            ],
            pointsByMonth: [
                UserStats.MonthlyPointCount(year: 2025, month: 1, earned: 50, redeemed: 0),
                UserStats.MonthlyPointCount(year: 2025, month: 2, earned: 75, redeemed: 0),
                UserStats.MonthlyPointCount(year: 2025, month: 3, earned: 225, redeemed: 100)
            ],
            topRatedReports: [] // 実際のアプリでは実際のレポートデータを入れる
        )
    }
    
    // モックデータ生成（クラブ統計）
    private func generateMockClubStats(clubId: String) -> ClubStats {
        return ClubStats(
            clubId: clubId,
            totalReceivedReports: 45,
            reviewedReports: 40,
            averageFeedbackTime: 24.5,
            topContributors: [
                ClubStats.UserContribution(userId: "user1", username: "サッカー太郎", reportCount: 12, averageLikes: 4.2),
                ClubStats.UserContribution(userId: "user2", username: "フットボール次郎", reportCount: 8, averageLikes: 3.8),
                ClubStats.UserContribution(userId: "user3", username: "Jリーグ三郎", reportCount: 6, averageLikes: 3.5)
            ],
            reportsByPosition: [
                ClubStats.PositionReportCount(position: "FW", count: 15),
                ClubStats.PositionReportCount(position: "MF", count: 18),
                ClubStats.PositionReportCount(position: "DF", count: 10),
                ClubStats.PositionReportCount(position: "GK", count: 2)
            ],
            reportsByMonth: [
                ClubStats.MonthlyReportCount(year: 2025, month: 1, count: 10),
                ClubStats.MonthlyReportCount(year: 2025, month: 2, count: 15),
                ClubStats.MonthlyReportCount(year: 2025, month: 3, count: 20)
            ],
            mostScoutedPlayers: [
                ClubStats.PlayerScoutCount(playerId: "player1", playerName: "三笘薫", reportCount: 8),
                ClubStats.PlayerScoutCount(playerId: "player2", playerName: "久保建英", reportCount: 7),
                ClubStats.PlayerScoutCount(playerId: "player3", playerName: "興梠慎三", reportCount: 5)
            ]
        )
    }
    
    // モックデータ生成（リーダーボード）
    private func generateMockLeaderboard() -> [LeaderboardEntry] {
        return [
            LeaderboardEntry(userId: "user1", username: "サッカー太郎", profileImageUrl: "profile1", reportCount: 12, likeCount: 50, points: 350, rank: 1),
            LeaderboardEntry(userId: "user2", username: "フットボール次郎", profileImageUrl: "profile2", reportCount: 10, likeCount: 40, points: 300, rank: 2),
            LeaderboardEntry(userId: "user3", username: "Jリーグ三郎", profileImageUrl: "profile3", reportCount: 8, likeCount: 35, points: 250, rank: 3),
            LeaderboardEntry(userId: "user4", username: "ゴール四郎", profileImageUrl: "profile4", reportCount: 7, likeCount: 30, points: 200, rank: 4),
            LeaderboardEntry(userId: "user5", username: "ドリブル五郎", profileImageUrl: "profile5", reportCount: 6, likeCount: 25, points: 180, rank: 5)
        ]
    }
    
    // モックデータ生成（選手分析）
    private func generateMockPlayerAnalytics(playerId: String) -> PlayerAnalytics {
        let playerName = playerId == "player1" ? "三笘薫" : (playerId == "player2" ? "久保建英" : "興梠慎三")
        
        return PlayerAnalytics(
            playerId: playerId,
            playerName: playerName,
            totalReports: 8,
            averageRatings: [
                PlayerAnalytics.ItemRating(itemId: "item1", itemName: "テクニック", averageRating: 4.5),
                PlayerAnalytics.ItemRating(itemId: "item2", itemName: "フィジカル", averageRating: 3.8),
                PlayerAnalytics.ItemRating(itemId: "item3", itemName: "戦術理解", averageRating: 4.2),
                PlayerAnalytics.ItemRating(itemId: "item4", itemName: "メンタル", averageRating: 4.0),
                PlayerAnalytics.ItemRating(itemId: "item5", itemName: "ポテンシャル", averageRating: 4.7)
            ],
            ratingTrend: [
                PlayerAnalytics.MonthlyRating(year: 2025, month: 1, averageRating: 4.0),
                PlayerAnalytics.MonthlyRating(year: 2025, month: 2, averageRating: 4.2),
                PlayerAnalytics.MonthlyRating(year: 2025, month: 3, averageRating: 4.5)
            ],
            strengthsAndWeaknesses: PlayerAnalytics.StrengthWeakness(
                strengths: ["優れたボールコントロール", "状況判断の良さ", "創造性"],
                weaknesses: ["フィジカルコンタクト", "ヘディング"]
            ),
            interestedClubs: [
                PlayerAnalytics.ClubInterest(clubId: "club1", clubName: "FC東京", interestLevel: 5),
                PlayerAnalytics.ClubInterest(clubId: "club3", clubName: "横浜F・マリノス", interestLevel: 4),
                PlayerAnalytics.ClubInterest(clubId: "club5", clubName: "ガンバ大阪", interestLevel: 3)
            ]
        )
    }
    
    // モックデータ生成（システム統計）
    private func generateMockSystemStats() -> SystemStats {
        return SystemStats(
            totalUsers: 250,
            totalClubs: 20,
            totalReports: 450,
            totalMatches: 120,
            activeUsers: 180,
            usersByRegion: [
                SystemStats.RegionCount(region: "関東", count: 100),
                SystemStats.RegionCount(region: "関西", count: 70),
                SystemStats.RegionCount(region: "中部", count: 40),
                SystemStats.RegionCount(region: "その他", count: 40)
            ],
            reportsByStatus: [
                SystemStats.StatusCount(status: .draft, count: 50),
                SystemStats.StatusCount(status: .submitted, count: 100),
                SystemStats.StatusCount(status: .reviewed, count: 300)
            ],
            pointsAwarded: 5000,
            pointsRedeemed: 2500
        )
    }
}

// 分析エラー
enum AnalyticsError: Error {
    case dataNotFound
    case processingError
    case networkError
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .dataNotFound:
            return "データが見つかりません"
        case .processingError:
            return "データ処理エラーが発生しました"
        case .networkError:
            return "ネットワークエラーが発生しました"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
}

// 分析・統計を管理するビューモデル
class AnalyticsViewModel: ObservableObject {
    // 分析サービス
    private let analyticsService: AnalyticsServiceProtocol
    
    // 購読を保持するためのセット
    private var cancellables = Set<AnyCancellable>()
    
    // 公開プロパティ
    @Published var userStats: UserStats?
    @Published var clubStats: ClubStats?
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var playerAnalytics: PlayerAnalytics?
    @Published var systemStats: SystemStats?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared) {
        self.analyticsService = analyticsService
    }
    
    // ユーザー統計を読み込む
    func loadUserStats(userId: String) {
        isLoading = true
        errorMessage = nil
        
        analyticsService.getUserStats(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] stats in
                    self?.userStats = stats
                }
            )
            .store(in: &cancellables)
    }
    
    // クラブ統計を読み込む
    func loadClubStats(clubId: String) {
        isLoading = true
        errorMessage = nil
        
        analyticsService.getClubStats(clubId: clubId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] stats in
                    self?.clubStats = stats
                }
            )
            .store(in: &cancellables)
    }
    
    // リーダーボードを読み込む
    func loadLeaderboard() {
        isLoading = true
        errorMessage = nil
        
        analyticsService.getLeaderboard()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] leaderboard in
                    self?.leaderboard = leaderboard
                }
            )
            .store(in: &cancellables)
    }
    
    // 選手分析を読み込む
    func loadPlayerAnalytics(playerId: String) {
        isLoading = true
        errorMessage = nil
        
        analyticsService.getPlayerAnalytics(playerId: playerId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] analytics in
                    self?.playerAnalytics = analytics
                }
            )
            .store(in: &cancellables)
    }
    
    // システム統計を読み込む
    func loadSystemStats() {
        isLoading = true
        errorMessage = nil
        
        analyticsService.getSystemStats()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] stats in
                    self?.systemStats = stats
                }
            )
            .store(in: &cancellables)
    }
    
    // 月名を取得
    func getMonthName(month: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        return dateFormatter.monthSymbols[month - 1]
    }
    
    // レポートステータスの表示名を取得
    func getStatusDisplayName(status: ReportStatus) -> String {
        switch status {
        case .draft:
            return "下書き"
        case .submitted:
            return "提出済み"
        case .reviewed:
            return "評価済み"
        }
    }
}
