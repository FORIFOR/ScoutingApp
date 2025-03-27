import Foundation
import Combine

// ユーザーモデル
struct User: Codable, Identifiable {
    var id: String
    var email: String
    var username: String
    var favoriteClub: String?
    var region: String?
    var bio: String?
    var profileImageUrl: String?
    var createdAt: Date
    var updatedAt: Date
    var isClubUser: Bool
    var points: Int
    
    init(id: String = UUID().uuidString, 
         email: String, 
         username: String, 
         favoriteClub: String? = nil, 
         region: String? = nil, 
         bio: String? = nil, 
         profileImageUrl: String? = nil, 
         createdAt: Date = Date(), 
         updatedAt: Date = Date(), 
         isClubUser: Bool = false, 
         points: Int = 0) {
        self.id = id
        self.email = email
        self.username = username
        self.favoriteClub = favoriteClub
        self.region = region
        self.bio = bio
        self.profileImageUrl = profileImageUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isClubUser = isClubUser
        self.points = points
    }
}

// クラブモデル
struct Club: Codable, Identifiable {
    var id: String
    var name: String
    var logoUrl: String?
    var description: String?
    var category: String // J1, J2, J3, JFL, 大学など
    var region: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, 
         name: String, 
         logoUrl: String? = nil, 
         description: String? = nil, 
         category: String, 
         region: String, 
         createdAt: Date = Date(), 
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.logoUrl = logoUrl
        self.description = description
        self.category = category
        self.region = region
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// 試合モデル
struct Match: Codable, Identifiable {
    var id: String
    var homeTeamId: String
    var awayTeamId: String
    var homeTeam: Club?
    var awayTeam: Club?
    var date: Date
    var venue: String
    var category: String // J1, J2, J3, JFL, 大学など
    var status: MatchStatus
    var interestedClubs: [String] // 注目しているクラブのID
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, 
         homeTeamId: String, 
         awayTeamId: String, 
         homeTeam: Club? = nil, 
         awayTeam: Club? = nil, 
         date: Date, 
         venue: String, 
         category: String, 
         status: MatchStatus = .scheduled, 
         interestedClubs: [String] = [], 
         createdAt: Date = Date(), 
         updatedAt: Date = Date()) {
        self.id = id
        self.homeTeamId = homeTeamId
        self.awayTeamId = awayTeamId
        self.homeTeam = homeTeam
        self.awayTeam = awayTeam
        self.date = date
        self.venue = venue
        self.category = category
        self.status = status
        self.interestedClubs = interestedClubs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// 試合ステータス
enum MatchStatus: String, Codable {
    case scheduled // 予定
    case live      // 進行中
    case completed // 完了
    case cancelled // キャンセル
}

// 選手モデル
struct Player: Codable, Identifiable {
    var id: String
    var name: String
    var position: String
    var clubId: String
    var club: Club?
    var dateOfBirth: Date?
    var height: Int?
    var weight: Int?
    var nationality: String?
    var profileImageUrl: String?
    var description: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, 
         name: String, 
         position: String, 
         clubId: String, 
         club: Club? = nil, 
         dateOfBirth: Date? = nil, 
         height: Int? = nil, 
         weight: Int? = nil, 
         nationality: String? = nil, 
         profileImageUrl: String? = nil, 
         description: String? = nil, 
         createdAt: Date = Date(), 
         updatedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.position = position
        self.clubId = clubId
        self.club = club
        self.dateOfBirth = dateOfBirth
        self.height = height
        self.weight = weight
        self.nationality = nationality
        self.profileImageUrl = profileImageUrl
        self.description = description
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// スカウティングレポートテンプレートモデル
struct ReportTemplate: Codable, Identifiable {
    var id: String
    var clubId: String
    var name: String
    var description: String?
    var evaluationItems: [EvaluationItem]
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, 
         clubId: String, 
         name: String, 
         description: String? = nil, 
         evaluationItems: [EvaluationItem] = [], 
         isActive: Bool = true, 
         createdAt: Date = Date(), 
         updatedAt: Date = Date()) {
        self.id = id
        self.clubId = clubId
        self.name = name
        self.description = description
        self.evaluationItems = evaluationItems
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// 評価項目モデル
struct EvaluationItem: Codable, Identifiable {
    var id: String
    var name: String
    var description: String?
    var maxRating: Int
    
    init(id: String = UUID().uuidString, 
         name: String, 
         description: String? = nil, 
         maxRating: Int = 5) {
        self.id = id
        self.name = name
        self.description = description
        self.maxRating = maxRating
    }
}

// スカウティングレポートモデル
struct ScoutingReport: Codable, Identifiable {
    var id: String
    var userId: String
    var clubId: String
    var playerId: String
    var matchId: String
    var templateId: String
    var status: ReportStatus
    var evaluations: [Evaluation]
    var overallComment: String?
    var mediaUrls: [String]
    var likes: Int
    var feedback: String?
    var pointsAwarded: Int
    var createdAt: Date
    var updatedAt: Date
    
    init(id: String = UUID().uuidString, 
         userId: String, 
         clubId: String, 
         playerId: String, 
         matchId: String, 
         templateId: String, 
         status: ReportStatus = .draft, 
         evaluations: [Evaluation] = [], 
         overallComment: String? = nil, 
         mediaUrls: [String] = [], 
         likes: Int = 0, 
         feedback: String? = nil, 
         pointsAwarded: Int = 0, 
         createdAt: Date = Date(), 
         updatedAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.clubId = clubId
        self.playerId = playerId
        self.matchId = matchId
        self.templateId = templateId
        self.status = status
        self.evaluations = evaluations
        self.overallComment = overallComment
        self.mediaUrls = mediaUrls
        self.likes = likes
        self.feedback = feedback
        self.pointsAwarded = pointsAwarded
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// レポートステータス
enum ReportStatus: String, Codable {
    case draft      // 下書き
    case submitted  // 提出済み
    case reviewed   // 評価済み
}

// 評価モデル
struct Evaluation: Codable, Identifiable {
    var id: String
    var itemId: String
    var rating: Int
    var comment: String?
    
    init(id: String = UUID().uuidString, 
         itemId: String, 
         rating: Int, 
         comment: String? = nil) {
        self.id = id
        self.itemId = itemId
        self.rating = rating
        self.comment = comment
    }
}

// 通知モデル
struct Notification: Codable, Identifiable {
    var id: String
    var userId: String
    var type: NotificationType
    var title: String
    var message: String
    var relatedId: String?
    var isRead: Bool
    var createdAt: Date
    
    init(id: String = UUID().uuidString, 
         userId: String, 
         type: NotificationType, 
         title: String, 
         message: String, 
         relatedId: String? = nil, 
         isRead: Bool = false, 
         createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.type = type
        self.title = title
        self.message = message
        self.relatedId = relatedId
        self.isRead = isRead
        self.createdAt = createdAt
    }
}

// 通知タイプ
enum NotificationType: String, Codable {
    case like       // いいね
    case feedback   // フィードバック
    case points     // ポイント付与
    case system     // システム通知
}

// ポイント履歴モデル
struct PointHistory: Codable, Identifiable {
    var id: String
    var userId: String
    var amount: Int
    var type: PointType
    var description: String
    var relatedId: String?
    var createdAt: Date
    
    init(id: String = UUID().uuidString, 
         userId: String, 
         amount: Int, 
         type: PointType, 
         description: String, 
         relatedId: String? = nil, 
         createdAt: Date = Date()) {
        self.id = id
        self.userId = userId
        self.amount = amount
        self.type = type
        self.description = description
        self.relatedId = relatedId
        self.createdAt = createdAt
    }
}

// ポイントタイプ
enum PointType: String, Codable {
    case earned     // 獲得
    case redeemed   // 交換
    case expired    // 期限切れ
}
