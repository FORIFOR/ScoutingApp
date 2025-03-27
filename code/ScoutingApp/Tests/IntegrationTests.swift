import XCTest
@testable import ScoutingApp

class IntegrationTests: XCTestCase {
    
    var authService: AuthenticationService!
    var reportService: ReportService!
    var syncManager: SyncManager!
    var mockFirebaseManager: MockFirebaseManager!
    var mockLocalDataManager: MockLocalDataManager!
    
    override func setUp() {
        super.setUp()
        mockFirebaseManager = MockFirebaseManager()
        mockLocalDataManager = MockLocalDataManager()
        
        authService = AuthenticationService(firebaseManager: mockFirebaseManager)
        reportService = ReportService(firebaseManager: mockFirebaseManager)
        syncManager = SyncManager(firebaseManager: mockFirebaseManager, localDataManager: mockLocalDataManager)
    }
    
    override func tearDown() {
        authService = nil
        reportService = nil
        syncManager = nil
        mockFirebaseManager = nil
        mockLocalDataManager = nil
        super.tearDown()
    }
    
    func testUserSignInAndCreateReport() {
        // テスト用データ
        let email = "test@example.com"
        let password = "password123"
        let userId = "user1"
        let clubId = "club1"
        let playerId = "player1"
        let matchId = "match1"
        let templateId = "template1"
        
        let signInExpectation = self.expectation(description: "サインイン成功")
        let createReportExpectation = self.expectation(description: "レポート作成成功")
        let syncExpectation = self.expectation(description: "同期成功")
        
        // モックの設定 - サインイン
        let mockUser = User(id: userId, email: email, username: "テストユーザー", createdAt: Date(), updatedAt: Date())
        mockFirebaseManager.loginUserResult = .success(mockUser)
        
        // モックの設定 - レポート作成
        let reportId = "report1"
        let createdReport = ScoutingReport(
            id: reportId,
            userId: userId,
            clubId: clubId,
            playerId: playerId,
            matchId: matchId,
            templateId: templateId,
            status: .draft,
            evaluations: [
                Evaluation(id: "eval1", itemId: "item1", rating: 4, comment: "良いプレー")
            ],
            overallComment: "将来性のある選手",
            mediaUrls: ["image1.jpg"],
            likes: 0,
            feedback: nil,
            pointsAwarded: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockFirebaseManager.createReportResult = .success(createdReport)
        
        // モックの設定 - 同期
        mockFirebaseManager.getUserResult = .success(mockUser)
        mockFirebaseManager.getReportsByUserResult = .success([createdReport])
        mockFirebaseManager.getMatchesResult = .success([])
        mockFirebaseManager.getPointHistoryResult = .success([])
        mockFirebaseManager.getRewardItemsResult = .success([])
        
        // テスト実行 - サインイン
        var signedInUser: User?
        var signInError: Error?
        
        authService.signIn(email: email, password: password)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        signInError = error
                    }
                    signInExpectation.fulfill()
                },
                receiveValue: { user in
                    signedInUser = user
                }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(signInError)
            XCTAssertNotNil(signedInUser)
            XCTAssertEqual(signedInUser?.id, userId)
            
            // テスト実行 - レポート作成
            let newReport = ScoutingReport(
                id: "",
                userId: userId,
                clubId: clubId,
                playerId: playerId,
                matchId: matchId,
                templateId: templateId,
                status: .draft,
                evaluations: [
                    Evaluation(id: "eval1", itemId: "item1", rating: 4, comment: "良いプレー")
                ],
                overallComment: "将来性のある選手",
                mediaUrls: ["image1.jpg"],
                likes: 0,
                feedback: nil,
                pointsAwarded: 0,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            var createdReportResult: ScoutingReport?
            var createReportError: Error?
            
            self.reportService.createReport(report: newReport)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            createReportError = error
                        }
                        createReportExpectation.fulfill()
                    },
                    receiveValue: { report in
                        createdReportResult = report
                    }
                )
                .store(in: &self.mockFirebaseManager.cancellables)
            
            self.waitForExpectations(timeout: 1.0) { error in
                XCTAssertNil(error)
                XCTAssertNil(createReportError)
                XCTAssertNotNil(createdReportResult)
                XCTAssertEqual(createdReportResult?.id, reportId)
                
                // テスト実行 - 同期
                var syncError: Error?
                
                self.syncManager.syncAllData(userId: userId)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                syncError = error
                            }
                            syncExpectation.fulfill()
                        },
                        receiveValue: { _ in }
                    )
                    .store(in: &self.mockFirebaseManager.cancellables)
                
                self.waitForExpectations(timeout: 1.0) { error in
                    XCTAssertNil(error)
                    XCTAssertNil(syncError)
                    
                    // 同期結果の検証
                    XCTAssertEqual(self.mockLocalDataManager.savedUser?.id, userId)
                    XCTAssertEqual(self.mockLocalDataManager.savedReports?.count, 1)
                    XCTAssertEqual(self.mockLocalDataManager.savedReports?.first?.id, reportId)
                }
            }
        }
    }
    
    func testReportSubmissionAndFeedback() {
        // テスト用データ
        let userId = "user1"
        let clubId = "club1"
        let reportId = "report1"
        
        let submitReportExpectation = self.expectation(description: "レポート提出成功")
        let addFeedbackExpectation = self.expectation(description: "フィードバック追加成功")
        
        // モックの設定 - レポート更新
        let report = ScoutingReport(
            id: reportId,
            userId: userId,
            clubId: clubId,
            playerId: "player1",
            matchId: "match1",
            templateId: "template1",
            status: .draft,
            evaluations: [
                Evaluation(id: "eval1", itemId: "item1", rating: 4, comment: "良いプレー")
            ],
            overallComment: "将来性のある選手",
            mediaUrls: ["image1.jpg"],
            likes: 0,
            feedback: nil,
            pointsAwarded: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let submittedReport = ScoutingReport(
            id: reportId,
            userId: userId,
            clubId: clubId,
            playerId: "player1",
            matchId: "match1",
            templateId: "template1",
            status: .submitted,
            evaluations: report.evaluations,
            overallComment: report.overallComment,
            mediaUrls: report.mediaUrls,
            likes: 0,
            feedback: nil,
            pointsAwarded: 0,
            createdAt: report.createdAt,
            updatedAt: Date()
        )
        mockFirebaseManager.updateReportResult = .success(submittedReport)
        
        // モックの設定 - フィードバック追加
        let feedback = "素晴らしい観察力です"
        let points = 50
        let reviewedReport = ScoutingReport(
            id: reportId,
            userId: userId,
            clubId: clubId,
            playerId: "player1",
            matchId: "match1",
            templateId: "template1",
            status: .reviewed,
            evaluations: report.evaluations,
            overallComment: report.overallComment,
            mediaUrls: report.mediaUrls,
            likes: 1,
            feedback: feedback,
            pointsAwarded: points,
            createdAt: report.createdAt,
            updatedAt: Date()
        )
        mockFirebaseManager.addFeedbackResult = .success(reviewedReport)
        
        // テスト実行 - レポート提出
        var submittedReportResult: ScoutingReport?
        var submitReportError: Error?
        
        reportService.updateReport(report: report, newStatus: .submitted)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        submitReportError = error
                    }
                    submitReportExpectation.fulfill()
                },
                receiveValue: { report in
                    submittedReportResult = report
                }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(submitReportError)
            XCTAssertNotNil(submittedReportResult)
            XCTAssertEqual(submittedReportResult?.status, .submitted)
            
            // テスト実行 - フィードバック追加
            var reviewedReportResult: ScoutingReport?
            var addFeedbackError: Error?
            
            self.reportService.addFeedback(reportId: reportId, feedback: feedback, pointsAwarded: points)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            addFeedbackError = error
                        }
                        addFeedbackExpectation.fulfill()
                    },
                    receiveValue: { report in
                        reviewedReportResult = report
                    }
                )
                .store(in: &self.mockFirebaseManager.cancellables)
            
            self.waitForExpectations(timeout: 1.0) { error in
                XCTAssertNil(error)
                XCTAssertNil(addFeedbackError)
                XCTAssertNotNil(reviewedReportResult)
                XCTAssertEqual(reviewedReportResult?.status, .reviewed)
                XCTAssertEqual(reviewedReportResult?.feedback, feedback)
                XCTAssertEqual(reviewedReportResult?.pointsAwarded, points)
            }
        }
    }
    
    func testOfflineReportCreationAndSync() {
        // テスト用データ
        let userId = "user1"
        let reportId = "offline1"
        
        let createOfflineReportExpectation = self.expectation(description: "オフラインレポート作成")
        let syncOfflineReportsExpectation = self.expectation(description: "オフラインレポート同期")
        
        // オフラインレポートの作成
        let offlineReport = ScoutingReport(
            id: reportId,
            userId: userId,
            clubId: "club1",
            playerId: "player1",
            matchId: "match1",
            templateId: "template1",
            status: .draft,
            evaluations: [
                Evaluation(id: "eval1", itemId: "item1", rating: 4, comment: "良いプレー")
            ],
            overallComment: "将来性のある選手",
            mediaUrls: [],
            likes: 0,
            feedback: nil,
            pointsAwarded: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // ローカルデータマネージャーにオフラインレポートを保存
        mockLocalDataManager.saveReport(offlineReport)
        mockLocalDataManager.unsyncedReports = [offlineReport]
        
        // モックの設定 - レポート同期
        mockFirebaseManager.createReportResult = .success(offlineReport)
        
        // テスト実行 - オフラインレポート作成の確認
        XCTAssertEqual(mockLocalDataManager.unsyncedReports.count, 1)
        XCTAssertEqual(mockLocalDataManager.unsyncedReports.first?.id, reportId)
        createOfflineReportExpectation.fulfill()
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            
            // テスト実行 - オフラインレポート同期
            var syncError: Error?
            
            self.syncManager.syncOfflineReports(userId: userId)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            syncError = error
                        }
                        syncOfflineReportsExpectation.fulfill()
                    },
                    receiveValue: { _ in }
                )
                .store(in: &self.mockFirebaseManager.cancellables)
            
            self.waitForExpectations(timeout: 1.0) { error in
                XCTAssertNil(error)
                XCTAssertNil(syncError)
                
                // 同期結果の検証
                XCTAssertEqual(self.mockLocalDataManager.markedAsSyncedReports?.count, 1)
                XCTAssertEqual(self.mockLocalDataManager.markedAsSyncedReports?.first?.id, reportId)
            }
        }
    }
}

// MockLocalDataManagerの拡張
extension MockLocalDataManager {
    func saveReport(_ report: ScoutingReport) {
        if savedReports == nil {
            savedReports = []
        }
        savedReports?.append(report)
    }
}
