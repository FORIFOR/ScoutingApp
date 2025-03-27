import XCTest
@testable import ScoutingApp

class AuthenticationTests: XCTestCase {
    
    var authService: AuthenticationService!
    var mockFirebaseManager: MockFirebaseManager!
    
    override func setUp() {
        super.setUp()
        mockFirebaseManager = MockFirebaseManager()
        authService = AuthenticationService(firebaseManager: mockFirebaseManager)
    }
    
    override func tearDown() {
        authService = nil
        mockFirebaseManager = nil
        super.tearDown()
    }
    
    func testSignUpSuccess() {
        // テスト用データ
        let email = "test@example.com"
        let password = "password123"
        let expectation = self.expectation(description: "サインアップ成功")
        
        // モックの設定
        let mockUser = User(id: "user1", email: email, username: "テストユーザー", createdAt: Date(), updatedAt: Date())
        mockFirebaseManager.registerUserResult = .success(mockUser)
        
        // テスト実行
        var resultUser: User?
        var resultError: Error?
        
        authService.signUp(email: email, password: password)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        resultError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { user in
                    resultUser = user
                }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        // 結果検証
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(resultError)
            XCTAssertNotNil(resultUser)
            XCTAssertEqual(resultUser?.email, email)
            XCTAssertEqual(resultUser?.id, "user1")
        }
    }
    
    func testSignUpFailure() {
        // テスト用データ
        let email = "invalid@example.com"
        let password = "short"
        let expectation = self.expectation(description: "サインアップ失敗")
        
        // モックの設定
        let mockError = NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "パスワードが短すぎます"])
        mockFirebaseManager.registerUserResult = .failure(mockError)
        
        // テスト実行
        var resultUser: User?
        var resultError: Error?
        
        authService.signUp(email: email, password: password)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        resultError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { user in
                    resultUser = user
                }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        // 結果検証
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNotNil(resultError)
            XCTAssertNil(resultUser)
            XCTAssertEqual((resultError as NSError?)?.localizedDescription, "パスワードが短すぎます")
        }
    }
    
    func testSignInSuccess() {
        // テスト用データ
        let email = "existing@example.com"
        let password = "password123"
        let expectation = self.expectation(description: "サインイン成功")
        
        // モックの設定
        let mockUser = User(id: "user1", email: email, username: "テストユーザー", createdAt: Date(), updatedAt: Date())
        mockFirebaseManager.loginUserResult = .success(mockUser)
        
        // テスト実行
        var resultUser: User?
        var resultError: Error?
        
        authService.signIn(email: email, password: password)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        resultError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { user in
                    resultUser = user
                }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        // 結果検証
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNil(resultError)
            XCTAssertNotNil(resultUser)
            XCTAssertEqual(resultUser?.email, email)
            XCTAssertEqual(resultUser?.id, "user1")
        }
    }
    
    func testSignInFailure() {
        // テスト用データ
        let email = "nonexistent@example.com"
        let password = "wrongpassword"
        let expectation = self.expectation(description: "サインイン失敗")
        
        // モックの設定
        let mockError = NSError(domain: "AuthError", code: 2, userInfo: [NSLocalizedDescriptionKey: "メールアドレスまたはパスワードが間違っています"])
        mockFirebaseManager.loginUserResult = .failure(mockError)
        
        // テスト実行
        var resultUser: User?
        var resultError: Error?
        
        authService.signIn(email: email, password: password)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        resultError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { user in
                    resultUser = user
                }
            )
            .store(in: &mockFirebaseManager.cancellables)
        
        // 結果検証
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
            XCTAssertNotNil(resultError)
            XCTAssertNil(resultUser)
            XCTAssertEqual((resultError as NSError?)?.localizedDescription, "メールアドレスまたはパスワードが間違っています")
        }
    }
    
    func testSignOut() {
        // テスト用データ
        let expectation = self.expectation(description: "サインアウト成功")
        
        // モックの設定
        mockFirebaseManager.logoutUserResult = .success(())
        
        // テスト実行
        var resultError: Error?
        
        authService.signOut()
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
        }
    }
}

// モックFirebaseManager
class MockFirebaseManager: FirebaseManagerProtocol {
    var registerUserResult: Result<User, Error>?
    var loginUserResult: Result<User, Error>?
    var logoutUserResult: Result<Void, Error>?
    var getUserResult: Result<User, Error>?
    var updateUserResult: Result<User, Error>?
    var getClubsResult: Result<[Club], Error>?
    var getClubResult: Result<Club, Error>?
    var getMatchesResult: Result<[Match], Error>?
    var getMatchResult: Result<Match, Error>?
    var getReportTemplatesResult: Result<[ReportTemplate], Error>?
    var createReportResult: Result<ScoutingReport, Error>?
    var updateReportResult: Result<ScoutingReport, Error>?
    var getReportsByUserResult: Result<[ScoutingReport], Error>?
    var getReportsByClubResult: Result<[ScoutingReport], Error>?
    var likeReportResult: Result<ScoutingReport, Error>?
    var addFeedbackResult: Result<ScoutingReport, Error>?
    var getUserPointsResult: Result<Int, Error>?
    var getPointHistoryResult: Result<[PointHistory], Error>?
    var addPointsResult: Result<Int, Error>?
    var redeemPointsResult: Result<Int, Error>?
    var getRewardItemsResult: Result<[RewardItem], Error>?
    var redeemRewardResult: Result<RewardRedemption, Error>?
    
    var cancellables = Set<AnyCancellable>()
    
    func registerUser(email: String, password: String) -> AnyPublisher<User, Error> {
        guard let result = registerUserResult else {
            fatalError("registerUserResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func loginUser(email: String, password: String) -> AnyPublisher<User, Error> {
        guard let result = loginUserResult else {
            fatalError("loginUserResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func logoutUser() -> AnyPublisher<Void, Error> {
        guard let result = logoutUserResult else {
            fatalError("logoutUserResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func getUser(userId: String) -> AnyPublisher<User, Error> {
        guard let result = getUserResult else {
            fatalError("getUserResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func updateUser(user: User) -> AnyPublisher<User, Error> {
        guard let result = updateUserResult else {
            fatalError("updateUserResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func getClubs() -> AnyPublisher<[Club], Error> {
        guard let result = getClubsResult else {
            fatalError("getClubsResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func getClub(clubId: String) -> AnyPublisher<Club, Error> {
        guard let result = getClubResult else {
            fatalError("getClubResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func getMatches(region: String?, date: DateFilter?, category: String?) -> AnyPublisher<[Match], Error> {
        guard let result = getMatchesResult else {
            fatalError("getMatchesResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func getMatch(matchId: String) -> AnyPublisher<Match, Error> {
        guard let result = getMatchResult else {
            fatalError("getMatchResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func getReportTemplates(clubId: String) -> AnyPublisher<[ReportTemplate], Error> {
        guard let result = getReportTemplatesResult else {
            fatalError("getReportTemplatesResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func createReport(report: ScoutingReport) -> AnyPublisher<ScoutingReport, Error> {
        guard let result = createReportResult else {
            fatalError("createReportResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func updateReport(report: ScoutingReport) -> AnyPublisher<ScoutingReport, Error> {
        guard let result = updateReportResult else {
            fatalError("updateReportResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func getReportsByUser(userId: String, status: ReportStatus?) -> AnyPublisher<[ScoutingReport], Error> {
        guard let result = getReportsByUserResult else {
            fatalError("getReportsByUserResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func getReportsByClub(clubId: String) -> AnyPublisher<[ScoutingReport], Error> {
        guard let result = getReportsByClubResult else {
            fatalError("getReportsByClubResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func likeReport(reportId: String, clubId: String) -> AnyPublisher<ScoutingReport, Error> {
        guard let result = likeReportResult else {
            fatalError("likeReportResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func addFeedback(reportId: String, feedback: String, pointsAwarded: Int) -> AnyPublisher<ScoutingReport, Error> {
        guard let result = addFeedbackResult else {
            fatalError("addFeedbackResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func getUserPoints(userId: String) -> AnyPublisher<Int, Error> {
        guard let result = getUserPointsResult else {
            fatalError("getUserPointsResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func getPointHistory(userId: String) -> AnyPublisher<[PointHistory], Error> {
        guard let result = getPointHistoryResult else {
            fatalError("getPointHistoryResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func addPoints(userId: String, amount: Int, type: PointType, description: String, relatedId: String?) -> AnyPublisher<Int, Error> {
        guard let result = addPointsResult else {
            fatalError("addPointsResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func redeemPoints(userId: String, amount: Int, description: String) -> AnyPublisher<Int, Error> {
        guard let result = redeemPointsResult else {
            fatalError("redeemPointsResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func getRewardItems() -> AnyPublisher<[RewardItem], Error> {
        guard let result = getRewardItemsResult else {
            fatalError("getRewardItemsResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
    
    func redeemReward(userId: String, rewardId: String) -> AnyPublisher<RewardRedemption, Error> {
        guard let result = redeemRewardResult else {
            fatalError("redeemRewardResult not set")
        }
        
        return result.publisher.eraseToAnyPublisher()
    }
}
