import Foundation
import Combine

// 試合スケジュールサービスプロトコル
protocol ScheduleServiceProtocol {
    func getMatches(region: String?, date: DateFilter?, category: String?) -> AnyPublisher<[Match], Error>
    func getMatchDetails(matchId: String) -> AnyPublisher<Match, Error>
    func getInterestedClubMatches(clubId: String) -> AnyPublisher<[Match], Error>
    func getPlayersByMatch(matchId: String) -> AnyPublisher<[Player], Error>
}

// 日付フィルター
enum DateFilter: String {
    case today = "today"
    case tomorrow = "tomorrow"
    case thisWeek = "this_week"
    case nextWeek = "next_week"
    case thisMonth = "this_month"
}

// 試合スケジュールサービス実装
class ScheduleService: ScheduleServiceProtocol {
    // シングルトンインスタンス
    static let shared = ScheduleService()
    
    private init() {
        // 初期化処理
    }
    
    // 試合一覧を取得
    func getMatches(region: String? = nil, date: DateFilter? = nil, category: String? = nil) -> AnyPublisher<[Match], Error> {
        return Future<[Match], Error> { promise in
            // 実際のアプリではAPIを呼び出して試合一覧を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let matches = self.generateMockMatches(region: region, date: date, category: category)
                promise(.success(matches))
            }
        }.eraseToAnyPublisher()
    }
    
    // 試合詳細を取得
    func getMatchDetails(matchId: String) -> AnyPublisher<Match, Error> {
        return Future<Match, Error> { promise in
            // 実際のアプリではAPIを呼び出して試合詳細を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let match = self.generateMockMatches().first(where: { $0.id == matchId }) {
                    promise(.success(match))
                } else {
                    promise(.failure(ScheduleError.matchNotFound))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // 特定のクラブが注目している試合を取得
    func getInterestedClubMatches(clubId: String) -> AnyPublisher<[Match], Error> {
        return Future<[Match], Error> { promise in
            // 実際のアプリではAPIを呼び出してクラブが注目している試合を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let matches = self.generateMockMatches().filter { $0.interestedClubs.contains(clubId) }
                promise(.success(matches))
            }
        }.eraseToAnyPublisher()
    }
    
    // 試合に出場する選手一覧を取得
    func getPlayersByMatch(matchId: String) -> AnyPublisher<[Player], Error> {
        return Future<[Player], Error> { promise in
            // 実際のアプリではAPIを呼び出して選手一覧を取得
            // ここではモックデータを返す
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let players = self.generateMockPlayers()
                promise(.success(players))
            }
        }.eraseToAnyPublisher()
    }
    
    // モックデータ生成（試合）
    private func generateMockMatches(region: String? = nil, date: DateFilter? = nil, category: String? = nil) -> [Match] {
        let fcTokyo = Club(
            id: "club1",
            name: "FC東京",
            logoUrl: "fc_tokyo_logo",
            category: "J1",
            region: "関東"
        )
        
        let urawa = Club(
            id: "club2",
            name: "浦和レッズ",
            logoUrl: "urawa_logo",
            category: "J1",
            region: "関東"
        )
        
        let yokohamaFM = Club(
            id: "club3",
            name: "横浜F・マリノス",
            logoUrl: "yokohama_fm_logo",
            category: "J1",
            region: "関東"
        )
        
        let kashima = Club(
            id: "club4",
            name: "鹿島アントラーズ",
            logoUrl: "kashima_logo",
            category: "J1",
            region: "関東"
        )
        
        let gamba = Club(
            id: "club5",
            name: "ガンバ大阪",
            logoUrl: "gamba_logo",
            category: "J1",
            region: "関西"
        )
        
        let cerezo = Club(
            id: "club6",
            name: "セレッソ大阪",
            logoUrl: "cerezo_logo",
            category: "J1",
            region: "関西"
        )
        
        let nagoya = Club(
            id: "club7",
            name: "名古屋グランパス",
            logoUrl: "nagoya_logo",
            category: "J1",
            region: "中部"
        )
        
        let hiroshima = Club(
            id: "club8",
            name: "サンフレッチェ広島",
            logoUrl: "hiroshima_logo",
            category: "J1",
            region: "中国"
        )
        
        // 今日の日付
        let today = Date()
        let calendar = Calendar.current
        
        // 明日の日付
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // 3日後の日付
        let threeDaysLater = calendar.date(byAdding: .day, value: 3, to: today)!
        
        // 1週間後の日付
        let oneWeekLater = calendar.date(byAdding: .day, value: 7, to: today)!
        
        var matches = [
            Match(
                id: "match1",
                homeTeamId: fcTokyo.id,
                awayTeamId: urawa.id,
                homeTeam: fcTokyo,
                awayTeam: urawa,
                date: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: today)!,
                venue: "味の素スタジアム",
                category: "J1",
                interestedClubs: ["club1", "club2"]
            ),
            Match(
                id: "match2",
                homeTeamId: yokohamaFM.id,
                awayTeamId: kashima.id,
                homeTeam: yokohamaFM,
                awayTeam: kashima,
                date: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: today)!,
                venue: "日産スタジアム",
                category: "J1",
                interestedClubs: ["club3", "club4"]
            ),
            Match(
                id: "match3",
                homeTeamId: gamba.id,
                awayTeamId: cerezo.id,
                homeTeam: gamba,
                awayTeam: cerezo,
                date: calendar.date(bySettingHour: 13, minute: 0, second: 0, of: tomorrow)!,
                venue: "パナソニックスタジアム",
                category: "J1",
                interestedClubs: ["club5"]
            ),
            Match(
                id: "match4",
                homeTeamId: nagoya.id,
                awayTeamId: hiroshima.id,
                homeTeam: nagoya,
                awayTeam: hiroshima,
                date: calendar.date(bySettingHour: 16, minute: 0, second: 0, of: tomorrow)!,
                venue: "豊田スタジアム",
                category: "J1",
                interestedClubs: ["club7", "club8"]
            ),
            Match(
                id: "match5",
                homeTeamId: fcTokyo.id,
                awayTeamId: kashima.id,
                homeTeam: fcTokyo,
                awayTeam: kashima,
                date: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: threeDaysLater)!,
                venue: "味の素スタジアム",
                category: "J1",
                interestedClubs: ["club1", "club4"]
            ),
            Match(
                id: "match6",
                homeTeamId: urawa.id,
                awayTeamId: yokohamaFM.id,
                homeTeam: urawa,
                awayTeam: yokohamaFM,
                date: calendar.date(bySettingHour: 15, minute: 0, second: 0, of: oneWeekLater)!,
                venue: "埼玉スタジアム2002",
                category: "J1",
                interestedClubs: ["club2", "club3"]
            )
        ]
        
        // フィルタリング
        if let region = region, region != "全国" {
            matches = matches.filter { match in
                return match.homeTeam?.region == region || match.awayTeam?.region == region
            }
        }
        
        if let date = date {
            matches = matches.filter { match in
                let matchDate = match.date
                switch date {
                case .today:
                    return calendar.isDateInToday(matchDate)
                case .tomorrow:
                    return calendar.isDateInTomorrow(matchDate)
                case .thisWeek:
                    let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                    let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
                    return matchDate >= startOfWeek && matchDate < endOfWeek
                case .nextWeek:
                    let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
                    let startOfNextWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
                    let endOfNextWeek = calendar.date(byAdding: .day, value: 7, to: startOfNextWeek)!
                    return matchDate >= startOfNextWeek && matchDate < endOfNextWeek
                case .thisMonth:
                    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
                    let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
                    return matchDate >= startOfMonth && matchDate < nextMonth
                }
            }
        }
        
        if let category = category {
            matches = matches.filter { $0.category == category }
        }
        
        return matches
    }
    
    // モックデータ生成（選手）
    private func generateMockPlayers() -> [Player] {
        let fcTokyo = Club(
            id: "club1",
            name: "FC東京",
            logoUrl: "fc_tokyo_logo",
            category: "J1",
            region: "関東"
        )
        
        let urawa = Club(
            id: "club2",
            name: "浦和レッズ",
            logoUrl: "urawa_logo",
            category: "J1",
            region: "関東"
        )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        return [
            Player(
                id: "player1",
                name: "三笘薫",
                position: "MF",
                clubId: fcTokyo.id,
                club: fcTokyo,
                dateOfBirth: dateFormatter.date(from: "1997/05/20"),
                height: 178,
                weight: 73,
                nationality: "日本",
                profileImageUrl: "mitoma_profile"
            ),
            Player(
                id: "player2",
                name: "久保建英",
                position: "MF",
                clubId: fcTokyo.id,
                club: fcTokyo,
                dateOfBirth: dateFormatter.date(from: "2001/06/04"),
                height: 173,
                weight: 67,
                nationality: "日本",
                profileImageUrl: "kubo_profile"
            ),
            Player(
                id: "player3",
                name: "興梠慎三",
                position: "FW",
                clubId: urawa.id,
                club: urawa,
                dateOfBirth: dateFormatter.date(from: "1986/07/06"),
                height: 175,
                weight: 72,
                nationality: "日本",
                profileImageUrl: "koroki_profile"
            ),
            Player(
                id: "player4",
                name: "槙野智章",
                position: "DF",
                clubId: urawa.id,
                club: urawa,
                dateOfBirth: dateFormatter.date(from: "1987/05/11"),
                height: 182,
                weight: 75,
                nationality: "日本",
                profileImageUrl: "makino_profile"
            )
        ]
    }
}

// スケジュールエラー
enum ScheduleError: Error {
    case matchNotFound
    case networkError
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .matchNotFound:
            return "試合が見つかりません"
        case .networkError:
            return "ネットワークエラーが発生しました"
        case .unknown:
            return "不明なエラーが発生しました"
        }
    }
}

// 試合スケジュールを管理するビューモデル
class ScheduleViewModel: ObservableObject {
    // スケジュールサービス
    private let scheduleService: ScheduleServiceProtocol
    
    // 購読を保持するためのセット
    private var cancellables = Set<AnyCancellable>()
    
    // 公開プロパティ
    @Published var matches: [Match] = []
    @Published var selectedMatch: Match?
    @Published var matchPlayers: [Player] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // フィルター状態
    @Published var selectedRegion: String = "全国"
    @Published var selectedDateFilter: DateFilter?
    @Published var selectedCategory: String?
    
    init(scheduleService: ScheduleServiceProtocol = ScheduleService.shared) {
        self.scheduleService = scheduleService
        loadMatches()
    }
    
    // 試合一覧を読み込む
    func loadMatches() {
        isLoading = true
        errorMessage = nil
        
        scheduleService.getMatches(
            region: selectedRegion == "全国" ? nil : selectedRegion,
            date: selectedDateFilter,
            category: selectedCategory
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] matches in
                self?.matches = matches
            }
        )
        .store(in: &cancellables)
    }
    
    // 試合詳細を読み込む
    func loadMatchDetails(matchId: String) {
        isLoading = true
        errorMessage = nil
        
        scheduleService.getMatchDetails(matchId: matchId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] match in
                    self?.selectedMatch = match
                    self?.loadMatchPlayers(matchId: matchId)
                }
            )
            .store(in: &cancellables)
    }
    
    // 試合に出場する選手一覧を読み込む
    private func loadMatchPlayers(matchId: String) {
        scheduleService.getPlayersByMatch(matchId: matchId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] players in
                    self?.matchPlayers = players
                }
            )
            .store(in: &cancellables)
    }
    
    // フィルターを適用して試合一覧を更新
    func applyFilters(region: String, dateFilter: DateFilter?, category: String?) {
        selectedRegion = region
        selectedDateFilter = dateFilter
        selectedCategory = category
        loadMatches()
    }
    
    // 日付をフォーマット
    func formatMatchDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        return dateFormatter.string(from: date)
    }
    
    // 時間をフォーマット
    func formatMatchTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    }
    
    // 日付が今日かどうか
    func isToday(_ date: Date) -> Bool {
        return Calendar.current.isDateInToday(date)
    }
    
    // 日付が明日かどうか
    func isTomorrow(_ date: Date) -> Bool {
        return Calendar.current.isDateInTomorrow(date)
    }
    
    // 日付が今週かどうか
    func isThisWeek(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        return date >= startOfWeek && date < endOfWeek
    }
}
