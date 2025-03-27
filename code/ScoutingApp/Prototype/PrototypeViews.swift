import SwiftUI

// アプリのカラーテーマを定義
struct AppColors {
    static let mainBlue = Color(hex: "1A73E8")
    static let accentGreen = Color(hex: "34A853")
    static let supportRed = Color(hex: "EA4335")
    static let supportYellow = Color(hex: "FBBC05")
    static let darkGrey = Color(hex: "202124")
    static let mediumGrey = Color(hex: "5F6368")
    static let lightGrey = Color(hex: "E8EAED")
    static let white = Color.white
}

// 16進数からColorを生成するための拡張
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// アプリのテキストスタイルを定義
struct AppTextStyles {
    static let h1 = Font.system(size: 28, weight: .bold)
    static let h2 = Font.system(size: 22, weight: .semibold)
    static let h3 = Font.system(size: 20, weight: .medium)
    static let h4 = Font.system(size: 17, weight: .medium)
    static let body = Font.system(size: 17, weight: .regular)
    static let secondary = Font.system(size: 15, weight: .regular)
    static let caption = Font.system(size: 13, weight: .regular)
    static let small = Font.system(size: 11, weight: .regular)
}

// 共通のボタンスタイル
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(AppColors.mainBlue)
            .foregroundColor(AppColors.white)
            .font(Font.system(size: 17, weight: .semibold))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(AppColors.white)
            .foregroundColor(AppColors.mainBlue)
            .font(Font.system(size: 17, weight: .semibold))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppColors.mainBlue, lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

// スプラッシュ画面
struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            OnboardingView()
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [AppColors.mainBlue, AppColors.mainBlue.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("ファンがスカウトマンになれる")
                        .font(AppTextStyles.h1)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

// オンボーディング画面
struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isShowingLoginScreen = false
    
    let pages = [
        OnboardingPage(
            title: "サッカー界に革命を",
            description: "ファンの情熱とクラブの専門性を繋ぐ、革新的なスカウティングプラットフォーム",
            imageName: "figure.soccer"
        ),
        OnboardingPage(
            title: "あなたの目がクラブの力に",
            description: "試合を観戦しながら、プロ目線のスカウティングレポートを作成できます",
            imageName: "eye.fill"
        ),
        OnboardingPage(
            title: "貢献に対する報酬",
            description: "クラブから評価されたレポートには報酬が付与され、特典と交換できます",
            imageName: "gift.fill"
        ),
        OnboardingPage(
            title: "さあ、始めましょう",
            description: "あなたの情熱がサッカー界の未来を変えます",
            imageName: "arrow.right.circle.fill"
        )
    ]
    
    var body: some View {
        if isShowingLoginScreen {
            LoginSelectionView()
        } else {
            ZStack {
                AppColors.white.edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingLoginScreen = true
                        }) {
                            Text("スキップ")
                                .foregroundColor(AppColors.mainBlue)
                                .font(AppTextStyles.secondary)
                                .padding()
                        }
                    }
                    
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            VStack(spacing: 20) {
                                Image(systemName: pages[index].imageName)
                                    .font(.system(size: 120))
                                    .foregroundColor(AppColors.mainBlue)
                                    .padding(.bottom, 20)
                                
                                Text(pages[index].title)
                                    .font(AppTextStyles.h2)
                                    .foregroundColor(AppColors.darkGrey)
                                    .multilineTextAlignment(.center)
                                
                                Text(pages[index].description)
                                    .font(AppTextStyles.body)
                                    .foregroundColor(AppColors.mediumGrey)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                                
                                Spacer()
                            }
                            .tag(index)
                            .padding(.top, 50)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    HStack(spacing: 10) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? AppColors.mainBlue : AppColors.lightGrey)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            isShowingLoginScreen = true
                        }
                    }) {
                        HStack {
                            Text(currentPage < pages.count - 1 ? "次へ" : "始める")
                            Image(systemName: "arrow.right")
                        }
                        .frame(minWidth: 200)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// オンボーディングページのデータモデル
struct OnboardingPage {
    let title: String
    let description: String
    let imageName: String
}

// ログイン選択画面
struct LoginSelectionView: View {
    @State private var isShowingRegistration = false
    @State private var isShowingLogin = false
    
    var body: some View {
        if isShowingRegistration {
            RegistrationView()
        } else if isShowingLogin {
            LoginView()
        } else {
            ZStack {
                AppColors.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.mainBlue)
                    
                    Text("ファンスカウト")
                        .font(AppTextStyles.h1)
                        .foregroundColor(AppColors.darkGrey)
                    
                    Spacer()
                    
                    Button(action: {
                        isShowingRegistration = true
                    }) {
                        Text("新規登録")
                            .frame(minWidth: 250)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    
                    Button(action: {
                        isShowingLogin = true
                    }) {
                        Text("ログイン")
                            .frame(minWidth: 250)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    
                    Text("アカウントをお持ちでない方は新規登録してください")
                        .font(AppTextStyles.caption)
                        .foregroundColor(AppColors.mediumGrey)
                        .padding(.top, 10)
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
            }
        }
    }
}

// 登録画面
struct RegistrationView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isShowingProfileSetup = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        if isShowingProfileSetup {
            ProfileSetupView()
        } else {
            NavigationView {
                ZStack {
                    AppColors.white.edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("メールアドレス")
                                    .font(AppTextStyles.secondary)
                                    .foregroundColor(AppColors.darkGrey)
                                
                                TextField("", text: $email)
                                    .padding()
                                    .background(AppColors.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.lightGrey, lineWidth: 1)
                                    )
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("パスワード")
                                    .font(AppTextStyles.secondary)
                                    .foregroundColor(AppColors.darkGrey)
                                
                                SecureField("", text: $password)
                                    .padding()
                                    .background(AppColors.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.lightGrey, lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("パスワード（確認）")
                                    .font(AppTextStyles.secondary)
                                    .foregroundColor(AppColors.darkGrey)
                                
                                SecureField("", text: $confirmPassword)
                                    .padding()
                                    .background(AppColors.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.lightGrey, lineWidth: 1)
                                    )
                            }
                            
                            Button(action: {
                                if validateInputs() {
                                    isShowingProfileSetup = true
                                } else {
                                    showingAlert = true
                                }
                            }) {
                                Text("登録する")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding(.top, 20)
                            
                            Text("または")
                                .font(AppTextStyles.secondary)
                                .foregroundColor(AppColors.mediumGrey)
                                .padding(.vertical, 10)
                            
                            HStack(spacing: 20) {
                                Button(action: {}) {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: 20))
                                        .frame(width: 50, height: 50)
                                        .background(AppColors.darkGrey)
                                        .foregroundColor(.white)
                                        .cornerRadius(25)
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "g.circle.fill")
                                        .font(.system(size: 20))
                                        .frame(width: 50, height: 50)
                                        .background(AppColors.supportRed)
                                        .foregroundColor(.white)
                                        .cornerRadius(25)
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "f.circle.fill")
                                        .font(.system(size: 20))
                                        .frame(width: 50, height: 50)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(25)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 30)
                    }
                    .navigationBarTitle("新規登録", displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.mainBlue)
                    })
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("エラー"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
        }
    }
    
    private func validateInputs() -> Bool {
        if email.isEmpty {
            alertMessage = "メールアドレスを入力してください"
            return false
        }
        
        if !email.contains("@") || !email.contains(".") {
            alertMessage = "有効なメールアドレスを入力してください"
            return false
        }
        
        if password.isEmpty {
            alertMessage = "パスワードを入力してください"
            return false
        }
        
        if password.count < 8 {
            alertMessage = "パスワードは8文字以上で入力してください"
            return false
        }
        
        if password != confirmPassword {
            alertMessage = "パスワードが一致しません"
            return false
        }
        
        return true
    }
}

// ログイン画面
struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingHomeScreen = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        if isShowingHomeScreen {
            HomeView()
        } else {
            NavigationView {
                ZStack {
                    AppColors.white.edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("メールアドレス")
                                    .font(AppTextStyles.secondary)
                                    .foregroundColor(AppColors.darkGrey)
                                
                                TextField("", text: $email)
                                    .padding()
                                    .background(AppColors.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.lightGrey, lineWidth: 1)
                                    )
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("パスワード")
                                    .font(AppTextStyles.secondary)
                                    .foregroundColor(AppColors.darkGrey)
                                
                                SecureField("", text: $password)
                                    .padding()
                                    .background(AppColors.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.lightGrey, lineWidth: 1)
                                    )
                            }
                            
                            Button(action: {
                                if validateInputs() {
                                    isShowingHomeScreen = true
                                } else {
                                    showingAlert = true
                                }
                            }) {
                                Text("ログイン")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding(.top, 20)
                            
                            Button(action: {}) {
                                Text("パスワードをお忘れですか？")
                                    .font(AppTextStyles.secondary)
                                    .foregroundColor(AppColors.mainBlue)
                            }
                            .padding(.top, 10)
                            
                            Text("または")
                                .font(AppTextStyles.secondary)
                                .foregroundColor(AppColors.mediumGrey)
                                .padding(.vertical, 10)
                            
                            HStack(spacing: 20) {
                                Button(action: {}) {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: 20))
                                        .frame(width: 50, height: 50)
                                        .background(AppColors.darkGrey)
                                        .foregroundColor(.white)
                                        .cornerRadius(25)
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "g.circle.fill")
                                        .font(.system(size: 20))
                                        .frame(width: 50, height: 50)
                                        .background(AppColors.supportRed)
                                        .foregroundColor(.white)
                                        .cornerRadius(25)
                                }
                                
                                Button(action: {}) {
                                    Image(systemName: "f.circle.fill")
                                        .font(.system(size: 20))
                                        .frame(width: 50, height: 50)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(25)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 30)
                    }
                    .navigationBarTitle("ログイン", displayMode: .inline)
                    .navigationBarItems(leading: Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.mainBlue)
                    })
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("エラー"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
        }
    }
    
    private func validateInputs() -> Bool {
        if email.isEmpty {
            alertMessage = "メールアドレスを入力してください"
            return false
        }
        
        if password.isEmpty {
            alertMessage = "パスワードを入力してください"
            return false
        }
        
        // デモ用に簡易的な検証
        return true
    }
}

// プロフィール設定画面
struct ProfileSetupView: View {
    @State private var username = ""
    @State private var selectedClub = "未選択"
    @State private var selectedRegion = "未選択"
    @State private var bio = ""
    @State private var isShowingHomeScreen = false
    @State private var showingClubPicker = false
    @State private var showingRegionPicker = false
    
    let clubs = ["FC東京", "浦和レッズ", "鹿島アントラーズ", "ガンバ大阪", "セレッソ大阪", "横浜F・マリノス", "サンフレッチェ広島", "名古屋グランパス"]
    let regions = ["北海道", "東北", "関東", "中部", "関西", "中国", "四国", "九州"]
    
    var body: some View {
        if isShowingHomeScreen {
            HomeView()
        } else {
            NavigationView {
                ZStack {
                    AppColors.white.edgesIgnoringSafeArea(.all)
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // プロフィール画像
                            ZStack {
                                Circle()
                                    .fill(AppColors.lightGrey)
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(AppColors.mediumGrey)
                                
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Circle()
                                            .fill(AppColors.mainBlue)
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                }
                                .frame(width: 100, height: 100)
                            }
                            .padding(.top, 20)
                            
                            // ユーザー名
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ユーザー名")
                                    .font(AppTextStyles.secondary)
                                    .foregroundColor(AppColors.darkGrey)
                                
                                TextField("", text: $username)
                                    .padding()
                                    .background(AppColors.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.lightGrey, lineWidth: 1)
                                    )
                            }
                            
                            // 応援するクラブ
                            VStack(alignment: .leading, spacing: 8) {
                                Text("応援するクラブ")
                                    .font(AppTextStyles.secondary)
                                    .foregroundColor(AppColors.darkGrey)
                                
                                Button(action: {
                                    showingClubPicker = true
                                }) {
                                    HStack {
                                        Text(selectedClub)
                                            .foregroundColor(selectedClub == "未選択" ? AppColors.mediumGrey : AppColors.darkGrey)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(AppColors.mediumGrey)
                                    }
                                    .padding()
                                    .background(AppColors.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.lightGrey, lineWidth: 1)
                                    )
                                }
                                .actionSheet(isPresented: $showingClubPicker) {
                                    ActionSheet(
                                        title: Text("応援するクラブを選択"),
                                        buttons: clubs.map { club in
                                            .default(Text(club)) {
                                                selectedClub = club
                                            }
                                        } + [.cancel(Text("キャンセル"))]
                                    )
                                }
                            }
                            
                            // 活動地域
                            VStack(alignment: .leading, spacing: 8) {
                                Text("活動地域")
                                    .font(AppTextStyles.secondary)
                                    .foregroundColor(AppColors.darkGrey)
                                
                                Button(action: {
                                    showingRegionPicker = true
                                }) {
                                    HStack {
                                        Text(selectedRegion)
                                            .foregroundColor(selectedRegion == "未選択" ? AppColors.mediumGrey : AppColors.darkGrey)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(AppColors.mediumGrey)
                                    }
                                    .padding()
                                    .background(AppColors.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.lightGrey, lineWidth: 1)
                                    )
                                }
                                .actionSheet(isPresented: $showingRegionPicker) {
                                    ActionSheet(
                                        title: Text("活動地域を選択"),
                                        buttons: regions.map { region in
                                            .default(Text(region)) {
                                                selectedRegion = region
                                            }
                                        } + [.cancel(Text("キャンセル"))]
                                    )
                                }
                            }
                            
                            // 自己紹介
                            VStack(alignment: .leading, spacing: 8) {
                                Text("自己紹介")
                                    .font(AppTextStyles.secondary)
                                    .foregroundColor(AppColors.darkGrey)
                                
                                TextEditor(text: $bio)
                                    .frame(height: 100)
                                    .padding(4)
                                    .background(AppColors.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppColors.lightGrey, lineWidth: 1)
                                    )
                            }
                            
                            // 保存ボタン
                            Button(action: {
                                isShowingHomeScreen = true
                            }) {
                                Text("保存する")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding(.top, 20)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                    .navigationBarTitle("プロフィール設定", displayMode: .inline)
                }
            }
        }
    }
}

// ホーム画面
struct HomeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTabView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
                .tag(0)
            
            ScheduleTabView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("スケジュール")
                }
                .tag(1)
            
            ReportTabView()
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("レポート")
                }
                .tag(2)
            
            ProfileTabView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("プロフィール")
                }
                .tag(3)
        }
        .accentColor(AppColors.mainBlue)
    }
}

// ホームタブ
struct HomeTabView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // ユーザーグリーティング
                    Text("こんにちは、サッカーファンさん")
                        .font(AppTextStyles.h3)
                        .foregroundColor(AppColors.darkGrey)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    
                    // 今日の注目試合
                    VStack(alignment: .leading, spacing: 10) {
                        Text("今日の注目試合")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.darkGrey)
                            .padding(.horizontal, 20)
                        
                        MatchCard(
                            homeTeam: "FC東京",
                            awayTeam: "浦和レッズ",
                            time: "19:00",
                            venue: "味の素スタジアム"
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // スカウト実績
                    VStack(alignment: .leading, spacing: 10) {
                        Text("あなたのスカウト実績")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.darkGrey)
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 0) {
                            StatItem(title: "レポート数", value: "5件", icon: "doc.text.fill")
                            Divider().frame(height: 40)
                            StatItem(title: "いいね数", value: "12", icon: "heart.fill")
                            Divider().frame(height: 40)
                            StatItem(title: "獲得ポイント", value: "250pt", icon: "star.fill")
                        }
                        .padding(.vertical, 15)
                        .background(AppColors.lightGrey.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                    }
                    
                    // 最近のフィードバック
                    VStack(alignment: .leading, spacing: 10) {
                        Text("最近のフィードバック")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.darkGrey)
                            .padding(.horizontal, 20)
                        
                        FeedbackCard(
                            clubName: "FC東京",
                            reportTitle: "三笘薫選手のスカウティングレポート",
                            time: "2日前"
                        )
                        .padding(.horizontal, 20)
                        
                        FeedbackCard(
                            clubName: "浦和レッズ",
                            reportTitle: "興梠慎三選手のスカウティングレポート",
                            time: "1週間前"
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // おすすめの試合
                    VStack(alignment: .leading, spacing: 10) {
                        Text("おすすめの試合")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.darkGrey)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(0..<5) { _ in
                                    SmallMatchCard(
                                        homeTeam: "鹿島",
                                        awayTeam: "G大阪",
                                        date: "3/30",
                                        time: "14:00"
                                    )
                                    .frame(width: 150)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .navigationBarTitle("ホーム", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.mainBlue)
                },
                trailing: Button(action: {}) {
                    Image(systemName: "bell")
                        .foregroundColor(AppColors.mainBlue)
                }
            )
        }
    }
}

// 試合カード
struct MatchCard: View {
    let homeTeam: String
    let awayTeam: String
    let time: String
    let venue: String
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(AppColors.mainBlue)
                .frame(width: 4)
            
            VStack(spacing: 15) {
                HStack {
                    VStack {
                        Image(systemName: "sportscourt.fill")
                            .font(.system(size: 30))
                            .foregroundColor(AppColors.mainBlue)
                        Text(homeTeam)
                            .font(AppTextStyles.body)
                            .foregroundColor(AppColors.darkGrey)
                    }
                    
                    Spacer()
                    
                    Text("VS")
                        .font(AppTextStyles.h3)
                        .foregroundColor(AppColors.mediumGrey)
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "sportscourt.fill")
                            .font(.system(size: 30))
                            .foregroundColor(AppColors.supportRed)
                        Text(awayTeam)
                            .font(AppTextStyles.body)
                            .foregroundColor(AppColors.darkGrey)
                    }
                }
                
                HStack {
                    HStack {
                        Image(systemName: "clock.fill")
                            .foregroundColor(AppColors.mediumGrey)
                        Text(time)
                            .font(AppTextStyles.secondary)
                            .foregroundColor(AppColors.mediumGrey)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(AppColors.mediumGrey)
                        Text(venue)
                            .font(AppTextStyles.secondary)
                            .foregroundColor(AppColors.mediumGrey)
                    }
                }
                
                Button(action: {}) {
                    Text("詳細を見る")
                        .font(AppTextStyles.secondary)
                        .foregroundColor(AppColors.mainBlue)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 10)
        }
        .background(AppColors.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// 小さい試合カード
struct SmallMatchCard: View {
    let homeTeam: String
    let awayTeam: String
    let date: String
    let time: String
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack {
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.mainBlue)
                    Text(homeTeam)
                        .font(AppTextStyles.caption)
                        .foregroundColor(AppColors.darkGrey)
                }
                
                Spacer()
                
                Text("VS")
                    .font(AppTextStyles.secondary)
                    .foregroundColor(AppColors.mediumGrey)
                
                Spacer()
                
                VStack {
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppColors.supportRed)
                    Text(awayTeam)
                        .font(AppTextStyles.caption)
                        .foregroundColor(AppColors.darkGrey)
                }
            }
            
            HStack {
                Text(date)
                    .font(AppTextStyles.small)
                    .foregroundColor(AppColors.mediumGrey)
                
                Spacer()
                
                Text(time)
                    .font(AppTextStyles.small)
                    .foregroundColor(AppColors.mediumGrey)
            }
        }
        .padding(10)
        .background(AppColors.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

// 統計アイテム
struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .foregroundColor(AppColors.mainBlue)
            
            Text(value)
                .font(AppTextStyles.h3)
                .foregroundColor(AppColors.mainBlue)
            
            Text(title)
                .font(AppTextStyles.caption)
                .foregroundColor(AppColors.mediumGrey)
        }
        .frame(maxWidth: .infinity)
    }
}

// フィードバックカード
struct FeedbackCard: View {
    let clubName: String
    let reportTitle: String
    let time: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "heart.fill")
                .font(.system(size: 20))
                .foregroundColor(AppColors.supportRed)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("\(clubName)からのいいね")
                    .font(AppTextStyles.body)
                    .foregroundColor(AppColors.darkGrey)
                
                Text(reportTitle)
                    .font(AppTextStyles.secondary)
                    .foregroundColor(AppColors.mediumGrey)
                
                Text(time)
                    .font(AppTextStyles.caption)
                    .foregroundColor(AppColors.mediumGrey)
            }
            
            Spacer()
        }
        .padding(15)
        .background(AppColors.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// スケジュールタブ
struct ScheduleTabView: View {
    @State private var selectedRegion = "全国"
    @State private var selectedDate = "今週"
    
    let regions = ["全国", "関東", "関西", "中部", "東北", "北海道", "中国", "四国", "九州"]
    let dates = ["今日", "明日", "今週", "来週", "今月"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // フィルター
                    HStack {
                        Menu {
                            ForEach(regions, id: \.self) { region in
                                Button(action: {
                                    selectedRegion = region
                                }) {
                                    Text(region)
                                }
                            }
                        } label: {
                            HStack {
                                Text("地域: \(selectedRegion)")
                                    .foregroundColor(AppColors.darkGrey)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppColors.mediumGrey)
                            }
                            .padding(10)
                            .background(AppColors.lightGrey.opacity(0.5))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Menu {
                            ForEach(dates, id: \.self) { date in
                                Button(action: {
                                    selectedDate = date
                                }) {
                                    Text(date)
                                }
                            }
                        } label: {
                            HStack {
                                Text("日付: \(selectedDate)")
                                    .foregroundColor(AppColors.darkGrey)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppColors.mediumGrey)
                            }
                            .padding(10)
                            .background(AppColors.lightGrey.opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 今日の試合
                    VStack(alignment: .leading, spacing: 10) {
                        Text("今日の試合")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.darkGrey)
                            .padding(.horizontal, 20)
                        
                        ScheduleMatchCard(
                            homeTeam: "FC東京",
                            awayTeam: "浦和レッズ",
                            time: "19:00",
                            venue: "味の素スタジアム",
                            interestedClubs: ["FC東京"]
                        )
                        .padding(.horizontal, 20)
                        
                        ScheduleMatchCard(
                            homeTeam: "横浜FM",
                            awayTeam: "鹿島",
                            time: "14:00",
                            venue: "日産スタジアム",
                            interestedClubs: ["横浜FM", "鹿島"]
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // 明日の試合
                    VStack(alignment: .leading, spacing: 10) {
                        Text("明日の試合")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.darkGrey)
                            .padding(.horizontal, 20)
                        
                        ScheduleMatchCard(
                            homeTeam: "G大阪",
                            awayTeam: "C大阪",
                            time: "13:00",
                            venue: "パナソニックスタジアム",
                            interestedClubs: ["G大阪"]
                        )
                        .padding(.horizontal, 20)
                        
                        ScheduleMatchCard(
                            homeTeam: "名古屋",
                            awayTeam: "広島",
                            time: "16:00",
                            venue: "豊田スタジアム",
                            interestedClubs: ["名古屋", "広島"]
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // 今週の試合
                    VStack(alignment: .leading, spacing: 10) {
                        Text("今週の試合")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.darkGrey)
                            .padding(.horizontal, 20)
                        
                        ScheduleMatchCard(
                            homeTeam: "川崎F",
                            awayTeam: "柏",
                            time: "19:00",
                            venue: "等々力陸上競技場",
                            date: "3/30",
                            interestedClubs: ["川崎F"]
                        )
                        .padding(.horizontal, 20)
                        
                        ScheduleMatchCard(
                            homeTeam: "湘南",
                            awayTeam: "福岡",
                            time: "15:00",
                            venue: "レベルファイブスタジアム",
                            date: "3/31",
                            interestedClubs: ["湘南"]
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 10)
            }
            .navigationBarTitle("試合スケジュール", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.mainBlue)
                },
                trailing: Button(action: {}) {
                    Image(systemName: "calendar")
                        .foregroundColor(AppColors.mainBlue)
                }
            )
        }
    }
}

// スケジュール試合カード
struct ScheduleMatchCard: View {
    let homeTeam: String
    let awayTeam: String
    let time: String
    let venue: String
    var date: String? = nil
    let interestedClubs: [String]
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack {
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 30))
                        .foregroundColor(AppColors.mainBlue)
                    Text(homeTeam)
                        .font(AppTextStyles.body)
                        .foregroundColor(AppColors.darkGrey)
                }
                
                Spacer()
                
                Text("VS")
                    .font(AppTextStyles.h3)
                    .foregroundColor(AppColors.mediumGrey)
                
                Spacer()
                
                VStack {
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 30))
                        .foregroundColor(AppColors.supportRed)
                    Text(awayTeam)
                        .font(AppTextStyles.body)
                        .foregroundColor(AppColors.darkGrey)
                }
            }
            
            HStack {
                if let date = date {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(AppColors.mediumGrey)
                        Text(date)
                            .font(AppTextStyles.secondary)
                            .foregroundColor(AppColors.mediumGrey)
                    }
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(AppColors.mediumGrey)
                    Text(time)
                        .font(AppTextStyles.secondary)
                        .foregroundColor(AppColors.mediumGrey)
                }
                
                Spacer()
                
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(AppColors.mediumGrey)
                    Text(venue)
                        .font(AppTextStyles.secondary)
                        .foregroundColor(AppColors.mediumGrey)
                }
            }
            
            HStack {
                Text("注目クラブ:")
                    .font(AppTextStyles.caption)
                    .foregroundColor(AppColors.mediumGrey)
                
                ForEach(interestedClubs, id: \.self) { club in
                    Text(club)
                        .font(AppTextStyles.caption)
                        .foregroundColor(AppColors.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.mainBlue)
                        .cornerRadius(4)
                }
                
                Spacer()
            }
        }
        .padding(15)
        .background(AppColors.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// レポートタブ
struct ReportTabView: View {
    @State private var selectedStatus = "全て"
    @State private var selectedDate = "全て"
    
    let statuses = ["全て", "下書き", "提出済", "評価済"]
    let dates = ["全て", "今週", "今月", "3ヶ月"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // フィルター
                    HStack {
                        Menu {
                            ForEach(statuses, id: \.self) { status in
                                Button(action: {
                                    selectedStatus = status
                                }) {
                                    Text(status)
                                }
                            }
                        } label: {
                            HStack {
                                Text("状態: \(selectedStatus)")
                                    .foregroundColor(AppColors.darkGrey)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppColors.mediumGrey)
                            }
                            .padding(10)
                            .background(AppColors.lightGrey.opacity(0.5))
                            .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Menu {
                            ForEach(dates, id: \.self) { date in
                                Button(action: {
                                    selectedDate = date
                                }) {
                                    Text(date)
                                }
                            }
                        } label: {
                            HStack {
                                Text("日付: \(selectedDate)")
                                    .foregroundColor(AppColors.darkGrey)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(AppColors.mediumGrey)
                            }
                            .padding(10)
                            .background(AppColors.lightGrey.opacity(0.5))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // レポート一覧
                    VStack(spacing: 15) {
                        ReportCard(
                            playerName: "三笘薫",
                            matchName: "FC東京 vs 浦和レッズ",
                            date: "2025/3/25",
                            status: "評価済",
                            likes: 5
                        )
                        .padding(.horizontal, 20)
                        
                        ReportCard(
                            playerName: "久保建英",
                            matchName: "横浜FM vs 鹿島",
                            date: "2025/3/20",
                            status: "提出済",
                            likes: 2
                        )
                        .padding(.horizontal, 20)
                        
                        ReportCard(
                            playerName: "堂安律",
                            matchName: "G大阪 vs C大阪",
                            date: "2025/3/15",
                            status: "評価済",
                            likes: 3
                        )
                        .padding(.horizontal, 20)
                        
                        ReportCard(
                            playerName: "前田大然",
                            matchName: "名古屋 vs 広島",
                            date: "2025/3/10",
                            status: "下書き",
                            likes: 0
                        )
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 10)
            }
            .navigationBarTitle("マイレポート", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.mainBlue)
                },
                trailing: Button(action: {}) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(AppColors.mainBlue)
                }
            )
        }
    }
}

// レポートカード
struct ReportCard: View {
    let playerName: String
    let matchName: String
    let date: String
    let status: String
    let likes: Int
    
    var statusColor: Color {
        switch status {
        case "下書き":
            return AppColors.mediumGrey
        case "提出済":
            return AppColors.supportYellow
        case "評価済":
            return AppColors.accentGreen
        default:
            return AppColors.mediumGrey
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(playerName)
                .font(AppTextStyles.h4)
                .foregroundColor(AppColors.darkGrey)
            
            HStack {
                Text(matchName)
                    .font(AppTextStyles.secondary)
                    .foregroundColor(AppColors.mediumGrey)
                
                Spacer()
                
                Text(date)
                    .font(AppTextStyles.caption)
                    .foregroundColor(AppColors.mediumGrey)
            }
            
            HStack {
                Text(status)
                    .font(AppTextStyles.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor)
                    .cornerRadius(4)
                
                Spacer()
                
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(AppColors.supportRed)
                    Text("\(likes)")
                        .font(AppTextStyles.secondary)
                        .foregroundColor(AppColors.darkGrey)
                }
            }
        }
        .padding(15)
        .background(AppColors.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// プロフィールタブ
struct ProfileTabView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // プロフィールヘッダー
                    VStack(spacing: 10) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.mainBlue)
                        
                        Text("サッカーファン")
                            .font(AppTextStyles.h2)
                            .foregroundColor(AppColors.darkGrey)
                        
                        HStack {
                            Image(systemName: "sportscourt.fill")
                                .foregroundColor(AppColors.mainBlue)
                            Text("応援クラブ: FC東京")
                                .font(AppTextStyles.secondary)
                                .foregroundColor(AppColors.mediumGrey)
                        }
                        
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(AppColors.mainBlue)
                            Text("活動地域: 関東")
                                .font(AppTextStyles.secondary)
                                .foregroundColor(AppColors.mediumGrey)
                        }
                    }
                    .padding(.top, 20)
                    
                    // スカウト実績
                    VStack(alignment: .leading, spacing: 10) {
                        Text("スカウト実績")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.darkGrey)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 15) {
                            HStack(spacing: 0) {
                                StatItem(title: "レポート数", value: "5件", icon: "doc.text.fill")
                                Divider().frame(height: 40)
                                StatItem(title: "いいね数", value: "12", icon: "heart.fill")
                                Divider().frame(height: 40)
                                StatItem(title: "ランキング", value: "24位", icon: "crown.fill")
                            }
                            
                            // 簡易グラフ
                            HStack(spacing: 5) {
                                ForEach(0..<6) { i in
                                    VStack {
                                        Spacer()
                                        Rectangle()
                                            .fill(AppColors.mainBlue)
                                            .frame(height: CGFloat([30, 50, 20, 60, 40, 70][i]))
                                        Text("\(i+1)月")
                                            .font(AppTextStyles.caption)
                                            .foregroundColor(AppColors.mediumGrey)
                                    }
                                    .frame(height: 100)
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        .padding(.vertical, 15)
                        .background(AppColors.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                        .padding(.horizontal, 20)
                    }
                    
                    // ポイント
                    VStack(alignment: .leading, spacing: 10) {
                        Text("ポイント")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.darkGrey)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 15) {
                            Text("250pt")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(AppColors.white)
                            
                            Button(action: {}) {
                                Text("ポイント交換へ")
                                    .font(AppTextStyles.body)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 20)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(20)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [AppColors.mainBlue, AppColors.mainBlue.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .padding(.horizontal, 20)
                    }
                    
                    // 最近のレポート
                    VStack(alignment: .leading, spacing: 10) {
                        Text("最近のレポート")
                            .font(AppTextStyles.h4)
                            .foregroundColor(AppColors.darkGrey)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(0..<3) { i in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(["三笘薫", "久保建英", "堂安律"][i])
                                            .font(AppTextStyles.body)
                                            .foregroundColor(AppColors.darkGrey)
                                        
                                        Text(["FC東京 vs 浦和レッズ", "横浜FM vs 鹿島", "G大阪 vs C大阪"][i])
                                            .font(AppTextStyles.caption)
                                            .foregroundColor(AppColors.mediumGrey)
                                        
                                        HStack {
                                            Image(systemName: "heart.fill")
                                                .foregroundColor(AppColors.supportRed)
                                            Text("\([5, 2, 3][i])")
                                                .font(AppTextStyles.caption)
                                                .foregroundColor(AppColors.darkGrey)
                                        }
                                    }
                                    .padding(15)
                                    .frame(width: 200)
                                    .background(AppColors.white)
                                    .cornerRadius(8)
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    
                    // プロフィール編集ボタン
                    Button(action: {}) {
                        Text("プロフィールを編集")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitle("プロフィール", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {}) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(AppColors.mainBlue)
                }
            )
        }
    }
}

// プレビュー
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
