import XCTest
@testable import ScoutingApp

class ReportServiceTests: XCTestCase {
    
    var reportService: ReportService!
    var mockFirebaseManager: MockFirebaseManager!
    
    override func setUp() {
        super.setUp()
        mockFirebaseManager = MockFirebaseManager()
        reportService = ReportService(firebaseManager: mockFirebaseManager)
    }
    
    override func tearDown() {
        reportService = nil
        mockFirebaseManager = nil
        super.tearDown()
    }
    
    func testCreateReportSuccess() {
        // テスト用データ
        let userId = "user1"
        let clubId = "club1"
        let playerId = "player1"
        let matchId = "match1"
        let templateId = "template1"
        let expectation = self.expectation(description: "レポート作成成功")
        
        // 新しいレポートを作成
        let report = ScoutingReport(
            id: "",
            userId: userId,
            clubId: clubId,
            playerId: playerId,
            matchId: matchId,
            templateId: templateId,
            status: .draft,
            evaluations: [
                Evaluation(id: "eval1", itemId: "item1", rating: 4, comment: "良いプレー"),
                Evaluation(id: "eval2", itemId: "item2", rating: 3, comment: "平均的")
            ],
            overallComment: "将来性のある選手",
            mediaUrls: ["image1.jpg"],
            likes: 0,
            feedback: nil,
            pointsAwarded: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // モックの設定
        let createdReport = ScoutingReport(
            id: "report1",
            userId: userId,
            clubId: clubId,
            playerId: playerId,
            matchId: matchId,
            templateId: templateId,
            status: .draft,
            evaluations: report.evaluations,
            overallComment: report.overallComment,
            mediaUrls: report.mediaUrls,
            likes: 0,
            feedback: nil,
            pointsAwarded: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockFirebaseManager.createReportResult = .success(createdReport)
        
        // テスト実行
        var resultReport: ScoutingReport?
        var resultError: Error?
        
        reportService.createReport(report: report)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        resultError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { report in
                    resultReport = report
                }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        // 結果検証
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(resultError)
            XCTAssertNotNil(resultReport)
            XCTAssertEqual(resultReport?.id, "report1")
            XCTAssertEqual(resultReport?.userId, userId)
            XCTAssertEqual(resultReport?.clubId, clubId)
            XCTAssertEqual(resultReport?.status, .draft)
            XCTAssertEqual(resultReport?.evaluations.count, 2)
            XCTAssertEqual(resultReport?.overallComment, "将来性のある選手")
        }
    }
    
    func testUpdateReportSuccess() {
        // テスト用データ
        let reportId = "report1"
        let userId = "user1"
        let clubId = "club1"
        let expectation = self.expectation(description: "レポート更新成功")
        
        // 更新するレポート
        let report = ScoutingReport(
            id: reportId,
            userId: userId,
            clubId: clubId,
            playerId: "player1",
            matchId: "match1",
            templateId: "template1",
            status: .draft,
            evaluations: [
                Evaluation(id: "eval1", itemId: "item1", rating: 5, comment: "素晴らしいプレー"),
                Evaluation(id: "eval2", itemId: "item2", rating: 4, comment: "良い動き")
            ],
            overallComment: "非常に将来性のある選手",
            mediaUrls: ["image1.jpg", "image2.jpg"],
            likes: 0,
            feedback: nil,
            pointsAwarded: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        // モックの設定
        let updatedReport = ScoutingReport(
            id: reportId,
            userId: userId,
            clubId: clubId,
            playerId: "player1",
            matchId: "match1",
            templateId: "template1",
            status: .submitted, // 更新後のステータス
            evaluations: report.evaluations,
            overallComment: report.overallComment,
            mediaUrls: report.mediaUrls,
            likes: 0,
            feedback: nil,
            pointsAwarded: 0,
            createdAt: report.createdAt,
            updatedAt: Date() // 更新日時
        )
        mockFirebaseManager.updateReportResult = .success(updatedReport)
        
        // テスト実行
        var resultReport: ScoutingReport?
        var resultError: Error?
        
        reportService.updateReport(report: report, newStatus: .submitted)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        resultError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { report in
                    resultReport = report
                }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        // 結果検証
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(resultError)
            XCTAssertNotNil(resultReport)
            XCTAssertEqual(resultReport?.id, reportId)
            XCTAssertEqual(resultReport?.status, .submitted) // ステータスが更新されていることを確認
            XCTAssertEqual(resultReport?.evaluations.count, 2)
            XCTAssertEqual(resultReport?.overallComment, "非常に将来性のある選手")
        }
    }
    
    func testGetUserReportsSuccess() {
        // テスト用データ
        let userId = "user1"
        let expectation = self.expectation(description: "ユーザーレポート取得成功")
        
        // モックの設定
        let reports = [
            ScoutingReport(
                id: "report1",
                userId: userId,
                clubId: "club1",
                playerId: "player1",
                matchId: "match1",
                templateId: "template1",
                status: .submitted,
                evaluations: [],
                overallComment: "コメント1",
                mediaUrls: [],
                likes: 2,
                feedback: "良いレポート",
                pointsAwarded: 50,
                createdAt: Date(),
                updatedAt: Date()
            ),
            ScoutingReport(
                id: "report2",
                userId: userId,
                clubId: "club2",
                playerId: "player2",
                matchId: "match2",
                templateId: "template2",
                status: .draft,
                evaluations: [],
                overallComment: "コメント2",
                mediaUrls: [],
                likes: 0,
                feedback: nil,
                pointsAwarded: 0,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        mockFirebaseManager.getReportsByUserResult = .success(reports)
        
        // テスト実行
        var resultReports: [ScoutingReport]?
        var resultError: Error?
        
        reportService.getUserReports(userId: userId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        resultError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { reports in
                    resultReports = reports
                }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        // 結果検証
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(resultError)
            XCTAssertNotNil(resultReports)
            XCTAssertEqual(resultReports?.count, 2)
            XCTAssertEqual(resultReports?[0].id, "report1")
            XCTAssertEqual(resultReports?[1].id, "report2")
        }
    }
    
    func testGetClubReportsSuccess() {
        // テスト用データ
        let clubId = "club1"
        let expectation = self.expectation(description: "クラブレポート取得成功")
        
        // モックの設定
        let reports = [
            ScoutingReport(
                id: "report1",
                userId: "user1",
                clubId: clubId,
                playerId: "player1",
                matchId: "match1",
                templateId: "template1",
                status: .submitted,
                evaluations: [],
                overallComment: "コメント1",
                mediaUrls: [],
                likes: 0,
                feedback: nil,
                pointsAwarded: 0,
                createdAt: Date(),
                updatedAt: Date()
            ),
            ScoutingReport(
                id: "report2",
                userId: "user2",
                clubId: clubId,
                playerId: "player2",
                matchId: "match2",
                templateId: "template1",
                status: .submitted,
                evaluations: [],
                overallComment: "コメント2",
                mediaUrls: [],
                likes: 1,
                feedback: "良い観察",
                pointsAwarded: 30,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        mockFirebaseManager.getReportsByClubResult = .success(reports)
        
        // テスト実行
        var resultReports: [ScoutingReport]?
        var resultError: Error?
        
        reportService.getClubReports(clubId: clubId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        resultError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { reports in
                    resultReports = reports
                }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        // 結果検証
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(resultError)
            XCTAssertNotNil(resultReports)
            XCTAssertEqual(resultReports?.count, 2)
            XCTAssertEqual(resultReports?[0].id, "report1")
            XCTAssertEqual(resultReports?[1].id, "report2")
        }
    }
    
    func testLikeReportSuccess() {
        // テスト用データ
        let reportId = "report1"
        let clubId = "club1"
        let expectation = self.expectation(description: "レポートいいね成功")
        
        // モックの設定
        let likedReport = ScoutingReport(
            id: reportId,
            userId: "user1",
            clubId: clubId,
            playerId: "player1",
            matchId: "match1",
            templateId: "template1",
            status: .submitted,
            evaluations: [],
            overallComment: "コメント",
            mediaUrls: [],
            likes: 1, // いいねが増加
            feedback: nil,
            pointsAwarded: 0,
            createdAt: Date(),
            updatedAt: Date()
        )
        mockFirebaseManager.likeReportResult = .success(likedReport)
        
        // テスト実行
        var resultReport: ScoutingReport?
        var resultError: Error?
        
        reportService.likeReport(reportId: reportId, clubId: clubId)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        resultError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { report in
                    resultReport = report
                }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        // 結果検証
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(resultError)
            XCTAssertNotNil(resultReport)
            XCTAssertEqual(resultReport?.id, reportId)
            XCTAssertEqual(resultReport?.likes, 1)
        }
    }
    
    func testAddFeedbackSuccess() {
        // テスト用データ
        let reportId = "report1"
        let feedback = "素晴らしい観察力です"
        let points = 50
        let expectation = self.expectation(description: "フィードバック追加成功")
        
        // モックの設定
        let updatedReport = ScoutingReport(
            id: reportId,
            userId: "user1",
            clubId: "club1",
            playerId: "player1",
            matchId: "match1",
            templateId: "template1",
            status: .reviewed, // レビュー済みに更新
            evaluations: [],
            overallComment: "コメント",
            mediaUrls: [],
            likes: 0,
            feedback: feedback, // フィードバックが追加
            pointsAwarded: points, // ポイントが付与
            createdAt: Date(),
            updatedAt: Date()
        )
        mockFirebaseManager.addFeedbackResult = .success(updatedReport)
        
        // テスト実行
        var resultReport: ScoutingReport?
        var resultError: Error?
        
        reportService.addFeedback(reportId: reportId, feedback: feedback, pointsAwarded: points)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        resultError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { report in
                    resultReport = report
                }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        // 結果検証
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(resultError)
            XCTAssertNotNil(resultReport)
            XCTAssertEqual(resultReport?.id, reportId)
            XCTAssertEqual(resultReport?.status, .reviewed)
            XCTAssertEqual(resultReport?.feedback, feedback)
            XCTAssertEqual(resultReport?.pointsAwarded, points)
        }
    }
}
