import SwiftUI
import PhotosUI
import SwiftData

struct ProfileView: View {
    @ObservedObject var profileData: ProfileData
    @State private var showImagePicker = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var pendingImagePicker = false
    @Query(sort: [SortDescriptor(\Writing.date, order: .reverse)]) var writings: [Writing]
    @State private var showProfileOverlay = false

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color.white)
                .frame(height: 56)
            HStack {
                Text("나의 정보")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.leading, 20)
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray.opacity(0.3))
        HStack(alignment: .center, spacing: 33) {
            ZStack(alignment: .bottomTrailing) {
                if let data = profileData.imageData, let uiImage = UIImage(data: data) {
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
                Text(profileData.nickname.isEmpty ? "닉네임" : profileData.nickname)
                    .font(.system(size: 20, weight: .bold))
                    .padding(.bottom, 6)
                    .padding(.top, 8)
                HStack(spacing: 36) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(postCount)")
                            .font(.system(size: 15, weight: .bold))
                        Text("게시물")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .frame(minWidth: 36)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(oneLineCount)")
                            .font(.system(size: 15, weight: .bold))
                        Text("한마디")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .frame(minWidth: 36)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(charCountDisplay)
                            .font(.system(size: 15, weight: .bold))
                        Text("글자")
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
                Color.black.opacity(0.7).ignoresSafeArea()
                VStack(spacing: 32) {
                    ZStack(alignment: .bottomTrailing) {
                        if let data = profileData.imageData, let uiImage = UIImage(data: data) {
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
                    .onTapGesture {
                        showProfileOverlay = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            pendingImagePicker = true
                        }
                    }
                    VStack(spacing: 0) {
                        TextField("닉네임", text: $profileData.nickname)
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
            .onTapGesture {
                showProfileOverlay = false
            }
        }

        // --- 외부 링크 카드 리스트 ---
        VStack(alignment: .leading, spacing: 8) {
            ProfileLinkCard(
                image: Image("1"),
                title: "개발자 GO 이야기",
                description: "세상에 필요한 앱을 만들고 싶어요.",
                url: URL(string: "https://your-go-link.com")
            )
            ProfileLinkCard(
                image: Image("2"),
                title: "Letgo의 비전",
                description: "글쓰기의 즐거움을 되찾을 때까지!",
                url: URL(string: "https://your-learndry-link.com")
            )
            ProfileLinkCard(
                image: Image("3"),
                title: "끊임없이 고민하기",
                description: "최고의 사용자 경험을 위해 노력중입니다.",
                url: URL(string: "https://your-nfc-link.com")
            )
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
                                profileData.imageData = data
                            }
                        }
                    }
                }
            }

        // --- 앱 버전 및 개인정보처리방침 ---
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("App Version")
                    .font(.system(size: 14))
                Text("v0.0.1(beta)")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            Spacer()
            Button(action: {
                if let url = URL(string: "https://your-privacy-link.com") {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("개인정보처리방침")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
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
        if count >= 10_000 {
            let formatted = Double(count) / 10_000
            let str = String(format: "%.1f", formatted)
            if str.hasSuffix(".0") {
                return "\(Int(formatted))만"
            } else {
                return "\(str)만"
            }
        } else if count >= 1_000 {
            let formatted = Double(count) / 1_000
            let str = String(format: "%.1f", formatted)
            if str.hasSuffix(".0") {
                return "\(Int(formatted))천"
            } else {
                return "\(str)천"
            }
        } else {
            return "\(count)"
        }
    }
}

// --- 프로필 링크 카드 뷰 ---
struct ProfileLinkCard: View {
    let image: Image
    let title: String
    let description: String
    let url: URL?

    var body: some View {
        Button(action: {
            if let url = url {
                UIApplication.shared.open(url)
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
    ProfileView(profileData: ProfileData())
}
