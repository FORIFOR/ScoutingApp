import XCTest
@testable import ScoutingApp

class PerformanceTests: XCTestCase {
    
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
    
    func testReportListLoadingPerformance() {
        // 大量のレポートデータを準備
        let userId = "user1"
        let reports = generateLargeReportList(count: 100, userId: userId)
        mockFirebaseManager.getReportsByUserResult = .success(reports)
        
        // パフォーマンス測定
        measure {
            // 期待値
            let expectation = self.expectation(description: "レポート一覧読み込みパフォーマンス")
            
            // テスト実行
            var resultReports: [ScoutingReport]?
            
            reportService.getUserReports(userId: userId)
                .sink(
                    receiveCompletion: { completion in
                        expectation.fulfill()
                    },
                    receiveValue: { reports in
                        resultReports = reports
                    }
                )
                .store(in: &mockFirebaseManager.cancellables)
            
            // 待機
            waitForExpectations(timeout: 1.0) { error in
                XCTAssertNil(error)
                XCTAssertEqual(resultReports?.count, 100)
            }
        }
    }
    
    func testReportFilteringPerformance() {
        // 大量のレポートデータを準備
        let userId = "user1"
        let reports = generateLargeReportList(count: 100, userId: userId)
        mockFirebaseManager.getReportsByUserResult = .success(reports)
        
        // パフォーマンス測定
        measure {
            // 期待値
            let expectation = self.expectation(description: "レポートフィルタリングパフォーマンス")
            
            // テスト実行
            var resultReports: [ScoutingReport]?
            
            reportService.getUserReports(userId: userId, status: .submitted)
                .sink(
                    receiveCompletion: { completion in
                        expectation.fulfill()
                    },
                    receiveValue: { reports in
                        resultReports = reports
                    }
                )
                .store(in: &mockFirebaseManager.cancellables)
            
            // 待機
            waitForExpectations(timeout: 1.0) { error in
                XCTAssertNil(error)
                // 約半数がsubmitted状態
                XCTAssertEqual(resultReports?.count, 50, accuracy: 10)
            }
        }
    }
    
    func testReportSortingPerformance() {
        // 大量のレポートデータを準備
        let userId = "user1"
        let reports = generateLargeReportList(count: 100, userId: userId)
        mockFirebaseManager.getReportsByUserResult = .success(reports)
        
        // パフォーマンス測定
        measure {
            // 期待値
            let expectation = self.expectation(description: "レポートソートパフォーマンス")
            
            // テスト実行
            var resultReports: [ScoutingReport]?
            
            reportService.getUserReportsSortedByDate(userId: userId)
                .sink(
                    receiveCompletion: { completion in
                        expectation.fulfill()
                    },
                    receiveValue: { reports in
                        resultReports = reports
                    }
                )
                .store(in: &mockFirebaseManager.cancellables)
            
            // 待機
            waitForExpectations(timeout: 1.0) { error in
                XCTAssertNil(error)
                XCTAssertEqual(resultReports?.count, 100)
                
                // ソートが正しく行われていることを確認
                if let reports = resultReports, reports.count > 1 {
                    for i in 0..<reports.count-1 {
                        XCTAssertGreaterThanOrEqual(reports[i].createdAt, reports[i+1].createdAt)
                    }
                }
            }
        }
    }
    
    func testImageProcessingPerformance() {
        // 画像処理のパフォーマンス測定
        measure {
            // 期待値
            let expectation = self.expectation(description: "画像処理パフォーマンス")
            
            // テスト実行
            DispatchQueue.global().async {
                // 画像処理をシミュレート
                let imageSize = CGSize(width: 1920, height: 1080)
                let renderer = UIGraphicsImageRenderer(size: imageSize)
                let image = renderer.image { ctx in
                    UIColor.white.setFill()
                    ctx.fill(CGRect(origin: .zero, size: imageSize))
                    
                    // 複雑な描画処理
                    for i in 0..<100 {
                        let rect = CGRect(x: CGFloat.random(in: 0...imageSize.width),
                                         y: CGFloat.random(in: 0...imageSize.height),
                                         width: CGFloat.random(in: 10...100),
                                         height: CGFloat.random(in: 10...100))
                        
                        UIColor(red: CGFloat.random(in: 0...1),
                                green: CGFloat.random(in: 0...1),
                                blue: CGFloat.random(in: 0...1),
                                alpha: 1.0).setFill()
                        
                        ctx.fill(rect)
                    }
                }
                
                // 画像の圧縮処理
                let compressedData = image.jpegData(compressionQuality: 0.7)
                XCTAssertNotNil(compressedData)
                
                // 画像のリサイズ処理
                let resizedImage = self.resizeImage(image, targetSize: CGSize(width: 800, height: 450))
                XCTAssertNotNil(resizedImage)
                
                DispatchQueue.main.async {
                    expectation.fulfill()
                }
            }
            
            // 待機
            waitForExpectations(timeout: 5.0) { error in
                XCTAssertNil(error)
            }
        }
    }
    
    func testDataSyncPerformance() {
        // 大量のデータを準備
        let userId = "user1"
        let reports = generateLargeReportList(count: 50, userId: userId)
        let matches = generateLargeMatchList(count: 30)
        let pointHistory = generateLargePointHistoryList(count: 20, userId: userId)
        
        mockFirebaseManager.getReportsByUserResult = .success(reports)
        mockFirebaseManager.getMatchesResult = .success(matches)
        mockFirebaseManager.getPointHistoryResult = .success(pointHistory)
        
        // SyncManagerを作成
        let mockLocalDataManager = MockLocalDataManager()
        let syncManager = SyncManager(firebaseManager: mockFirebaseManager, localDataManager: mockLocalDataManager)
        
        // パフォーマンス測定
        measure {
            // 期待値
            let expectation = self.expectation(description: "データ同期パフォーマンス")
            
            // テスト実行
            syncManager.syncAllData(userId: userId)
                .sink(
                    receiveCompletion: { completion in
                        expectation.fulfill()
                    },
                    receiveValue: { _ in }
                )
                .store(in: &mockFirebaseManager.cancellables)
            
            // 待機
            waitForExpectations(timeout: 2.0) { error in
                XCTAssertNil(error)
                XCTAssertEqual(mockLocalDataManager.savedReports?.count, 50)
                XCTAssertEqual(mockLocalDataManager.savedMatches?.count, 30)
                XCTAssertEqual(mockLocalDataManager.savedPointHistory?.count, 20)
            }
        }
    }
    
    // ヘルパーメソッド
    
    private func generateLargeReportList(count: Int, userId: String) -> [ScoutingReport] {
        var reports: [ScoutingReport] = []
        
        for i in 0..<count {
            let status: ReportStatus = i % 2 == 0 ? .submitted : .draft
            let createdAt = Date().addingTimeInterval(-Double(i * 3600)) // 1時間ごとに古くなる
            
            let report = ScoutingReport(
                id: "report\(i)",
                userId: userId,
                clubId: "club\(i % 5 + 1)",
                playerId: "player\(i % 20 + 1)",
                matchId: "match\(i % 15 + 1)",
                templateId: "template\(i % 3 + 1)",
                status: status,
                evaluations: [
                    Evaluation(id: "eval\(i)_1", itemId: "item1", rating: Int.random(in: 1...5), comment: "コメント\(i)_1"),
                    Evaluation(id: "eval\(i)_2", itemId: "item2", rating: Int.random(in: 1...5), comment: "コメント\(i)_2")
                ],
                overallComment: "全体コメント\(i)",
                mediaUrls: i % 3 == 0 ? ["image\(i)_1.jpg", "image\(i)_2.jpg"] : [],
                likes: i % 5,
                feedback: i % 4 == 0 ? "フィードバック\(i)" : nil,
                pointsAwarded: i % 4 == 0 ? i * 10 : 0,
                createdAt: createdAt,
                updatedAt: createdAt.addingTimeInterval(1800) // 30分後に更新
            )
            
            reports.append(report)
        }
        
        return reports
    }
    
    private func generateLargeMatchList(count: Int) -> [Match] {
        var matches: [Match] = []
        
        for i in 0..<count {
            let date = Date().addingTimeInterval(Double(i * 86400)) // 1日ごとに未来
            
            let match = Match(
                id: "match\(i)",
                homeTeamId: "team\(i % 10 + 1)",
                awayTeamId: "team\((i + 5) % 10 + 1)",
                date: date,
                venue: "スタジアム\(i % 5 + 1)",
                category: i % 3 == 0 ? "J1" : (i % 3 == 1 ? "J2" : "J3"),
                status: .scheduled,
                createdAt: Date().addingTimeInterval(-Double(i * 3600)),
                updatedAt: Date()
            )
            
            matches.append(match)
        }
        
        return matches
    }
    
    private func generateLargePointHistoryList(count: Int, userId: String) -> [PointHistory] {
        var history: [PointHistory] = []
        
        for i in 0..<count {
            let date = Date().addingTimeInterval(-Double(i * 86400)) // 1日ごとに過去
            let type: PointType = i % 3 == 0 ? .earned : (i % 3 == 1 ? .redeemed : .bonus)
            let amount = type == .redeemed ? -(i * 10 + 50) : (i * 10 + 20)
            
            let pointHistory = PointHistory(
                id: "history\(i)",
                userId: userId,
                amount: amount,
                type: type,
                description: "ポイント履歴\(i)",
                relatedId: type == .earned ? "report\(i)" : nil,
                createdAt: date
            )
            
            history.append(pointHistory)
        }
        
        return history
    }
    
    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
