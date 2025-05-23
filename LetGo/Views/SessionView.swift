import AVKit
import SwiftUI

struct LoopingVideoPlayer: UIViewRepresentable {
    let videoName: String

    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(videoName: videoName)
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    class PlayerUIView: UIView {
        private var playerLooper: AVPlayerLooper?
        private var queuePlayer: AVQueuePlayer?
        private var playerLayer: AVPlayerLayer?

        init(videoName: String) {
            super.init(frame: .zero)

            guard let path = Bundle.main.path(forResource: videoName, ofType: "mp4") else {
                return
            }

            let url = URL(fileURLWithPath: path)
            let playerItem = AVPlayerItem(url: url)
            let queuePlayer = AVQueuePlayer(playerItem: playerItem)
            self.queuePlayer = queuePlayer
            playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)

            let playerLayer = AVPlayerLayer(player: queuePlayer)
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.frame = bounds
            layer.addSublayer(playerLayer)
            self.playerLayer = playerLayer

            queuePlayer.play()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            playerLayer?.frame = bounds
        }
    }
}

struct SessionInfo {
    let imageName: String
    let subtitle: String
    let title: String
    let timeDesc: String
    let guide: String
    let backgroundImage: String
}

struct SessionCarouselView: View {
    let sessions: [SessionInfo]
    @Binding var selectedSession: Int
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedSession) {
                ForEach(0..<sessions.count, id: \.self) { idx in
                    let session = sessions[idx]
                    HStack {
                        Image(session.imageName)
                            .resizable()
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.trailing, 12)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(session.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(session.title)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Text(session.timeDesc)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(height: 100)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 1)
                    .frame(width: UIScreen.main.bounds.width - 40)
                    .tag(idx)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 170)
            .padding(.bottom, 12)

            // 인디케이터 (세션 개수만큼)
            HStack(spacing: 6) {
                ForEach(0..<sessions.count, id: \.self) { idx in
                    Capsule()
                        .fill(selectedSession == idx ? Color.orange : Color.white)
                        .frame(width: selectedSession == idx ? 20 : 12, height: 6)
                        .animation(.easeInOut(duration: 0.18), value: selectedSession)
                }
            }
            .padding(.bottom, 1)
        }
    }
}

struct SessionView: View {
    @ObservedObject var profileData: ProfileData
    @Namespace private var tabAnimation
    @State private var selectedTab: Int = 0 // 0: 글쓰기 세션, 1: 오늘의 한마디
    @State private var selectedSession: Int = 0 // 캐러셀 인덱스
    @State private var bgImageId: Int = 0 // 배경 이미지 페이드용
    @State private var showModeSetting = false

    let profileImage: Image? = nil

    let sessions: [SessionInfo] = [
        SessionInfo(
            imageName: "3min",
            subtitle: "일상의 작은 틈에서 글 써보기",
            title: "3 min Challenge",
            timeDesc: "3분 세션",
            guide: "떠오르는 생각이나 감정을 빠르게 적어보아요.",
            backgroundImage: "bg_3min"
        ),
        SessionInfo(
            imageName: "5min",
            subtitle: "5분은 생각보다 길다",
            title: "Mini 5min Challenge",
            timeDesc: "5분 세션",
            guide: "5분 동안 더 깊은 생각을 자유롭게 적어보세요.",
            backgroundImage: "bg_5min"
        ),
        SessionInfo(
            imageName: "7min",
            subtitle: "7분은 몰입의 시작",
            title: "Deep 7min Challenge",
            timeDesc: "7분 세션",
            guide: "7분 동안 몰입해서 나만의 이야기를 써보세요.",
            backgroundImage: "bg_7min"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // 상단 프로필 & 탭
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    if let data = profileData.imageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray4))
                                .frame(width: 44, height: 44)
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                        }
                    }
                    Text(profileData.nickname)
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 0)
                .background(Color.white)

                // 탭바
                HStack(spacing: 0) {
                    ForEach(0..<2) { idx in
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                selectedTab = idx
                            }
                        }) {
                            VStack(spacing: 12) {
                                ZStack {
                                    // 선택된 스타일
                                    Text(idx == 0 ? "글쓰기 세션" : "오늘의 한마디")
                                        .font(.system(size: 18, weight: .bold))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .opacity(selectedTab == idx ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.18), value: selectedTab)
                                    // 비선택 스타일
                                    Text(idx == 0 ? "글쓰기 세션" : "오늘의 한마디")
                                        .font(.system(size: 18, weight: .regular))
                                        .fontWeight(.regular)
                                        .foregroundColor(.gray)
                                        .opacity(selectedTab == idx ? 0 : 1)
                                        .animation(.easeInOut(duration: 0.18), value: selectedTab)
                                }
                                // 밑줄 인디케이터
                                ZStack {
                                    if selectedTab == idx {
                                        Rectangle()
                                            .frame(height: 3)
                                            .foregroundColor(.black)
                                            .matchedGeometryEffect(id: "tabIndicator", in: tabAnimation)
                                    } else {
                                        Color.clear.frame(height: 3)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 20)
                .background(Color.white)
            }
            .padding(.top)

            // 본문
            SessionMainView(
                sessions: sessions,
                selectedTab: selectedTab,
                selectedSession: $selectedSession,
                showModeSetting: $showModeSetting
            )
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    SessionView(
        profileData: ProfileData()
    )
}

class ProfileData: ObservableObject {
    @Published var nickname: String {
        didSet { UserDefaults.standard.set(nickname, forKey: "nickname") }
    }
    @Published var imageData: Data? {
        didSet { UserDefaults.standard.set(imageData, forKey: "profileImage") }
    }

    init() {
        self.nickname = UserDefaults.standard.string(forKey: "nickname") ?? "Letgo"
        self.imageData = UserDefaults.standard.data(forKey: "profileImage")
    }
}

struct SessionMainView: View {
    let sessions: [SessionInfo]
    let selectedTab: Int
    @Binding var selectedSession: Int
    @Binding var showModeSetting: Bool

    var body: some View {
        ZStack {
            ZStack {
                ForEach(0..<sessions.count, id: \.self) { idx in
                    if selectedTab == 0 && selectedSession == idx {
                        LoopingVideoPlayer(videoName: sessions[idx].backgroundImage)
                            .ignoresSafeArea()
                            .transition(.opacity)
                            .id(idx)
                    }
                }
                Color.black.opacity(0.5)
            }
            .animation(.easeInOut(duration: 0.4), value: selectedSession)
            .ignoresSafeArea()

            if selectedTab == 0 {
                ScrollView {
                    SessionContentView(
                        sessions: sessions,
                        selectedSession: $selectedSession,
                        showModeSetting: $showModeSetting
                    )
                }
            } else {
                OneLineView()
            }
        }
    }
}
