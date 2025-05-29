import SwiftUI
import PhotosUI
import CoreData
import SafariServices

// 앱 언어 설정을 위한 UserDefaults 키
let appLanguageKey = "AppLanguage"

// 지원하는 언어 enum
enum AppLanguage: String, CaseIterable {
    case system = "system"
    case korean = "ko"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .system: return NSLocalizedString("system_language", comment: "")
        case .korean: return "한국어"
        case .english: return "English"
        }
    }
    
    var locale: Locale {
        switch self {
        case .system: return Locale.current
        case .korean: return Locale(identifier: "ko")
        case .english: return Locale(identifier: "en")
        }
    }
    
    static func setLanguage(_ language: AppLanguage) {
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.set(language.rawValue, forKey: appLanguageKey)
        UserDefaults.standard.synchronize()
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// 프로필 링크 데이터 구조체 추가
struct ProfileLinkData {
    let image: String
    let title: String
    let description: String
    let url: String
}

struct ProfileView: View {
    @FetchRequest(
        entity: UserProfile.entity(),
        sortDescriptors: [],
        animation: .default
    ) var profiles: FetchedResults<UserProfile>
    @Environment(\.managedObjectContext) private var context
    @State private var showImagePicker = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var pendingImagePicker = false
    @FetchRequest(
        entity: Writing.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Writing.date, ascending: false)],
        animation: .default
    ) var writings: FetchedResults<Writing>
    @State private var showProfileOverlay = false
    @State private var showPhotoActionSheet = false
    @State private var showLanguageSheet = false
    @State private var showLanguageChangeAlert = false
    @AppStorage(appLanguageKey) private var currentLanguage: String = AppLanguage.system.rawValue
    @State private var safariURL: URL? = nil
    @State private var showSafari = false

    var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: currentLanguage) ?? .system
    }

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color.white)
                .frame(height: 56)
            HStack {
                Text(NSLocalizedString("profile", comment: ""))
                    .font(.system(size: 22, weight: .bold))
                    .padding(.leading, 12)
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
            .padding(.horizontal, 20)
        }
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray.opacity(0.3))
        HStack(alignment: .center, spacing: 33) {
            ZStack(alignment: .bottomTrailing) {
                if let data = userProfile.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                } else {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray4))
                            .frame(width: 90, height: 90)
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .foregroundColor(.white)
                            .offset(x: 0, y: 0)
                    }
                }
                // +버튼 (단순 표시용, 탭 없음)
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.gray)
                    )
            }
            .contentShape(Rectangle())
            .onTapGesture { showProfileOverlay = true }
            VStack(alignment: .leading, spacing: 12) {
                Text(((userProfile.nickname ?? "").isEmpty ? "Letgo" : (userProfile.nickname ?? "")))
                    .font(.system(size: 20, weight: .bold))
                    .padding(.bottom, 6)
                    .padding(.top, 8)
                HStack(spacing: 36) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(postCount)")
                            .font(.system(size: 15, weight: .bold))
                        Text(NSLocalizedString("post_count", comment: ""))
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .frame(minWidth: 36)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(oneLineCount)")
                            .font(.system(size: 15, weight: .bold))
                        Text(NSLocalizedString("one_line_count", comment: ""))
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .frame(minWidth: 36)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(charCountDisplay)
                            .font(.system(size: 15, weight: .bold))
                        Text(NSLocalizedString("char_count", comment: ""))
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .frame(minWidth: 36)
                }
            }
            Spacer()
        }
        .padding(.top, 20)
        .padding(.bottom, 24)
        .padding(.horizontal, 32)
        Divider()
            .padding(.horizontal, 20)

        // 오버레이
        .fullScreenCover(isPresented: $showProfileOverlay) {
            ZStack {
                // 배경 터치 시 오버레이 닫힘
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture { showProfileOverlay = false }
                VStack(spacing: 32) {
                    ZStack(alignment: .bottomTrailing) {
                        if let data = userProfile.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 220, height: 220)
                                .clipShape(Circle())
                        } else {
                            ZStack(alignment: .center) {
                                Circle()
                                    .fill(Color(.systemGray4))
                                    .frame(width: 220, height: 220)
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 110, height: 110)
                                    .foregroundColor(.white)
                            }
                        }
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.gray)
                            )
                            .offset(x: -6, y: -6)
                    }
                    // 프로필 이미지 터치 시: 오버레이 닫고 모달 띄움
                    .onTapGesture { showPhotoActionSheet = true }
                    .contextMenu {
                        if userProfile.imageData != nil {
                            Button(role: .destructive) {
                                userProfile.imageData = nil
                                try? context.save()
                            } label: {
                                Label(NSLocalizedString("delete_photo", comment: ""), systemImage: "trash")
                            }
                        }
                    }
                    .confirmationDialog(NSLocalizedString("profile_photo", comment: ""), isPresented: $showPhotoActionSheet, titleVisibility: .visible) {
                        if userProfile.imageData == nil {
                            Button(NSLocalizedString("add_photo", comment: "")) {
                                showProfileOverlay = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    pendingImagePicker = true
                                }
                            }
                        } else {
                            Button(NSLocalizedString("change_photo", comment: "")) {
                                showProfileOverlay = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    pendingImagePicker = true
                                }
                            }
                            Button(NSLocalizedString("delete_photo", comment: ""), role: .destructive) {
                                userProfile.imageData = nil
                                try? context.save()
                            }
                        }
                        Button(NSLocalizedString("write_cancel", comment: ""), role: .cancel) {}
                    }
                    VStack(spacing: 0) {
                        TextField("Letgo", text: Binding(
                            get: { userProfile.nickname ?? "" },
                            set: { userProfile.nickname = $0; try? context.save() }
                        ))
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(width: 200)
                        .padding(.bottom, 8)
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 2)
                            .frame(width: 200)
                    }
                }
            }
        }
        

        // --- 외부 링크 카드 리스트 ---
        VStack(alignment: .leading, spacing: 8) {
            ForEach(profileLinks, id: \.url) { link in
                ProfileLinkCard(
                    image: Image(link.image),
                    title: link.title,
                    description: link.description,
                    url: URL(string: link.url),
                    onTap: { url in safariURL = url; showSafari = true }
                )
            }
        }
        .sheet(isPresented: $showSafari) {
            if let url = safariURL {
                SafariView(url: url)
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 8)

        Spacer(minLength: 24)
            .photosPicker(isPresented: $pendingImagePicker, selection: $pickerItem, matching: .images)
            .onChange(of: pickerItem) { newItem in
                if let item = newItem {
                    item.loadTransferable(type: Data.self) { result in
                        if case .success(let data?) = result {
                            DispatchQueue.main.async {
                                userProfile.imageData = data
                            }
                        }
                    }
                }
            }
        Divider()
            .padding(.bottom, 12)

        // --- 앱 버전 및 개인정보처리방침 ---
        Button(action: {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.gray)
                Text(NSLocalizedString("preferred_language_settings", comment: ""))
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
        }
            .padding(.bottom, 12)
        Divider()
            .padding(.bottom, 12)

        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(NSLocalizedString("app_version", comment: ""))
                    .font(.system(size: 14))
                Text("v1.0.0")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {
                if let url = URL(string: "https://gojaehyun.notion.site/Privacy-Policy-202f6a5a5d2f805aa51ecb53d77f5a34") {
                    safariURL = url
                    showSafari = true
                }
            }) {
                Text(NSLocalizedString("privacy_policy", comment: ""))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
        

        
        Button(action: {
            // ... existing developer story action ...
        }) {
            // ... existing developer story button content ...
        }
    }
    

    // 게시물: 세션+자유글쓰기
    var postCount: Int {
        writings.filter { $0.writingType == .threeMin || $0.writingType == .fiveMin || $0.writingType == .sevenMin || $0.writingType == .free }.count
    }
    // 한마디
    var oneLineCount: Int {
        writings.filter { $0.writingType == .oneLine }.count
    }
    // 글자수(제목+본문)
    var charCount: Int {
        writings.reduce(0) { $0 + $1.title.count + $1.content.count }
    }
    // 글자수 표기 (10,000 이상이면 1.2만, 1,000 이상이면 1.2천, 그 미만은 그대로 숫자로 표기)
    var charCountDisplay: String {
        let count = charCount
        let isKorean = Locale.current.languageCode == "ko"
        if count >= 10_000 {
            if isKorean {
                let formatted = Double(count) / 10_000
                let str = String(format: "%.1f", formatted)
                return str.hasSuffix(".0") ? "\(Int(formatted))만" : "\(str)만"
            } else {
                let formatted = Double(count) / 1_000
                let str = String(format: "%.0f", formatted)
                return "\(str)k"
            }
        } else if count >= 1_000 {
            if isKorean {
                let formatted = Double(count) / 1_000
                let str = String(format: "%.1f", formatted)
                return str.hasSuffix(".0") ? "\(Int(formatted))천" : "\(str)천"
            } else {
                let formatted = Double(count) / 1_000
                let str = String(format: "%.1f", formatted)
                return "\(str)k"
            }
        } else {
            return "\(count)"
        }
    }

    var userProfile: UserProfile {
        if let profile = profiles.first {
            return profile
        } else {
            let newProfile = UserProfile(context: context)
            newProfile.nickname = ""
            newProfile.imageData = nil
            try? context.save()
            return newProfile
        }
    }

    // 언어별 링크 데이터 정의
    var profileLinks: [ProfileLinkData] {
        let lang = Locale.current.languageCode
        if lang == "ko" {
            return [
                ProfileLinkData(
                    image: "1",
                    title: "개발자 GO 이야기",
                    description: "세상에 필요한 앱을 만들고 싶어요.",
                    url: "https://gojaehyun.notion.site/GO-KR-202f6a5a5d2f8092b7a3e504761a145a"
                ),
                ProfileLinkData(
                    image: "2",
                    title: "Letgo의 비전",
                    description: "글쓰기의 즐거움을 되찾을 때까지!",
                    url: "https://gojaehyun.notion.site/LetGO-KR-202f6a5a5d2f80fa91e2d34afbf3d906"
                ),
                ProfileLinkData(
                    image: "3",
                    title: "끊임없이 고민하기",
                    description: "최고의 사용자 경험을 위해 노력중입니다.",
                    url: "https://gojaehyun.notion.site/UX-202f6a5a5d2f805ab344e3426e6c7597"
                )
            ]
        } else {
            return [
                ProfileLinkData(
                    image: "1",
                    title: "Developer GO Story",
                    description: "Building apps the world needs.",
                    url: "https://gojaehyun.notion.site/Go-EN-202f6a5a5d2f80b0b169e543958f5b7a"
                ),
                ProfileLinkData(
                    image: "2",
                    title: "Letgo's Vision",
                    description: "Discovering writing joy.",
                    url: "https://gojaehyun.notion.site/LetGo-EN-202f6a5a5d2f806db39effe84355c080"
                ),
                ProfileLinkData(
                    image: "3",
                    title: "Constantly Thinking",
                    description: "Improving user experience.",
                    url: "https://gojaehyun.notion.site/UX-1-202f6a5a5d2f80f5bf17cf09f18de6d8"
                )
            ]
        }
    }
}

// --- 프로필 링크 카드 뷰 ---
struct ProfileLinkCard: View {
    let image: Image
    let title: String
    let description: String
    let url: URL?
    var onTap: ((URL) -> Void)? = nil

    var body: some View {
        Button(action: {
            if let url = url {
                onTap?(url)
            }
        }) {
            HStack(alignment: .center, spacing: 16) {
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
}
