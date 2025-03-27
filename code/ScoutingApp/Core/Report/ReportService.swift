import Foundation
import Combine

// スカウティングレポートサービスプロトコル
protocol ReportServiceProtocol {
    func getReportTemplates(clubId: String) -> AnyPublisher<[ReportTemplate], Error>
    func createReport(report: ScoutingReport) -> AnyPublisher<ScoutingReport, Error>
    func updateReport(report: ScoutingReport) -> AnyPublisher<ScoutingReport, Error>
    func getReportsByUser(userId: String, status: ReportStatus?) -> AnyPublisher<[ScoutingReport], Error>
    func getReportsByClub(clubId: String) -> AnyPublisher<[ScoutingReport], Error>
    func getReportDetails(reportId: String) -> AnyPublisher<ScoutingReport, Error>
    func likeReport(reportId: String, clubId: String) -> AnyPublisher<ScoutingReport, Error>
    func addFeedback(reportId: String, feedback: String, pointsAwarded: Int) -> AnyPublisher<ScoutingReport, Error>
}

// スカウティングレポートサービス実装
class ReportService: ReportServiceProtocol {
    // シングルトンインスタンス
    static let shared = ReportService()
    
    private init() {
        // 初期化処理
    }
    
    // レポートテンプレート一覧を取得
    func getReportTemplates(clubId: String) -> AnyPublisher<[ReportTemplate], Error> {
        return Future<[ReportTemplate], Error> { promise in
            // 実際のアプリではAPIを呼び出してテンプレート一覧を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let templates = self.generateMockTemplates(clubId: clubId)
                promise(.success(templates))
            }
        }.eraseToAnyPublisher()
    }
    
    // レポートを作成
    func createReport(report: ScoutingReport) -> AnyPublisher<ScoutingReport, Error> {
        return Future<ScoutingReport, Error> { promise in
            // 実際のアプリではAPIを呼び出してレポートを作成
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                var newReport = report
                newReport.id = UUID().uuidString
                newReport.createdAt = Date()
                newReport.updatedAt = Date()
                promise(.success(newReport))
            }
        }.eraseToAnyPublisher()
    }
    
    // レポートを更新
    func updateReport(report: ScoutingReport) -> AnyPublisher<ScoutingReport, Error> {
        return Future<ScoutingReport, Error> { promise in
            // 実際のアプリではAPIを呼び出してレポートを更新
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                var updatedReport = report
                updatedReport.updatedAt = Date()
                promise(.success(updatedReport))
            }
        }.eraseToAnyPublisher()
    }
    
    // ユーザーのレポート一覧を取得
    func getReportsByUser(userId: String, status: ReportStatus? = nil) -> AnyPublisher<[ScoutingReport], Error> {
        return Future<[ScoutingReport], Error> { promise in
            // 実際のアプリではAPIを呼び出してレポート一覧を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                var reports = self.generateMockReports().filter { $0.userId == userId }
                
                if let status = status {
                    reports = reports.filter { $0.status == status }
                }
                
                promise(.success(reports))
            }
        }.eraseToAnyPublisher()
    }
    
    // クラブのレポート一覧を取得
    func getReportsByClub(clubId: String) -> AnyPublisher<[ScoutingReport], Error> {
        return Future<[ScoutingReport], Error> { promise in
            // 実際のアプリではAPIを呼び出してレポート一覧を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let reports = self.generateMockReports().filter { $0.clubId == clubId }
                promise(.success(reports))
            }
        }.eraseToAnyPublisher()
    }
    
    // レポート詳細を取得
    func getReportDetails(reportId: String) -> AnyPublisher<ScoutingReport, Error> {
        return Future<ScoutingReport, Error> { promise in
            // 実際のアプリではAPIを呼び出してレポート詳細を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let report = self.generateMockReports().first(where: { $0.id == reportId }) {
                    promise(.success(report))
                } else {
                    promise(.failure(ReportError.reportNotFound))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // レポートにいいねを付ける
    func likeReport(reportId: String, clubId: String) -> AnyPublisher<ScoutingReport, Error> {
        return Future<ScoutingReport, Error> { promise in
            // 実際のアプリではAPIを呼び出していいねを付ける
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if var report = self.generateMockReports().first(where: { $0.id == reportId }) {
                    report.likes += 1
                    promise(.success(report))
                } else {
                    promise(.failure(ReportError.reportNotFound))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // レポートにフィードバックを追加
    func addFeedback(reportId: String, feedback: String, pointsAwarded: Int) -> AnyPublisher<ScoutingReport, Error> {
        return Future<ScoutingReport, Error> { promise in
            // 実際のアプリではAPIを呼び出してフィードバックを追加
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if var report = self.generateMockReports().first(where: { $0.id == reportId }) {
                    report.feedback = feedback
                    report.pointsAwarded = pointsAwarded
                    report.status = .reviewed
                    report.updatedAt = Date()
                    promise(.success(report))
                } else {
                    promise(.failure(ReportError.reportNotFound))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // モックデータ生成（テンプレート）
    private func generateMockTemplates(clubId: String) -> [ReportTemplate] {
        return [
            ReportTemplate(
                id: "template1",
                clubId: clubId,
                name: "基本評価テンプレート",
                description: "選手の基本的な能力を評価するためのテンプレート",
                evaluationItems: [
                    EvaluationItem(id: "item1", name: "テクニック", description: "ボールコントロール、パス精度、ドリブル技術など"),
                    EvaluationItem(id: "item2", name: "フィジカル", description: "スピード、パワー、持久力など"),
                    EvaluationItem(id: "item3", name: "戦術理解", description: "ポジショニング、状況判断、戦術的柔軟性など"),
                    EvaluationItem(id: "item4", name: "メンタル", description: "集中力、プレッシャー耐性、リーダーシップなど"),
                    EvaluationItem(id: "item5", name: "ポテンシャル", description: "将来性、成長余地など")
                ]
            ),
            ReportTemplate(
                id: "template2",
                clubId: clubId,
                name: "ポジション別評価テンプレート",
                description: "ポジション特性に応じた詳細評価のためのテンプレート",
                evaluationItems: [
                    EvaluationItem(id: "item6", name: "攻撃参加", description: "攻撃への関与度、得点能力など"),
                    EvaluationItem(id: "item7", name: "守備貢献", description: "守備への貢献度、ボール奪取能力など"),
                    EvaluationItem(id: "item8", name: "ポジショニング", description: "適切な位置取り、スペース活用など"),
                    EvaluationItem(id: "item9", name: "チーム貢献", description: "チームプレー、連携、コミュニケーションなど"),
                    EvaluationItem(id: "item10", name: "特殊技能", description: "セットプレー、空中戦、1対1など")
                ]
            )
        ]
    }
    
    // モックデータ生成（レポート）
    private func generateMockReports() -> [ScoutingReport] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        return [
            ScoutingReport(
                id: "report1",
                userId: "user1",
                clubId: "club1",
                playerId: "player1",
                matchId: "match1",
                templateId: "template1",
                status: .reviewed,
                evaluations: [
                    Evaluation(id: "eval1", itemId: "item1", rating: 4, comment: "正確なパスと優れたボールコントロールを持つ"),
                    Evaluation(id: "eval2", itemId: "item2", rating: 3, comment: "スピードは平均的だが、バランスが良い"),
                    Evaluation(id: "eval3", itemId: "item3", rating: 5, comment: "優れた状況判断と戦術理解を持つ"),
                    Evaluation(id: "eval4", itemId: "item4", rating: 4, comment: "集中力があり、プレッシャーにも強い"),
                    Evaluation(id: "eval5", itemId: "item5", rating: 5, comment: "非常に高いポテンシャルを持つ")
                ],
                overallComment: "三笘選手は技術と戦術理解に優れ、将来性も高い選手です。特に状況判断の良さが際立っており、チームの攻撃の起点となっています。",
                mediaUrls: ["media1.jpg", "media2.jpg"],
                likes: 5,
                feedback: "素晴らしい分析です。特に戦術面の評価が参考になりました。",
                pointsAwarded: 100,
                createdAt: dateFormatter.date(from: "2025/03/25")!,
                updatedAt: dateFormatter.date(from: "2025/03/26")!
            ),
            ScoutingReport(
                id: "report2",
                userId: "user1",
                clubId: "club3",
                playerId: "player2",
                matchId: "match2",
                templateId: "template1",
                status: .submitted,
                evaluations: [
                    Evaluation(id: "eval6", itemId: "item1", rating: 5, comment: "素晴らしいテクニックと創造性を持つ"),
                    Evaluation(id: "eval7", itemId: "item2", rating: 3, comment: "フィジカル面はやや弱いが、技術でカバー"),
                    Evaluation(id: "eval8", itemId: "item3", rating: 4, comment: "良い戦術理解を持ち、的確な判断ができる"),
                    Evaluation(id: "eval9", itemId: "item4", rating: 4, comment: "精神的に強く、プレッシャーにも動じない"),
                    Evaluation(id: "eval10", itemId: "item5", rating: 5, comment: "世界レベルのポテンシャルを持つ")
                ],
                overallComment: "久保選手は卓越したテクニックと創造性を持ち、若年ながら高い戦術理解を示しています。フィジカル面の向上が課題ですが、技術と知性で十分にカバーしています。",
                mediaUrls: ["media3.jpg", "media4.jpg"],
                likes: 2,
                createdAt: dateFormatter.date(from: "2025/03/20")!,
                updatedAt: dateFormatter.date(from: "2025/03/20")!
            ),
            ScoutingReport(
                id: "report3",
                userId: "user1",
                clubId: "club5",
                playerId: "player3",
                matchId: "match3",
                templateId: "template2",
                status: .reviewed,
                evaluations: [
                    Evaluation(id: "eval11", itemId: "item6", rating: 5, comment: "優れた得点能力と攻撃センス"),
                    Evaluation(id: "eval12", itemId: "item7", rating: 3, comment: "守備面はやや弱いが、前線でのプレスは効果的"),
                    Evaluation(id: "eval13", itemId: "item8", rating: 4, comment: "ゴール前での位置取りが素晴らしい"),
                    Evaluation(id: "eval14", itemId: "item9", rating: 4, comment: "チームメイトとの連携が良く、アシストも多い"),
                    Evaluation(id: "eval15", itemId: "item10", rating: 5, comment: "ヘディングとフィニッシュ能力が特に優れている")
                ],
                overallComment: "興梠選手はゴール前での嗅覚と決定力に優れ、経験に裏打ちされた試合運びが魅力です。チームの攻撃の中心として、得点だけでなくアシストも多く記録しています。",
                mediaUrls: ["media5.jpg"],
                likes: 3,
                feedback: "経験豊富な選手の特徴をよく捉えています。チーム内での役割についての分析が特に参考になりました。",
                pointsAwarded: 75,
                createdAt: dateFormatter.date(from: "2025/03/15")!,
                updatedAt: dateFormatter.date(from: "2025/03/16")!
            ),
            ScoutingReport(
                id: "report4",
                userId: "user1",
                clubId: "club7",
                playerId: "player4",
                matchId: "match4",
                templateId: "template2",
                status: .draft,
                evaluations: [
                    Evaluation(id: "eval16", itemId: "item6", rating: 3, comment: "攻撃参加は限定的だが、効果的なクロスを上げる"),
                    Evaluation(id: "eval17", itemId: "item7", rating: 5, comment: "優れた守備能力と対人守備の強さ"),
                    Evaluation(id: "eval18", itemId: "item8", rating: 4, comment: "守備ラインのコントロールが上手い"),
                    Evaluation(id: "eval19", itemId: "item9", rating: 5, comment: "チームの精神的支柱として機能している"),
                    Evaluation(id: "eval20", itemId: "item10", rating: 4, comment: "空中戦に強く、セットプレーでの得点能力もある")
                ],
                overallComment: "槙野選手は守備の要として、優れたリーダーシップと対人守備の強さを持っています。経験に基づいた的確な判断と指示が、チーム全体の守備安定に貢献しています。",
                createdAt: dateFormatter.date(from: "2025/03/10")!,
                updatedAt: dateFormatter.date(from: "2025/03/10")!
            )
        ]
    }
}

// レポートエラー
enum ReportError: Error {
    case reportNotFound
    case templateNotFound
    case invalidData
    case networkError
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .reportNotFound:
            return "レポートが見つかりません"
        case .templateNotFound:
            return "テンプレートが見つかりません"
        case .invalidData:
            return "無効なデータです"
        case .networkError:
            return "ネットワークエラーが発生しました"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
}

// スカウティングレポートを管理するビューモデル
class ReportViewModel: ObservableObject {
    // レポートサービス
    private let reportService: ReportServiceProtocol
    
    // 購読を保持するためのセット
    private var cancellables = Set<AnyCancellable>()
    
    // 公開プロパティ
    @Published var templates: [ReportTemplate] = []
    @Published var selectedTemplate: ReportTemplate?
    @Published var reports: [ScoutingReport] = []
    @Published var selectedReport: ScoutingReport?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // 新規レポート作成用
    @Published var newReport: ScoutingReport?
    @Published var evaluations: [Evaluation] = []
    @Published var overallComment: String = ""
    @Published var mediaUrls: [String] = []
    
    // フィルター状態
    @Published var selectedStatus: ReportStatus?
    
    init(reportService: ReportServiceProtocol = ReportService.shared) {
        self.reportService = reportService
    }
    
    // テンプレート一覧を読み込む
    func loadTemplates(clubId: String) {
        isLoading = true
        errorMessage = nil
        
        reportService.getReportTemplates(clubId: clubId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] templates in
                    self?.templates = templates
                    if let firstTemplate = templates.first {
                        self?.selectedTemplate = firstTemplate
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // ユーザーのレポート一覧を読み込む
    func loadUserReports(userId: String) {
        isLoading = true
        errorMessage = nil
        
        reportService.getReportsByUser(userId: userId, status: selectedStatus)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] reports in
                    self?.reports = reports
                }
            )
            .store(in: &cancellables)
    }
    
    // クラブのレポート一覧を読み込む
    func loadClubReports(clubId: String) {
        isLoading = true
        errorMessage = nil
        
        reportService.getReportsByClub(clubId: clubId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] reports in
                    self?.reports = reports
                }
            )
            .store(in: &cancellables)
    }
    
    // レポート詳細を読み込む
    func loadReportDetails(reportId: String) {
        isLoading = true
        errorMessage = nil
        
        reportService.getReportDetails(reportId: reportId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] report in
                    self?.selectedReport = report
                }
            )
            .store(in: &cancellables)
    }
    
    // 新規レポートの準備
    func prepareNewReport(userId: String, clubId: String, playerId: String, matchId: String, templateId: String) {
        // テンプレートから評価項目を取得
        if let template = templates.first(where: { $0.id == templateId }) {
            selectedTemplate = template
            
            // 評価項目の初期化
            evaluations = template.evaluationItems.map { item in
                Evaluation(itemId: item.id, rating: 0)
            }
            
            // 新規レポートの作成
            newReport = ScoutingReport(
                userId: userId,
                clubId: clubId,
                playerId: playerId,
                matchId: matchId,
                templateId: templateId,
                status: .draft,
                evaluations: evaluations
            )
        }
    }
    
    // 評価を更新
    func updateEvaluation(itemId: String, rating: Int, comment: String?) {
        if let index = evaluations.firstIndex(where: { $0.itemId == itemId }) {
            evaluations[index].rating = rating
            evaluations[index].comment = comment
            
            // 新規レポートの評価も更新
            if var report = newReport {
                report.evaluations = evaluations
                newReport = report
            }
        }
    }
    
    // レポートを保存（下書き）
    func saveReportAsDraft() {
        guard var report = newReport else { return }
        
        isLoading = true
        errorMessage = nil
        
        report.status = .draft
        report.evaluations = evaluations
        report.overallComment = overallComment
        report.mediaUrls = mediaUrls
        
        reportService.createReport(report: report)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] savedReport in
                    self?.selectedReport = savedReport
                    self?.resetNewReport()
                }
            )
            .store(in: &cancellables)
    }
    
    // レポートを提出
    func submitReport() {
        guard var report = newReport else { return }
        
        isLoading = true
        errorMessage = nil
        
        report.status = .submitted
        report.evaluations = evaluations
        report.overallComment = overallComment
        report.mediaUrls = mediaUrls
        
        reportService.createReport(report: report)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] savedReport in
                    self?.selectedReport = savedReport
                    self?.resetNewReport()
                }
            )
            .store(in: &cancellables)
    }
    
    // レポートを更新
    func updateReport() {
        guard var report = selectedReport else { return }
        
        isLoading = true
        errorMessage = nil
        
        reportService.updateReport(report: report)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] updatedReport in
                    self?.selectedReport = updatedReport
                }
            )
            .store(in: &cancellables)
    }
    
    // レポートにいいねを付ける
    func likeReport(clubId: String) {
        guard let reportId = selectedReport?.id else { return }
        
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
                receiveValue: { [weak self] updatedReport in
                    self?.selectedReport = updatedReport
                }
            )
            .store(in: &cancellables)
    }
    
    // レポートにフィードバックを追加
    func addFeedback(feedback: String, pointsAwarded: Int) {
        guard let reportId = selectedReport?.id else { return }
        
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
                receiveValue: { [weak self] updatedReport in
                    self?.selectedReport = updatedReport
                }
            )
            .store(in: &cancellables)
    }
    
    // 新規レポートをリセット
    private func resetNewReport() {
        newReport = nil
        evaluations = []
        overallComment = ""
        mediaUrls = []
    }
    
    // レポートのステータスに応じた色を取得
    func getStatusColor(status: ReportStatus) -> String {
        switch status {
        case .draft:
            return "#5F6368" // ミディアムグレー
        case .submitted:
            return "#FBBC05" // サポートイエロー
        case .reviewed:
            return "#34A853" // アクセントグリーン
        }
    }
    
    // レポートのステータスに応じた表示名を取得
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
