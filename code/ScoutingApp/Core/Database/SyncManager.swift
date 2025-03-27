import Foundation
import Combine

// データ同期マネージャー
class SyncManager {
    // シングルトンインスタンス
    static let shared = SyncManager()
    
    // Firebaseマネージャー
    private let firebaseManager = FirebaseManager.shared
    
    // ローカルデータマネージャー
    private let localDataManager = LocalDataManager.shared
    
    // 同期状態
    private(set) var isSyncing = false
    
    // 最終同期日時
    private(set) var lastSyncDate: Date?
    
    // 同期状態の変更を通知するパブリッシャー
    private let syncStatusSubject = PassthroughSubject<SyncStatus, Never>()
    var syncStatusPublisher: AnyPublisher<SyncStatus, Never> {
        return syncStatusSubject.eraseToAnyPublisher()
    }
    
    // 購読を保持するためのセット
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // 初期化処理
        loadLastSyncDate()
    }
    
    // 最終同期日時を読み込む
    private func loadLastSyncDate() {
        lastSyncDate = UserDefaults.standard.object(forKey: "lastSyncDate") as? Date
    }
    
    // 最終同期日時を保存する
    private func saveLastSyncDate() {
        UserDefaults.standard.set(lastSyncDate, forKey: "lastSyncDate")
    }
    
    // 全データを同期する
    func syncAllData(userId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            guard !self.isSyncing else {
                promise(.failure(SyncError.alreadySyncing))
                return
            }
            
            self.isSyncing = true
            self.syncStatusSubject.send(.syncing(progress: 0))
            
            // 同期処理を開始
            let syncOperations = [
                self.syncUserData(userId: userId),
                self.syncMatches(),
                self.syncUserReports(userId: userId),
                self.syncPointHistory(userId: userId),
                self.syncRewardItems()
            ]
            
            // 全ての同期処理を実行
            Publishers.Zip5(syncOperations[0], syncOperations[1], syncOperations[2], syncOperations[3], syncOperations[4])
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        self.isSyncing = false
                        
                        if case .failure(let error) = completion {
                            self.syncStatusSubject.send(.failed(error: error))
                            promise(.failure(error))
                        } else {
                            self.lastSyncDate = Date()
                            self.saveLastSyncDate()
                            self.syncStatusSubject.send(.completed(date: self.lastSyncDate!))
                            promise(.success(()))
                        }
                    },
                    receiveValue: { _, _, _, _, _ in
                        // 全ての同期処理が完了
                    }
                )
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    // ユーザーデータを同期する
    private func syncUserData(userId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.syncStatusSubject.send(.syncing(progress: 0.1))
            
            self.firebaseManager.getUser(userId: userId)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    },
                    receiveValue: { user in
                        // ローカルデータを更新
                        self.localDataManager.saveUser(user)
                        self.syncStatusSubject.send(.syncing(progress: 0.2))
                        promise(.success(()))
                    }
                )
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    // 試合データを同期する
    private func syncMatches() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.syncStatusSubject.send(.syncing(progress: 0.3))
            
            self.firebaseManager.getMatches()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    },
                    receiveValue: { matches in
                        // ローカルデータを更新
                        self.localDataManager.saveMatches(matches)
                        self.syncStatusSubject.send(.syncing(progress: 0.4))
                        promise(.success(()))
                    }
                )
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    // ユーザーのレポートを同期する
    private func syncUserReports(userId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.syncStatusSubject.send(.syncing(progress: 0.5))
            
            self.firebaseManager.getReportsByUser(userId: userId)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    },
                    receiveValue: { reports in
                        // ローカルデータを更新
                        self.localDataManager.saveReports(reports)
                        self.syncStatusSubject.send(.syncing(progress: 0.6))
                        promise(.success(()))
                    }
                )
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    // ポイント履歴を同期する
    private func syncPointHistory(userId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.syncStatusSubject.send(.syncing(progress: 0.7))
            
            self.firebaseManager.getPointHistory(userId: userId)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    },
                    receiveValue: { history in
                        // ローカルデータを更新
                        self.localDataManager.savePointHistory(history)
                        self.syncStatusSubject.send(.syncing(progress: 0.8))
                        promise(.success(()))
                    }
                )
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    // 報酬アイテムを同期する
    private func syncRewardItems() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            self.syncStatusSubject.send(.syncing(progress: 0.9))
            
            self.firebaseManager.getRewardItems()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    },
                    receiveValue: { items in
                        // ローカルデータを更新
                        self.localDataManager.saveRewardItems(items)
                        self.syncStatusSubject.send(.syncing(progress: 1.0))
                        promise(.success(()))
                    }
                )
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    // オフラインで作成されたレポートを同期する
    func syncOfflineReports(userId: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            // ローカルの未同期レポートを取得
            let unsyncedReports = self.localDataManager.getUnsyncedReports()
            
            guard !unsyncedReports.isEmpty else {
                promise(.success(()))
                return
            }
            
            self.syncStatusSubject.send(.syncing(progress: 0.5))
            
            // 各レポートを順番に同期
            let publishers = unsyncedReports.map { report in
                return self.firebaseManager.createReport(report: report)
                    .map { _ in () }
                    .catch { error -> AnyPublisher<Void, Error> in
                        print("レポート同期エラー: \(error.localizedDescription)")
                        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            
            Publishers.MergeMany(publishers)
                .collect()
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                    },
                    receiveValue: { _ in
                        // 同期済みとしてマーク
                        self.localDataManager.markReportsAsSynced(reports: unsyncedReports)
                        promise(.success(()))
                    }
                )
                .store(in: &self.cancellables)
        }.eraseToAnyPublisher()
    }
    
    // 同期状態をリセットする
    func resetSyncStatus() {
        isSyncing = false
        syncStatusSubject.send(.idle)
    }
}

// 同期状態
enum SyncStatus {
    case idle
    case syncing(progress: Double)
    case completed(date: Date)
    case failed(error: Error)
}

// 同期エラー
enum SyncError: Error {
    case alreadySyncing
    case networkError
    case dataError
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .alreadySyncing:
            return "同期処理が既に実行中です"
        case .networkError:
            return "ネットワークエラーが発生しました"
        case .dataError:
            return "データエラーが発生しました"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
}

// ローカルデータマネージャー
class LocalDataManager {
    // シングルトンインスタンス
    static let shared = LocalDataManager()
    
    // UserDefaults
    private let defaults = UserDefaults.standard
    
    // ファイルマネージャー
    private let fileManager = FileManager.default
    
    // ドキュメントディレクトリURL
    private let documentsDirectory: URL
    
    private init() {
        // ドキュメントディレクトリを取得
        documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // 必要なディレクトリを作成
        createDirectoryIfNeeded(at: documentsDirectory.appendingPathComponent("users"))
        createDirectoryIfNeeded(at: documentsDirectory.appendingPathComponent("matches"))
        createDirectoryIfNeeded(at: documentsDirectory.appendingPathComponent("reports"))
        createDirectoryIfNeeded(at: documentsDirectory.appendingPathComponent("pointHistory"))
        createDirectoryIfNeeded(at: documentsDirectory.appendingPathComponent("rewardItems"))
    }
    
    // ディレクトリが存在しない場合は作成
    private func createDirectoryIfNeeded(at url: URL) {
        if !fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("ディレクトリ作成エラー: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - ユーザー関連
    
    // ユーザーを保存
    func saveUser(_ user: User) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(user)
            let fileURL = documentsDirectory.appendingPathComponent("users/\(user.id).json")
            try data.write(to: fileURL)
            
            // 現在のユーザーIDを保存
            defaults.set(user.id, forKey: "currentUserId")
        } catch {
            print("ユーザー保存エラー: \(error.localizedDescription)")
        }
    }
    
    // ユーザーを取得
    func getUser(userId: String) -> User? {
        let fileURL = documentsDirectory.appendingPathComponent("users/\(userId).json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(User.self, from: data)
        } catch {
            print("ユーザー取得エラー: \(error.localizedDescription)")
            return nil
        }
    }
    
    // 現在のユーザーを取得
    func getCurrentUser() -> User? {
        guard let userId = defaults.string(forKey: "currentUserId") else {
            return nil
        }
        
        return getUser(userId: userId)
    }
    
    // MARK: - 試合関連
    
    // 試合一覧を保存
    func saveMatches(_ matches: [Match]) {
        let encoder = JSONEncoder()
        
        // 既存の試合を削除
        let matchesDirectory = documentsDirectory.appendingPathComponent("matches")
        do {
            let existingFiles = try fileManager.contentsOfDirectory(at: matchesDirectory, includingPropertiesForKeys: nil)
            for file in existingFiles {
                try fileManager.removeItem(at: file)
            }
        } catch {
            print("試合ファイル削除エラー: \(error.localizedDescription)")
        }
        
        // 新しい試合を保存
        for match in matches {
            do {
                let data = try encoder.encode(match)
                let fileURL = matchesDirectory.appendingPathComponent("\(match.id).json")
                try data.write(to: fileURL)
            } catch {
                print("試合保存エラー: \(error.localizedDescription)")
            }
        }
        
        // インデックスファイルを保存
        do {
            let matchIds = matches.map { $0.id }
            let indexData = try encoder.encode(matchIds)
            let indexURL = matchesDirectory.appendingPathComponent("index.json")
            try indexData.write(to: indexURL)
        } catch {
            print("試合インデックス保存エラー: \(error.localizedDescription)")
        }
    }
    
    // 試合一覧を取得
    func getMatches() -> [Match] {
        let matchesDirectory = documentsDirectory.appendingPathComponent("matches")
        let indexURL = matchesDirectory.appendingPathComponent("index.json")
        
        guard fileManager.fileExists(atPath: indexURL.path) else {
            return []
        }
        
        do {
            let indexData = try Data(contentsOf: indexURL)
            let decoder = JSONDecoder()
            let matchIds = try decoder.decode([String].self, from: indexData)
            
            var matches: [Match] = []
            for matchId in matchIds {
                if let match = getMatch(matchId: matchId) {
                    matches.append(match)
                }
            }
            
            return matches
        } catch {
            print("試合一覧取得エラー: \(error.localizedDescription)")
            return []
        }
    }
    
    // 試合を取得
    func getMatch(matchId: String) -> Match? {
        let fileURL = documentsDirectory.appendingPathComponent("matches/\(matchId).json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(Match.self, from: data)
        } catch {
            print("試合取得エラー: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - レポート関連
    
    // レポート一覧を保存
    func saveReports(_ reports: [ScoutingReport]) {
        let encoder = JSONEncoder()
        
        for report in reports {
            do {
                let data = try encoder.encode(report)
                let fileURL = documentsDirectory.appendingPathComponent("reports/\(report.id).json")
                try data.write(to: fileURL)
                
                // 同期済みとしてマーク
                markReportAsSynced(reportId: report.id)
            } catch {
                print("レポート保存エラー: \(error.localizedDescription)")
            }
        }
        
        // インデックスを更新
        updateReportIndex()
    }
    
    // レポートを保存
    func saveReport(_ report: ScoutingReport, synced: Bool = false) {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(report)
            let fileURL = documentsDirectory.appendingPathComponent("reports/\(report.id).json")
            try data.write(to: fileURL)
            
            // 同期状態を設定
            if synced {
                markReportAsSynced(reportId: report.id)
            } else {
                markReportAsUnsynced(reportId: report.id)
            }
            
            // インデックスを更新
            updateReportIndex()
        } catch {
            print("レポート保存エラー: \(error.localizedDescription)")
        }
    }
    
    // レポートインデックスを更新
    private func updateReportIndex() {
        let reportsDirectory = documentsDirectory.appendingPathComponent("reports")
        
        do {
            let files = try fileManager.contentsOfDirectory(at: reportsDirectory, includingPropertiesForKeys: nil)
            let reportFiles = files.filter { $0.pathExtension == "json" && $0.lastPathComponent != "index.json" }
            let reportIds = reportFiles.map { $0.deletingPathExtension().lastPathComponent }
            
            let encoder = JSONEncoder()
            let indexData = try encoder.encode(reportIds)
            let indexURL = reportsDirectory.appendingPathComponent("index.json")
            try indexData.write(to: indexURL)
        } catch {
            print("レポートインデックス更新エラー: \(error.localizedDescription)")
        }
    }
    
    // レポート一覧を取得
    func getReports() -> [ScoutingReport] {
        let reportsDirectory = documentsDirectory.appendingPathComponent("reports")
        let indexURL = reportsDirectory.appendingPathComponent("index.json")
        
        guard fileManager.fileExists(atPath: indexURL.path) else {
            return []
        }
        
        do {
            let indexData = try Data(contentsOf: indexURL)
            let decoder = JSONDecoder()
            let reportIds = try decoder.decode([String].self, from: indexData)
            
            var reports: [ScoutingReport] = []
            for reportId in reportIds {
                if let report = getReport(reportId: reportId) {
                    reports.append(report)
                }
            }
            
            return reports
        } catch {
            print("レポート一覧取得エラー: \(error.localizedDescription)")
            return []
        }
    }
    
    // レポートを取得
    func getReport(reportId: String) -> ScoutingReport? {
        let fileURL = documentsDirectory.appendingPathComponent("reports/\(reportId).json")
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(ScoutingReport.self, from: data)
        } catch {
            print("レポート取得エラー: \(error.localizedDescription)")
            return nil
        }
    }
    
    // 未同期のレポートを取得
    func getUnsyncedReports() -> [ScoutingReport] {
        let unsyncedIds = defaults.stringArray(forKey: "unsyncedReportIds") ?? []
        
        var reports: [ScoutingReport] = []
        for reportId in unsyncedIds {
            if let report = getReport(reportId: reportId) {
                reports.append(report)
            }
        }
        
        return reports
    }
    
    // レポートを未同期としてマーク
    func markReportAsUnsynced(reportId: String) {
        var unsyncedIds = defaults.stringArray(forKey: "unsyncedReportIds") ?? []
        if !unsyncedIds.contains(reportId) {
            unsyncedIds.append(reportId)
            defaults.set(unsyncedIds, forKey: "unsyncedReportIds")
        }
    }
    
    // レポートを同期済みとしてマーク
    func markReportAsSynced(reportId: String) {
        var unsyncedIds = defaults.stringArray(forKey: "unsyncedReportIds") ?? []
        unsyncedIds.removeAll { $0 == reportId }
        defaults.set(unsyncedIds, forKey: "unsyncedReportIds")
    }
    
    // レポート一覧を同期済みとしてマーク
    func markReportsAsSynced(reports: [ScoutingReport]) {
        var unsyncedIds = defaults.stringArray(forKey: "unsyncedReportIds") ?? []
        let reportIds = reports.map { $0.id }
        unsyncedIds.removeAll { reportIds.contains($0) }
        defaults.set(unsyncedIds, forKey: "unsyncedReportIds")
    }
    
    // MARK: - ポイント履歴関連
    
    // ポイント履歴を保存
    func savePointHistory(_ history: [PointHistory]) {
        let encoder = JSONEncoder()
        
        // 既存の履歴を削除
        let historyDirectory = documentsDirectory.appendingPathComponent("pointHistory")
        do {
            let existingFiles = try fileManager.contentsOfDirectory(at: historyDirectory, includingPropertiesForKeys: nil)
            for file in existingFiles {
                try fileManager.removeItem(at: file)
            }
        } catch {
            print("ポイント履歴ファイル削除エラー: \(error.localizedDescription)")
        }
        
        // 新しい履歴を保存
        for item in history {
            do {
                let data = try encoder.encode(item)
                let fileURL = historyDirectory.appendingPathComponent("\(item.id).json")
                try data.write(to: fileURL)
            } catch {
                print("ポイント履歴保存エラー: \(error.localizedDescription)")
            }
        }
        
        // インデックスファイルを保存
        do {
            let historyIds = history.map { $0.id }
            let indexData = try encoder.encode(historyIds)
            let indexURL = historyDirectory.appendingPathComponent("index.json")
            try indexData.write(to: indexURL)
        } catch {
            print("ポイント履歴インデックス保存エラー: \(error.localizedDescription)")
        }
    }
    
    // ポイント履歴を取得
    func getPointHistory() -> [PointHistory] {
        let historyDirectory = documentsDirectory.appendingPathComponent("pointHistory")
        let indexURL = historyDirectory.appendingPathComponent("index.json")
        
        guard fileManager.fileExists(atPath: indexURL.path) else {
            return []
        }
        
        do {
            let indexData = try Data(contentsOf: indexURL)
            let decoder = JSONDecoder()
            let historyIds = try decoder.decode([String].self, from: indexData)
            
            var history: [PointHistory] = []
            for historyId in historyIds {
                let fileURL = historyDirectory.appendingPathComponent("\(historyId).json")
                
                if fileManager.fileExists(atPath: fileURL.path) {
                    let data = try Data(contentsOf: fileURL)
                    let item = try decoder.decode(PointHistory.self, from: data)
                    history.append(item)
                }
            }
            
            return history.sorted { $0.createdAt > $1.createdAt }
        } catch {
            print("ポイント履歴取得エラー: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - 報酬アイテム関連
    
    // 報酬アイテムを保存
    func saveRewardItems(_ items: [RewardItem]) {
        let encoder = JSONEncoder()
        
        // 既存のアイテムを削除
        let itemsDirectory = documentsDirectory.appendingPathComponent("rewardItems")
        do {
            let existingFiles = try fileManager.contentsOfDirectory(at: itemsDirectory, includingPropertiesForKeys: nil)
            for file in existingFiles {
                try fileManager.removeItem(at: file)
            }
        } catch {
            print("報酬アイテムファイル削除エラー: \(error.localizedDescription)")
        }
        
        // 新しいアイテムを保存
        for item in items {
            do {
                let data = try encoder.encode(item)
                let fileURL = itemsDirectory.appendingPathComponent("\(item.id).json")
                try data.write(to: fileURL)
            } catch {
                print("報酬アイテム保存エラー: \(error.localizedDescription)")
            }
        }
        
        // インデックスファイルを保存
        do {
            let itemIds = items.map { $0.id }
            let indexData = try encoder.encode(itemIds)
            let indexURL = itemsDirectory.appendingPathComponent("index.json")
            try indexData.write(to: indexURL)
        } catch {
            print("報酬アイテムインデックス保存エラー: \(error.localizedDescription)")
        }
    }
    
    // 報酬アイテムを取得
    func getRewardItems() -> [RewardItem] {
        let itemsDirectory = documentsDirectory.appendingPathComponent("rewardItems")
        let indexURL = itemsDirectory.appendingPathComponent("index.json")
        
        guard fileManager.fileExists(atPath: indexURL.path) else {
            return []
        }
        
        do {
            let indexData = try Data(contentsOf: indexURL)
            let decoder = JSONDecoder()
            let itemIds = try decoder.decode([String].self, from: indexData)
            
            var items: [RewardItem] = []
            for itemId in itemIds {
                let fileURL = itemsDirectory.appendingPathComponent("\(itemId).json")
                
                if fileManager.fileExists(atPath: fileURL.path) {
                    let data = try Data(contentsOf: fileURL)
                    let item = try decoder.decode(RewardItem.self, from: data)
                    items.append(item)
                }
            }
            
            return items
        } catch {
            print("報酬アイテム取得エラー: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - キャッシュ管理
    
    // キャッシュをクリア
    func clearCache() {
        let directories = [
            documentsDirectory.appendingPathComponent("matches"),
            documentsDirectory.appendingPathComponent("reports"),
            documentsDirectory.appendingPathComponent("pointHistory"),
            documentsDirectory.appendingPathComponent("rewardItems")
        ]
        
        for directory in directories {
            do {
                let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
                for file in files {
                    try fileManager.removeItem(at: file)
                }
            } catch {
                print("キャッシュクリアエラー: \(error.localizedDescription)")
            }
        }
        
        // 未同期レポートIDをリセット
        defaults.removeObject(forKey: "unsyncedReportIds")
        
        // 最終同期日時をリセット
        defaults.removeObject(forKey: "lastSyncDate")
    }
}
