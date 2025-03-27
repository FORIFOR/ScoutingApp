import Foundation
import Combine

// 報酬システムサービスプロトコル
protocol RewardServiceProtocol {
    func getUserPoints(userId: String) -> AnyPublisher<Int, Error>
    func getPointHistory(userId: String) -> AnyPublisher<[PointHistory], Error>
    func addPoints(userId: String, amount: Int, type: PointType, description: String, relatedId: String?) -> AnyPublisher<Int, Error>
    func redeemPoints(userId: String, amount: Int, description: String) -> AnyPublisher<Int, Error>
    func getRewardItems() -> AnyPublisher<[RewardItem], Error>
    func redeemReward(userId: String, rewardId: String) -> AnyPublisher<RewardRedemption, Error>
}

// 報酬アイテムモデル
struct RewardItem: Codable, Identifiable {
    var id: String
    var name: String
    var description: String
    var pointCost: Int
    var imageUrl: String?
    var category: RewardCategory
    var isAvailable: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, 
         name: String, 
         description: String, 
         pointCost: Int, 
         imageUrl: String? = nil, 
         category: RewardCategory, 
         isAvailable: Bool = true, 
         createdAt: Date = Date(), 
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.description = description
        self.pointCost = pointCost
        self.imageUrl = imageUrl
        self.category = category
        self.isAvailable = isAvailable
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// 報酬カテゴリ
enum RewardCategory: String, Codable {
    case ticket      // チケット
    case merchandise // グッズ
    case experience  // 体験
    case discount    // 割引
    case other       // その他
}

// 報酬交換履歴モデル
struct RewardRedemption: Codable, Identifiable {
    var id: String
    var userId: String
    var rewardId: String
    var reward: RewardItem?
    var pointsUsed: Int
    var status: RedemptionStatus
    var redemptionCode: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, 
         userId: String, 
         rewardId: String, 
         reward: RewardItem? = nil, 
         pointsUsed: Int, 
         status: RedemptionStatus = .pending, 
         redemptionCode: String? = nil, 
         createdAt: Date = Date(), 
         updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.rewardId = rewardId
        self.reward = reward
        self.pointsUsed = pointsUsed
        self.status = status
        self.redemptionCode = redemptionCode
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// 交換ステータス
enum RedemptionStatus: String, Codable {
    case pending   // 処理中
    case completed // 完了
    case cancelled // キャンセル
}

// 報酬システムサービス実装
class RewardService: RewardServiceProtocol {
    // シングルトンインスタンス
    static let shared = RewardService()
    
    private init() {
        // 初期化処理
    }
    
    // ユーザーのポイントを取得
    func getUserPoints(userId: String) -> AnyPublisher<Int, Error> {
        return Future<Int, Error> { promise in
            // 実際のアプリではAPIを呼び出してポイントを取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let points = 250
                promise(.success(points))
            }
        }.eraseToAnyPublisher()
    }
    
    // ポイント履歴を取得
    func getPointHistory(userId: String) -> AnyPublisher<[PointHistory], Error> {
        return Future<[PointHistory], Error> { promise in
            // 実際のアプリではAPIを呼び出してポイント履歴を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let history = self.generateMockPointHistory(userId: userId)
                promise(.success(history))
            }
        }.eraseToAnyPublisher()
    }
    
    // ポイントを追加
    func addPoints(userId: String, amount: Int, type: PointType, description: String, relatedId: String? = nil) -> AnyPublisher<Int, Error> {
        return Future<Int, Error> { promise in
            // 実際のアプリではAPIを呼び出してポイントを追加
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let currentPoints = 250
                let newPoints = currentPoints + amount
                promise(.success(newPoints))
            }
        }.eraseToAnyPublisher()
    }
    
    // ポイントを使用
    func redeemPoints(userId: String, amount: Int, description: String) -> AnyPublisher<Int, Error> {
        return Future<Int, Error> { promise in
            // 実際のアプリではAPIを呼び出してポイントを使用
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let currentPoints = 250
                if amount > currentPoints {
                    promise(.failure(RewardError.insufficientPoints))
                    return
                }
                let newPoints = currentPoints - amount
                promise(.success(newPoints))
            }
        }.eraseToAnyPublisher()
    }
    
    // 報酬アイテム一覧を取得
    func getRewardItems() -> AnyPublisher<[RewardItem], Error> {
        return Future<[RewardItem], Error> { promise in
            // 実際のアプリではAPIを呼び出して報酬アイテム一覧を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let items = self.generateMockRewardItems()
                promise(.success(items))
            }
        }.eraseToAnyPublisher()
    }
    
    // 報酬を交換
    func redeemReward(userId: String, rewardId: String) -> AnyPublisher<RewardRedemption, Error> {
        return Future<RewardRedemption, Error> { promise in
            // 実際のアプリではAPIを呼び出して報酬を交換
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let rewardItem = self.generateMockRewardItems().first(where: { $0.id == rewardId }) {
                    let currentPoints = 250
                    if rewardItem.pointCost > currentPoints {
                        promise(.failure(RewardError.insufficientPoints))
                        return
                    }
                    
                    let redemption = RewardRedemption(
                        userId: userId,
                        rewardId: rewardId,
                        reward: rewardItem,
                        pointsUsed: rewardItem.pointCost,
                        status: .completed,
                        redemptionCode: "REWARD-\(Int.random(in: 10000...99999))"
                    )
                    promise(.success(redemption))
                } else {
                    promise(.failure(RewardError.rewardNotFound))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // モックデータ生成（ポイント履歴）
    private func generateMockPointHistory(userId: String) -> [PointHistory] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        return [
            PointHistory(
                userId: userId,
                amount: 100,
                type: .earned,
                description: "三笘薫選手のスカウティングレポートへの評価",
                relatedId: "report1",
                createdAt: dateFormatter.date(from: "2025/03/26")!
            ),
            PointHistory(
                userId: userId,
                amount: 75,
                type: .earned,
                description: "興梠慎三選手のスカウティングレポートへの評価",
                relatedId: "report3",
                createdAt: dateFormatter.date(from: "2025/03/16")!
            ),
            PointHistory(
                userId: userId,
                amount: 50,
                type: .earned,
                description: "アプリ登録ボーナス",
                createdAt: dateFormatter.date(from: "2025/03/01")!
            ),
            PointHistory(
                userId: userId,
                amount: 25,
                type: .earned,
                description: "初回レポート作成ボーナス",
                relatedId: "report1",
                createdAt: dateFormatter.date(from: "2025/03/10")!
            ),
            PointHistory(
                userId: userId,
                amount: 100,
                type: .redeemed,
                description: "ホームゲームチケット割引券と交換",
                relatedId: "redemption1",
                createdAt: dateFormatter.date(from: "2025/03/20")!
            )
        ]
    }
    
    // モックデータ生成（報酬アイテム）
    private func generateMockRewardItems() -> [RewardItem] {
        return [
            RewardItem(
                id: "reward1",
                name: "ホームゲームチケット割引券",
                description: "FC東京ホームゲームのチケットが20%割引になるクーポン",
                pointCost: 100,
                imageUrl: "ticket_discount",
                category: .discount
            ),
            RewardItem(
                id: "reward2",
                name: "オリジナルマフラータオル",
                description: "FC東京オリジナルマフラータオル",
                pointCost: 200,
                imageUrl: "towel",
                category: .merchandise
            ),
            RewardItem(
                id: "reward3",
                name: "選手サイン入りユニフォーム抽選券",
                description: "選手サイン入りユニフォームが当たる抽選に参加できる券",
                pointCost: 500,
                imageUrl: "uniform",
                category: .merchandise
            ),
            RewardItem(
                id: "reward4",
                name: "試合前ピッチ見学ツアー",
                description: "ホームゲーム前にピッチを見学できる特別ツアーに参加できる権利",
                pointCost: 300,
                imageUrl: "tour",
                category: .experience
            ),
            RewardItem(
                id: "reward5",
                name: "クラブハウス見学ツアー",
                description: "クラブハウスを見学できる特別ツアーに参加できる権利",
                pointCost: 400,
                imageUrl: "clubhouse",
                category: .experience
            )
        ]
    }
}

// 報酬エラー
enum RewardError: Error {
    case insufficientPoints
    case rewardNotFound
    case redemptionFailed
    case networkError
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .insufficientPoints:
            return "ポイントが不足しています"
        case .rewardNotFound:
            return "報酬アイテムが見つかりません"
        case .redemptionFailed:
            return "交換処理に失敗しました"
        case .networkError:
            return "ネットワークエラーが発生しました"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
}

// 報酬システムを管理するビューモデル
class RewardViewModel: ObservableObject {
    // 報酬サービス
    private let rewardService: RewardServiceProtocol
    
    // 購読を保持するためのセット
    private var cancellables = Set<AnyCancellable>()
    
    // 公開プロパティ
    @Published var userPoints: Int = 0
    @Published var pointHistory: [PointHistory] = []
    @Published var rewardItems: [RewardItem] = []
    @Published var redemptions: [RewardRedemption] = []
    @Published var selectedReward: RewardItem?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // フィルター状態
    @Published var selectedCategory: RewardCategory?
    
    init(rewardService: RewardServiceProtocol = RewardService.shared) {
        self.rewardService = rewardService
    }
    
    // ユーザーのポイントを読み込む
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
    
    // ポイント履歴を読み込む
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
    
    // 報酬アイテム一覧を読み込む
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
                    
                    // カテゴリでフィルタリング
                    if let category = self?.selectedCategory {
                        self?.rewardItems = items.filter { $0.category == category }
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // 報酬を交換
    func redeemReward(userId: String, rewardId: String) {
        guard let reward = rewardItems.first(where: { $0.id == rewardId }) else {
            errorMessage = "報酬アイテムが見つかりません"
            return
        }
        
        if reward.pointCost > userPoints {
            errorMessage = "ポイントが不足しています"
            return
        }
        
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
                receiveValue: { [weak self] redemption in
                    // ポイントを更新
                    if let self = self {
                        self.userPoints -= redemption.pointsUsed
                    }
                    
                    // 履歴を更新
                    self?.loadPointHistory(userId: userId)
                }
            )
            .store(in: &cancellables)
    }
    
    // カテゴリでフィルタリング
    func filterByCategory(category: RewardCategory?) {
        selectedCategory = category
        loadRewardItems()
    }
    
    // ポイントタイプに応じた表示名を取得
    func getPointTypeDisplayName(type: PointType) -> String {
        switch type {
        case .earned:
            return "獲得"
        case .redeemed:
            return "使用"
        case .expired:
            return "期限切れ"
        }
    }
    
    // ポイントタイプに応じた色を取得
    func getPointTypeColor(type: PointType) -> String {
        switch type {
        case .earned:
            return "#34A853" // アクセントグリーン
        case .redeemed:
            return "#EA4335" // サポートレッド
        case .expired:
            return "#5F6368" // ミディアムグレー
        }
    }
    
    // 報酬カテゴリに応じた表示名を取得
    func getCategoryDisplayName(category: RewardCategory) -> String {
        switch category {
        case .ticket:
            return "チケット"
        case .merchandise:
            return "グッズ"
        case .experience:
            return "体験"
        case .discount:
            return "割引"
        case .other:
            return "その他"
        }
    }
    
    // 報酬カテゴリに応じたアイコン名を取得
    func getCategoryIconName(category: RewardCategory) -> String {
        switch category {
        case .ticket:
            return "ticket.fill"
        case .merchandise:
            return "tshirt.fill"
        case .experience:
            return "star.fill"
        case .discount:
            return "percent"
        case .other:
            return "gift.fill"
        }
    }
}
