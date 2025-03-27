import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth
import Combine

// Firebaseデータベース設計実装
class FirebaseManager {
    // シングルトンインスタンス
    static let shared = FirebaseManager()
    
    // Firestoreインスタンス
    private let db: Firestore
    
    // 初期化
    private init() {
        // Firebase初期化
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // Firestoreインスタンス取得
        db = Firestore.firestore()
        
        // 設定
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true // オフラインサポート
        db.settings = settings
    }
    
    // MARK: - ユーザー関連
    
    // ユーザー登録
    func registerUser(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let authUser = authResult?.user else {
                    promise(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "ユーザー情報の取得に失敗しました"])))
                    return
                }
                
                let user = User(
                    id: authUser.uid,
                    email: email,
                    username: email.components(separatedBy: "@").first ?? "ユーザー",
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                // Firestoreにユーザー情報を保存
                self.db.collection("users").document(user.id).setData([
                    "id": user.id,
                    "email": user.email,
                    "username": user.username,
                    "favoriteClub": user.favoriteClub as Any,
                    "region": user.region as Any,
                    "bio": user.bio as Any,
                    "profileImageUrl": user.profileImageUrl as Any,
                    "createdAt": Timestamp(date: user.createdAt),
                    "updatedAt": Timestamp(date: user.updatedAt),
                    "isClubUser": user.isClubUser,
                    "points": user.points
                ]) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(user))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // ユーザーログイン
    func loginUser(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let authUser = authResult?.user else {
                    promise(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "ユーザー情報の取得に失敗しました"])))
                    return
                }
                
                // Firestoreからユーザー情報を取得
                self.db.collection("users").document(authUser.uid).getDocument { document, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let document = document, document.exists, let data = document.data() else {
                        promise(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "ユーザー情報の取得に失敗しました"])))
                        return
                    }
                    
                    let user = self.parseUserData(data: data)
                    promise(.success(user))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // ユーザーログアウト
    func logoutUser() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    // ユーザー情報更新
    func updateUser(user: User) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            let updatedUser = user
            updatedUser.updatedAt = Date()
            
            self.db.collection("users").document(user.id).updateData([
                "username": updatedUser.username,
                "favoriteClub": updatedUser.favoriteClub as Any,
                "region": updatedUser.region as Any,
                "bio": updatedUser.bio as Any,
                "profileImageUrl": updatedUser.profileImageUrl as Any,
                "updatedAt": Timestamp(date: updatedUser.updatedAt),
                "isClubUser": updatedUser.isClubUser,
                "points": updatedUser.points
            ]) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(updatedUser))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // ユーザー情報取得
    func getUser(userId: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            self.db.collection("users").document(userId).getDocument { document, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let document = document, document.exists, let data = document.data() else {
                    promise(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "ユーザー情報の取得に失敗しました"])))
                    return
                }
                
                let user = self.parseUserData(data: data)
                promise(.success(user))
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - クラブ関連
    
    // クラブ一覧取得
    func getClubs() -> AnyPublisher<[Club], Error> {
        return Future<[Club], Error> { promise in
            self.db.collection("clubs").getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    promise(.success([]))
                    return
                }
                
                let clubs = documents.compactMap { document -> Club? in
                    guard let data = document.data() as? [String: Any] else { return nil }
                    return self.parseClubData(data: data)
                }
                
                promise(.success(clubs))
            }
        }.eraseToAnyPublisher()
    }
    
    // クラブ情報取得
    func getClub(clubId: String) -> AnyPublisher<Club, Error> {
        return Future<Club, Error> { promise in
            self.db.collection("clubs").document(clubId).getDocument { document, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let document = document, document.exists, let data = document.data() else {
                    promise(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "クラブ情報の取得に失敗しました"])))
                    return
                }
                
                let club = self.parseClubData(data: data)
                promise(.success(club))
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - 試合関連
    
    // 試合一覧取得
    func getMatches(region: String? = nil, date: DateFilter? = nil, category: String? = nil) -> AnyPublisher<[Match], Error> {
        return Future<[Match], Error> { promise in
            var query: Query = self.db.collection("matches")
            
            // フィルタリング
            if let region = region {
                query = query.whereField("region", isEqualTo: region)
            }
            
            if let category = category {
                query = query.whereField("category", isEqualTo: category)
            }
            
            if let date = date {
                let calendar = Calendar.current
                let today = Date()
                
                switch date {
                case .today:
                    let startOfDay = calendar.startOfDay(for: today)
                    let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                    query = query.whereField("date", isGreaterThanOrEqualTo: startOfDay)
                        .whereField("date", isLessThan: endOfDay)
                    
                case .tomorrow:
                    let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: today))!
                    let endOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfTomorrow)!
                    query = query.whereField("date", isGreaterThanOrEqualTo: startOfTomorrow)
                        .whereField("date", isLessThan: endOfTomorrow)
                    
                case .thisWeek:
                    let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                    let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
                    query = query.whereField("date", isGreaterThanOrEqualTo: startOfWeek)
                        .whereField("date", isLessThan: endOfWeek)
                    
                case .nextWeek:
                    let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                    let startOfNextWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
                    let endOfNextWeek = calendar.date(byAdding: .day, value: 7, to: startOfNextWeek)!
                    query = query.whereField("date", isGreaterThanOrEqualTo: startOfNextWeek)
                        .whereField("date", isLessThan: endOfNextWeek)
                    
                case .thisMonth:
                    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
                    let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
                    query = query.whereField("date", isGreaterThanOrEqualTo: startOfMonth)
                        .whereField("date", isLessThan: nextMonth)
                }
            }
            
            // 日付順にソート
            query = query.order(by: "date")
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    promise(.success([]))
                    return
                }
                
                let matches = documents.compactMap { document -> Match? in
                    guard let data = document.data() as? [String: Any] else { return nil }
                    return self.parseMatchData(data: data)
                }
                
                promise(.success(matches))
            }
        }.eraseToAnyPublisher()
    }
    
    // 試合詳細取得
    func getMatch(matchId: String) -> AnyPublisher<Match, Error> {
        return Future<Match, Error> { promise in
            self.db.collection("matches").document(matchId).getDocument { document, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let document = document, document.exists, let data = document.data() else {
                    promise(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "試合情報の取得に失敗しました"])))
                    return
                }
                
                let match = self.parseMatchData(data: data)
                promise(.success(match))
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - レポート関連
    
    // レポートテンプレート一覧取得
    func getReportTemplates(clubId: String) -> AnyPublisher<[ReportTemplate], Error> {
        return Future<[ReportTemplate], Error> { promise in
            self.db.collection("reportTemplates")
                .whereField("clubId", isEqualTo: clubId)
                .whereField("isActive", isEqualTo: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    let templates = documents.compactMap { document -> ReportTemplate? in
                        guard let data = document.data() as? [String: Any] else { return nil }
                        return self.parseReportTemplateData(data: data)
                    }
                    
                    promise(.success(templates))
                }
        }.eraseToAnyPublisher()
    }
    
    // レポート作成
    func createReport(report: ScoutingReport) -> AnyPublisher<ScoutingReport, Error> {
        return Future<ScoutingReport, Error> { promise in
            let reportId = report.id.isEmpty ? UUID().uuidString : report.id
            var newReport = report
            newReport.id = reportId
            newReport.createdAt = Date()
            newReport.updatedAt = Date()
            
            let reportData: [String: Any] = [
                "id": newReport.id,
                "userId": newReport.userId,
                "clubId": newReport.clubId,
                "playerId": newReport.playerId,
                "matchId": newReport.matchId,
                "templateId": newReport.templateId,
                "status": newReport.status.rawValue,
                "evaluations": newReport.evaluations.map { evaluation in
                    return [
                        "id": evaluation.id,
                        "itemId": evaluation.itemId,
                        "rating": evaluation.rating,
                        "comment": evaluation.comment as Any
                    ]
                },
                "overallComment": newReport.overallComment as Any,
                "mediaUrls": newReport.mediaUrls,
                "likes": newReport.likes,
                "feedback": newReport.feedback as Any,
                "pointsAwarded": newReport.pointsAwarded,
                "createdAt": Timestamp(date: newReport.createdAt),
                "updatedAt": Timestamp(date: newReport.updatedAt)
            ]
            
            self.db.collection("reports").document(reportId).setData(reportData) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(newReport))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // レポート更新
    func updateReport(report: ScoutingReport) -> AnyPublisher<ScoutingReport, Error> {
        return Future<ScoutingReport, Error> { promise in
            var updatedReport = report
            updatedReport.updatedAt = Date()
            
            let reportData: [String: Any] = [
                "status": updatedReport.status.rawValue,
                "evaluations": updatedReport.evaluations.map { evaluation in
                    return [
                        "id": evaluation.id,
                        "itemId": evaluation.itemId,
                        "rating": evaluation.rating,
                        "comment": evaluation.comment as Any
                    ]
                },
                "overallComment": updatedReport.overallComment as Any,
                "mediaUrls": updatedReport.mediaUrls,
                "likes": updatedReport.likes,
                "feedback": updatedReport.feedback as Any,
                "pointsAwarded": updatedReport.pointsAwarded,
                "updatedAt": Timestamp(date: updatedReport.updatedAt)
            ]
            
            self.db.collection("reports").document(report.id).updateData(reportData) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(updatedReport))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // ユーザーのレポート一覧取得
    func getReportsByUser(userId: String, status: ReportStatus? = nil) -> AnyPublisher<[ScoutingReport], Error> {
        return Future<[ScoutingReport], Error> { promise in
            var query: Query = self.db.collection("reports").whereField("userId", isEqualTo: userId)
            
            if let status = status {
                query = query.whereField("status", isEqualTo: status.rawValue)
            }
            
            query.order(by: "createdAt", descending: true).getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    promise(.success([]))
                    return
                }
                
                let reports = documents.compactMap { document -> ScoutingReport? in
                    guard let data = document.data() as? [String: Any] else { return nil }
                    return self.parseReportData(data: data)
                }
                
                promise(.success(reports))
            }
        }.eraseToAnyPublisher()
    }
    
    // クラブのレポート一覧取得
    func getReportsByClub(clubId: String) -> AnyPublisher<[ScoutingReport], Error> {
        return Future<[ScoutingReport], Error> { promise in
            self.db.collection("reports")
                .whereField("clubId", isEqualTo: clubId)
                .whereField("status", isEqualTo: ReportStatus.submitted.rawValue)
                .order(by: "createdAt", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    let reports = documents.compactMap { document -> ScoutingReport? in
                        guard let data = document.data() as? [String: Any] else { return nil }
                        return self.parseReportData(data: data)
                    }
                    
                    promise(.success(reports))
                }
        }.eraseToAnyPublisher()
    }
    
    // レポートにいいねを付ける
    func likeReport(reportId: String, clubId: String) -> AnyPublisher<ScoutingReport, Error> {
        return Future<ScoutingReport, Error> { promise in
            let reportRef = self.db.collection("reports").document(reportId)
            
            self.db.runTransaction({ (transaction, errorPointer) -> Any? in
                let reportDocument: DocumentSnapshot
                do {
                    try reportDocument = transaction.getDocument(reportRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                guard let data = reportDocument.data() else {
                    let error = NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "レポートデータの取得に失敗しました"])
                    errorPointer?.pointee = error
                    return nil
                }
                
                let currentLikes = data["likes"] as? Int ?? 0
                transaction.updateData(["likes": currentLikes + 1], forDocument: reportRef)
                
                return data
            }) { (updatedData, error) in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let data = updatedData as? [String: Any] else {
                    promise(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "レポートデータの更新に失敗しました"])))
                    return
                }
                
                var report = self.parseReportData(data: data)
                report.likes += 1
                
                promise(.success(report))
            }
        }.eraseToAnyPublisher()
    }
    
    // レポートにフィードバックを追加
    func addFeedback(reportId: String, feedback: String, pointsAwarded: Int) -> AnyPublisher<ScoutingReport, Error> {
        return Future<ScoutingReport, Error> { promise in
            let reportRef = self.db.collection("reports").document(reportId)
            
            reportRef.getDocument { document, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let document = document, document.exists, var report = self.parseReportData(data: document.data() ?? [:]) else {
                    promise(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "レポートの取得に失敗しました"])))
                    return
                }
                
                report.feedback = feedback
                report.pointsAwarded = pointsAwarded
                report.status = .reviewed
                report.updatedAt = Date()
                
                reportRef.updateData([
                    "feedback": feedback,
                    "pointsAwarded": pointsAwarded,
                    "status": ReportStatus.reviewed.rawValue,
                    "updatedAt": Timestamp(date: report.updatedAt)
                ]) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        // ポイント履歴を追加
                        self.addPointHistory(
                            userId: report.userId,
                            amount: pointsAwarded,
                            type: .earned,
                            description: "レポートへのフィードバック報酬",
                            relatedId: reportId
                        )
                        
                        // ユーザーのポイントを更新
                        self.updateUserPoints(userId: report.userId, pointsToAdd: pointsAwarded)
                        
                        promise(.success(report))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - 報酬関連
    
    // ユーザーのポイント取得
    func getUserPoints(userId: String) -> AnyPublisher<Int, Error> {
        return Future<Int, Error> { promise in
            self.db.collection("users").document(userId).getDocument { document, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let document = document, document.exists, let data = document.data() else {
                    promise(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "ユーザー情報の取得に失敗しました"])))
                    return
                }
                
                let points = data["points"] as? Int ?? 0
                promise(.success(points))
            }
        }.eraseToAnyPublisher()
    }
    
    // ポイント履歴取得
    func getPointHistory(userId: String) -> AnyPublisher<[PointHistory], Error> {
        return Future<[PointHistory], Error> { promise in
            self.db.collection("pointHistory")
                .whereField("userId", isEqualTo: userId)
                .order(by: "createdAt", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    let history = documents.compactMap { document -> PointHistory? in
                        guard let data = document.data() as? [String: Any] else { return nil }
                        return self.parsePointHistoryData(data: data)
                    }
                    
                    promise(.success(history))
                }
        }.eraseToAnyPublisher()
    }
    
    // ポイント追加
    func addPoints(userId: String, amount: Int, type: PointType, description: String, relatedId: String? = nil) -> AnyPublisher<Int, Error> {
        return Future<Int, Error> { promise in
            // ポイント履歴を追加
            self.addPointHistory(userId: userId, amount: amount, type: type, description: description, relatedId: relatedId)
            
            // ユーザーのポイントを更新
            self.updateUserPoints(userId: userId, pointsToAdd: amount) { result in
                switch result {
                case .success(let newPoints):
                    promise(.success(newPoints))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // ポイント使用
    func redeemPoints(userId: String, amount: Int, description: String) -> AnyPublisher<Int, Error> {
        return Future<Int, Error> { promise in
            // 現在のポイントを確認
            self.getUserPoints(userId: userId)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    },
                    receiveValue: { currentPoints in
                        if currentPoints < amount {
                            promise(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "ポイントが不足しています"])))
                            return
                        }
                        
                        // ポイント履歴を追加
                        self.addPointHistory(userId: userId, amount: -amount, type: .redeemed, description: description)
                        
                        // ユーザーのポイントを更新
                        self.updateUserPoints(userId: userId, pointsToAdd: -amount) { result in
                            switch result {
                            case .success(let newPoints):
                                promise(.success(newPoints))
                            case .failure(let error):
                                promise(.failure(error))
                            }
                        }
                    }
                )
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    // 報酬アイテム一覧取得
    func getRewardItems() -> AnyPublisher<[RewardItem], Error> {
        return Future<[RewardItem], Error> { promise in
            self.db.collection("rewardItems")
                .whereField("isAvailable", isEqualTo: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }
                    
                    let items = documents.compactMap { document -> RewardItem? in
                        guard let data = document.data() as? [String: Any] else { return nil }
                        return self.parseRewardItemData(data: data)
                    }
                    
                    promise(.success(items))
                }
        }.eraseToAnyPublisher()
    }
    
    // 報酬交換
    func redeemReward(userId: String, rewardId: String) -> AnyPublisher<RewardRedemption, Error> {
        return Future<RewardRedemption, Error> { promise in
            // 報酬アイテム情報を取得
            self.db.collection("rewardItems").document(rewardId).getDocument { document, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let document = document, document.exists, let data = document.data() else {
                    promise(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "報酬アイテムの取得に失敗しました"])))
                    return
                }
                
                let rewardItem = self.parseRewardItemData(data: data)
                
                // ポイントが足りるか確認
                self.getUserPoints(userId: userId)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                promise(.failure(error))
                            }
                        },
                        receiveValue: { currentPoints in
                            if currentPoints < rewardItem.pointCost {
                                promise(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "ポイントが不足しています"])))
                                return
                            }
                            
                            // 交換履歴を作成
                            let redemptionId = UUID().uuidString
                            let redemptionCode = "REWARD-\(Int.random(in: 10000...99999))"
                            let redemption = RewardRedemption(
                                id: redemptionId,
                                userId: userId,
                                rewardId: rewardId,
                                reward: rewardItem,
                                pointsUsed: rewardItem.pointCost,
                                status: .completed,
                                redemptionCode: redemptionCode
                            )
                            
                            // Firestoreに交換履歴を保存
                            self.db.collection("redemptions").document(redemptionId).setData([
                                "id": redemption.id,
                                "userId": redemption.userId,
                                "rewardId": redemption.rewardId,
                                "pointsUsed": redemption.pointsUsed,
                                "status": redemption.status.rawValue,
                                "redemptionCode": redemption.redemptionCode as Any,
                                "createdAt": Timestamp(date: redemption.createdAt),
                                "updatedAt": Timestamp(date: redemption.updatedAt)
                            ]) { error in
                                if let error = error {
                                    promise(.failure(error))
                                    return
                                }
                                
                                // ポイントを使用
                                self.redeemPoints(userId: userId, amount: rewardItem.pointCost, description: "\(rewardItem.name)と交換")
                                    .sink(
                                        receiveCompletion: { completion in
                                            if case .failure(let error) = completion {
                                                promise(.failure(error))
                                            }
                                        },
                                        receiveValue: { _ in
                                            promise(.success(redemption))
                                        }
                                    )
                                    .store(in: &self.cancellables)
                            }
                        }
                    )
                    .store(in: &self.cancellables)
            }
        }.eraseToAnyPublisher()
    }
    
    // MARK: - ヘルパーメソッド
    
    // ポイント履歴追加（内部メソッド）
    private func addPointHistory(userId: String, amount: Int, type: PointType, description: String, relatedId: String? = nil) {
        let historyId = UUID().uuidString
        let createdAt = Date()
        
        self.db.collection("pointHistory").document(historyId).setData([
            "id": historyId,
            "userId": userId,
            "amount": amount,
            "type": type.rawValue,
            "description": description,
            "relatedId": relatedId as Any,
            "createdAt": Timestamp(date: createdAt)
        ])
    }
    
    // ユーザーポイント更新（内部メソッド）
    private func updateUserPoints(userId: String, pointsToAdd: Int, completion: ((Result<Int, Error>) -> Void)? = nil) {
        let userRef = self.db.collection("users").document(userId)
        
        self.db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let data = userDocument.data() else {
                let error = NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "ユーザーデータの取得に失敗しました"])
                errorPointer?.pointee = error
                return nil
            }
            
            let currentPoints = data["points"] as? Int ?? 0
            let newPoints = max(0, currentPoints + pointsToAdd) // ポイントが0未満にならないようにする
            
            transaction.updateData(["points": newPoints], forDocument: userRef)
            
            return newPoints
        }) { (result, error) in
            if let error = error {
                completion?(.failure(error))
                return
            }
            
            guard let newPoints = result as? Int else {
                completion?(.failure(NSError(domain: "FirebaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "ポイント更新に失敗しました"])))
                return
            }
            
            completion?(.success(newPoints))
        }
    }
    
    // MARK: - データパース
    
    // ユーザーデータのパース
    private func parseUserData(data: [String: Any]) -> User {
        let id = data["id"] as? String ?? ""
        let email = data["email"] as? String ?? ""
        let username = data["username"] as? String ?? ""
        let favoriteClub = data["favoriteClub"] as? String
        let region = data["region"] as? String
        let bio = data["bio"] as? String
        let profileImageUrl = data["profileImageUrl"] as? String
        let isClubUser = data["isClubUser"] as? Bool ?? false
        let points = data["points"] as? Int ?? 0
        
        let createdAtTimestamp = data["createdAt"] as? Timestamp
        let updatedAtTimestamp = data["updatedAt"] as? Timestamp
        
        let createdAt = createdAtTimestamp?.dateValue() ?? Date()
        let updatedAt = updatedAtTimestamp?.dateValue() ?? Date()
        
        return User(
            id: id,
            email: email,
            username: username,
            favoriteClub: favoriteClub,
            region: region,
            bio: bio,
            profileImageUrl: profileImageUrl,
            createdAt: createdAt,
            updatedAt: updatedAt,
            isClubUser: isClubUser,
            points: points
        )
    }
    
    // クラブデータのパース
    private func parseClubData(data: [String: Any]) -> Club {
        let id = data["id"] as? String ?? ""
        let name = data["name"] as? String ?? ""
        let logoUrl = data["logoUrl"] as? String
        let description = data["description"] as? String
        let category = data["category"] as? String ?? ""
        let region = data["region"] as? String ?? ""
        
        let createdAtTimestamp = data["createdAt"] as? Timestamp
        let updatedAtTimestamp = data["updatedAt"] as? Timestamp
        
        let createdAt = createdAtTimestamp?.dateValue() ?? Date()
        let updatedAt = updatedAtTimestamp?.dateValue() ?? Date()
        
        return Club(
            id: id,
            name: name,
            logoUrl: logoUrl,
            description: description,
            category: category,
            region: region,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    // 試合データのパース
    private func parseMatchData(data: [String: Any]) -> Match {
        let id = data["id"] as? String ?? ""
        let homeTeamId = data["homeTeamId"] as? String ?? ""
        let awayTeamId = data["awayTeamId"] as? String ?? ""
        let venue = data["venue"] as? String ?? ""
        let category = data["category"] as? String ?? ""
        let statusString = data["status"] as? String ?? MatchStatus.scheduled.rawValue
        let interestedClubs = data["interestedClubs"] as? [String] ?? []
        
        let dateTimestamp = data["date"] as? Timestamp
        let createdAtTimestamp = data["createdAt"] as? Timestamp
        let updatedAtTimestamp = data["updatedAt"] as? Timestamp
        
        let date = dateTimestamp?.dateValue() ?? Date()
        let createdAt = createdAtTimestamp?.dateValue() ?? Date()
        let updatedAt = updatedAtTimestamp?.dateValue() ?? Date()
        
        let status = MatchStatus(rawValue: statusString) ?? .scheduled
        
        return Match(
            id: id,
            homeTeamId: homeTeamId,
            awayTeamId: awayTeamId,
            date: date,
            venue: venue,
            category: category,
            status: status,
            interestedClubs: interestedClubs,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    // レポートテンプレートデータのパース
    private func parseReportTemplateData(data: [String: Any]) -> ReportTemplate {
        let id = data["id"] as? String ?? ""
        let clubId = data["clubId"] as? String ?? ""
        let name = data["name"] as? String ?? ""
        let description = data["description"] as? String
        let isActive = data["isActive"] as? Bool ?? true
        
        let evaluationItemsData = data["evaluationItems"] as? [[String: Any]] ?? []
        let evaluationItems = evaluationItemsData.map { itemData -> EvaluationItem in
            let itemId = itemData["id"] as? String ?? ""
            let itemName = itemData["name"] as? String ?? ""
            let itemDescription = itemData["description"] as? String
            let maxRating = itemData["maxRating"] as? Int ?? 5
            
            return EvaluationItem(
                id: itemId,
                name: itemName,
                description: itemDescription,
                maxRating: maxRating
            )
        }
        
        let createdAtTimestamp = data["createdAt"] as? Timestamp
        let updatedAtTimestamp = data["updatedAt"] as? Timestamp
        
        let createdAt = createdAtTimestamp?.dateValue() ?? Date()
        let updatedAt = updatedAtTimestamp?.dateValue() ?? Date()
        
        return ReportTemplate(
            id: id,
            clubId: clubId,
            name: name,
            description: description,
            evaluationItems: evaluationItems,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    // レポートデータのパース
    private func parseReportData(data: [String: Any]) -> ScoutingReport {
        let id = data["id"] as? String ?? ""
        let userId = data["userId"] as? String ?? ""
        let clubId = data["clubId"] as? String ?? ""
        let playerId = data["playerId"] as? String ?? ""
        let matchId = data["matchId"] as? String ?? ""
        let templateId = data["templateId"] as? String ?? ""
        let statusString = data["status"] as? String ?? ReportStatus.draft.rawValue
        let overallComment = data["overallComment"] as? String
        let mediaUrls = data["mediaUrls"] as? [String] ?? []
        let likes = data["likes"] as? Int ?? 0
        let feedback = data["feedback"] as? String
        let pointsAwarded = data["pointsAwarded"] as? Int ?? 0
        
        let evaluationsData = data["evaluations"] as? [[String: Any]] ?? []
        let evaluations = evaluationsData.map { evalData -> Evaluation in
            let evalId = evalData["id"] as? String ?? ""
            let itemId = evalData["itemId"] as? String ?? ""
            let rating = evalData["rating"] as? Int ?? 0
            let comment = evalData["comment"] as? String
            
            return Evaluation(
                id: evalId,
                itemId: itemId,
                rating: rating,
                comment: comment
            )
        }
        
        let createdAtTimestamp = data["createdAt"] as? Timestamp
        let updatedAtTimestamp = data["updatedAt"] as? Timestamp
        
        let createdAt = createdAtTimestamp?.dateValue() ?? Date()
        let updatedAt = updatedAtTimestamp?.dateValue() ?? Date()
        
        let status = ReportStatus(rawValue: statusString) ?? .draft
        
        return ScoutingReport(
            id: id,
            userId: userId,
            clubId: clubId,
            playerId: playerId,
            matchId: matchId,
            templateId: templateId,
            status: status,
            evaluations: evaluations,
            overallComment: overallComment,
            mediaUrls: mediaUrls,
            likes: likes,
            feedback: feedback,
            pointsAwarded: pointsAwarded,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    // ポイント履歴データのパース
    private func parsePointHistoryData(data: [String: Any]) -> PointHistory {
        let id = data["id"] as? String ?? ""
        let userId = data["userId"] as? String ?? ""
        let amount = data["amount"] as? Int ?? 0
        let typeString = data["type"] as? String ?? PointType.earned.rawValue
        let description = data["description"] as? String ?? ""
        let relatedId = data["relatedId"] as? String
        
        let createdAtTimestamp = data["createdAt"] as? Timestamp
        let createdAt = createdAtTimestamp?.dateValue() ?? Date()
        
        let type = PointType(rawValue: typeString) ?? .earned
        
        return PointHistory(
            id: id,
            userId: userId,
            amount: amount,
            type: type,
            description: description,
            relatedId: relatedId,
            createdAt: createdAt
        )
    }
    
    // 報酬アイテムデータのパース
    private func parseRewardItemData(data: [String: Any]) -> RewardItem {
        let id = data["id"] as? String ?? ""
        let name = data["name"] as? String ?? ""
        let description = data["description"] as? String ?? ""
        let pointCost = data["pointCost"] as? Int ?? 0
        let imageUrl = data["imageUrl"] as? String
        let categoryString = data["category"] as? String ?? RewardCategory.other.rawValue
        let isAvailable = data["isAvailable"] as? Bool ?? true
        
        let createdAtTimestamp = data["createdAt"] as? Timestamp
        let updatedAtTimestamp = data["updatedAt"] as? Timestamp
        
        let createdAt = createdAtTimestamp?.dateValue() ?? Date()
        let updatedAt = updatedAtTimestamp?.dateValue() ?? Date()
        
        let category = RewardCategory(rawValue: categoryString) ?? .other
        
        return RewardItem(
            id: id,
            name: name,
            description: description,
            pointCost: pointCost,
            imageUrl: imageUrl,
            category: category,
            isAvailable: isAvailable,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    // 購読を保持するためのセット
    private var cancellables = Set<AnyCancellable>()
}
