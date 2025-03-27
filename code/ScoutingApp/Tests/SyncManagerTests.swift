import XCTest
@testable import ScoutingApp

class SyncManagerTests: XCTestCase {
    
    var syncManager: SyncManager!
    var mockFirebaseManager: MockFirebaseManager!
    var mockLocalDataManager: MockLocalDataManager!
    
    override func setUp() {
        super.setUp()
        mockFirebaseManager = MockFirebaseManager()
        mockLocalDataManager = MockLocalDataManager()
        syncManager = SyncManager(firebaseManager: mockFirebaseManager, localDataManager: mockLocalDataManager)
    }
    
    override func tearDown() {
        syncManager = nil
        mockFirebaseManager = nil
        mockLocalDataManager = nil
        super.tearDown()
    }
    
    func testSyncAllDataSuccess() {
        // テスト用データ
        let userId = "user1"
        let expectation = self.expectation(description: "全データ同期成功")
        
        // モックの設定
        let user = User(id: userId, email: "test@example.com", username: "テストユーザー", createdAt: Date(), updatedAt: Date())
        mockFirebaseManager.getUserResult = .success(user)
        
        let matches = [
            Match(id: "match1", homeTeamId: "team1", awayTeamId: "team2", date: Date(), venue: "スタジアム1", category: "J1", status: .scheduled, createdAt: Date(), updatedAt: Date()),
            Match(id: "match2", homeTeamId: "team3", awayTeamId: "team4", date: Date().addingTimeInterval(86400), venue: "スタジアム2", category: "J1", status: .scheduled, createdAt: Date(), updatedAt: Date())
        ]
        mockFirebaseManager.getMatchesResult = .success(matches)
        
        let reports = [
            ScoutingReport(id: "report1", userId: userId, clubId: "club1", playerId: "player1", matchId: "match1", templateId: "template1", status: .submitted, evaluations: [], createdAt: Date(), updatedAt: Date()),
            ScoutingReport(id: "report2", userId: userId, clubId: "club2", playerId: "player2", matchId: "match2", templateId: "template1", status: .draft, evaluations: [], createdAt: Date(), updatedAt: Date())
        ]
        mockFirebaseManager.getReportsByUserResult = .success(reports)
        
        let pointHistory = [
            PointHistory(id: "history1", userId: userId, amount: 50, type: .earned, description: "レポート評価", createdAt: Date()),
            PointHistory(id: "history2", userId: userId, amount: -20, type: .redeemed, description: "報酬交換", createdAt: Date())
        ]
        mockFirebaseManager.getPointHistoryResult = .success(pointHistory)
        
        let rewardItems = [
            RewardItem(id: "reward1", name: "チケット割引", description: "ホームゲーム観戦チケット20%割引", pointCost: 100, category: .ticket, createdAt: Date(), updatedAt: Date()),
            RewardItem(id: "reward2", name: "選手サイン入りグッズ", description: "選手のサイン入りユニフォーム", pointCost: 500, category: .goods, createdAt: Date(), updatedAt: Date())
        ]
        mockFirebaseManager.getRewardItemsResult = .success(rewardItems)
        
        // テスト実行
        var resultError: Error?
        
        syncManager.syncAllData(userId: userId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        resultError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        // 結果検証
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(resultError)
            
            // 各データがローカルに保存されたことを確認
            XCTAssertEqual(self.mockLocalDataManager.savedUser?.id, userId)
            XCTAssertEqual(self.mockLocalDataManager.savedMatches?.count, 2)
            XCTAssertEqual(self.mockLocalDataManager.savedReports?.count, 2)
            XCTAssertEqual(self.mockLocalDataManager.savedPointHistory?.count, 2)
            XCTAssertEqual(self.mockLocalDataManager.savedRewardItems?.count, 2)
            
            // 同期状態が更新されたことを確認
            XCTAssertNotNil(self.syncManager.lastSyncDate)
            XCTAssertFalse(self.syncManager.isSyncing)
        }
    }
    
    func testSyncOfflineReportsSuccess() {
        // テスト用データ
        let userId = "user1"
        let expectation = self.expectation(description: "オフラインレポート同期成功")
        
        // モックの設定
        let unsyncedReports = [
            ScoutingReport(id: "report1", userId: userId, clubId: "club1", playerId: "player1", matchId: "match1", templateId: "template1", status: .draft, evaluations: [], createdAt: Date(), updatedAt: Date()),
            ScoutingReport(id: "report2", userId: userId, clubId: "club2", playerId: "player2", matchId: "match2", templateId: "template1", status: .draft, evaluations: [], createdAt: Date(), updatedAt: Date())
        ]
        mockLocalDataManager.unsyncedReports = unsyncedReports
        
        mockFirebaseManager.createReportResult = .success(unsyncedReports[0])
        
        // テスト実行
        var resultError: Error?
        
        syncManager.syncOfflineReports(userId: userId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        resultError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        // 結果検証
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(resultError)
            
            // レポートが同期済みとしてマークされたことを確認
            XCTAssertEqual(self.mockLocalDataManager.markedAsSyncedReports?.count, 2)
        }
    }
    
    func testSyncFailure() {
        // テスト用データ
        let userId = "user1"
        let expectation = self.expectation(description: "同期失敗")
        
        // モックの設定 - エラーを発生させる
        let mockError = NSError(domain: "SyncError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ネットワークエラー"])
        mockFirebaseManager.getUserResult = .failure(mockError)
        
        // テスト実行
        var resultError: Error?
        
        syncManager.syncAllData(userId: userId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        resultError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        // 結果検証
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNotNil(resultError)
            XCTAssertEqual((resultError as NSError?)?.localizedDescription, "ネットワークエラー")
            
            // 同期状態が更新されたことを確認
            XCTAssertFalse(self.syncManager.isSyncing)
        }
    }
}

// モックLocalDataManager
class MockLocalDataManager {
    var savedUser: User?
    var savedMatches: [Match]?
    var savedReports: [ScoutingReport]?
    var savedPointHistory: [PointHistory]?
    var savedRewardItems: [RewardItem]?
    var unsyncedReports: [ScoutingReport] = []
    var markedAsSyncedReports: [ScoutingReport]?
    
    func saveUser(_ user: User) {
        savedUser = user
    }
    
    func saveMatches(_ matches: [Match]) {
        savedMatches = matches
    }
    
    func saveReports(_ reports: [ScoutingReport]) {
        savedReports = reports
    }
    
    func savePointHistory(_ history: [PointHistory]) {
        savedPointHistory = history
    }
    
    func saveRewardItems(_ items: [RewardItem]) {
        savedRewardItems = items
    }
    
    func getUnsyncedReports() -> [ScoutingReport] {
        return unsyncedReports
    }
    
    func markReportsAsSynced(reports: [ScoutingReport]) {
        markedAsSyncedReports = reports
    }
}
