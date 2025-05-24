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
                            .frame(width: 85, height: 85)
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
                        .frame(height: 110)
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
    @State private var selectedSession: Int = 0
    @State private var previousSession: Int = 0
    @State private var bgImageId: Int = 0
    @State private var showModeSetting = false
    @Binding var selectedTab: Int
    @State private var isFading: Bool = false

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
        ZStack {
            ForEach(0..<sessions.count, id: \.self) { idx in
                LoopingVideoPlayer(videoName: sessions[idx].backgroundImage)
                    .ignoresSafeArea()
                    .opacity(selectedSession == idx ? 1 : 0)
                    .animation(.easeInOut(duration: 0.5), value: selectedSession)
            }
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 상단 프로필 전체를 Button으로 감싸기
                Button(action: {
                    selectedTab = 3
                }) {
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
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 12)
                }

                // 세션 캐러셀
                SessionCarouselView(sessions: sessions, selectedSession: $selectedSession)
                    .padding(.top, 20)
                    .onChange(of: selectedSession) { oldValue, newValue in
                        previousSession = oldValue
                        isFading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isFading = false
                            previousSession = newValue
                        }
                    }

                // 가이드 메시지
                Text(sessions[selectedSession].guide)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 40)

                // 시작하기 버튼
                Button(action: {
                    showModeSetting = true
                }) {
                    Text("시작하기")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 180, height: 180)
                        .background(
                            Circle()
                                .fill(Color.orange)
                                .opacity(0.85)
                        )
                }
                .padding(.top, 80)
                .padding(.bottom, 40)
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showModeSetting) {
            SessionTimerView(duration: (selectedSession == 0 ? 180 : selectedSession == 1 ? 300 : 420))
        }
    }
}

#Preview {
    SessionView(
        profileData: ProfileData(),
        selectedTab: .constant(0)
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
