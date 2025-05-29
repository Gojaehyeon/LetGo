import MapKit
import SwiftUI
import CoreData

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
        GeometryReader { geometry in
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
                        .frame(width: geometry.size.width - 40)
                        .tag(idx)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 170)
                .padding(.bottom, 4)

                // 인디케이터 (세션 개수만큼)
                HStack(spacing: 6) {
                    ForEach(0..<sessions.count, id: \.self) { idx in
                        Capsule()
                            .fill(selectedSession == idx ? Color.theme : Color.secondary)
                            .frame(width: selectedSession == idx ? 18 : 10, height: 4)
                            .animation(.easeInOut(duration: 0.18), value: selectedSession)
                    }
                }
                .padding(.bottom, 1)
            }
        }
    }
}

// 현재 위치 지도 뷰
struct SessionMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
    )
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true)
            .mapStyle(.standard(elevation: .realistic, emphasis: .muted))
            .onAppear {
                if let location = locationManager.lastLocation {
                    region.center = location.coordinate
                }
            }
            .onReceive(locationManager.$lastLocation) { location in
                if let location = location {
                    region.center = location.coordinate
                }
            }
            .ignoresSafeArea()
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var lastLocation: CLLocation?
    @Published var currentAddress: String = "위치 정보 없음"
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
        if let location = locations.last {
            updateAddress(for: location)
        }
    }

    private func updateAddress(for location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self,
                  let placemark = placemarks?.first,
                  error == nil else {
                self?.currentAddress = "위치 정보 없음"
                return
            }

            // 주소 구성요소 추출
            var addressComponents: [String] = []
            
            if let locality = placemark.locality {
                addressComponents.append(locality)
            }
            if let subLocality = placemark.subLocality {
                addressComponents.append(subLocality)
            }
            if let thoroughfare = placemark.thoroughfare {
                addressComponents.append(thoroughfare)
            }

            // 주소가 비어있으면 "위치 정보 없음" 표시
            if addressComponents.isEmpty {
                self.currentAddress = "위치 정보 없음"
            } else {
                // 최대 2개의 주소 구성요소만 사용
                let address = addressComponents.prefix(2).joined(separator: " ")
                self.currentAddress = address
            }
        }
    }
}

struct SessionView: View {
    @FetchRequest(
        entity: UserProfile.entity(),
        sortDescriptors: [],
        animation: .default
    ) var profiles: FetchedResults<UserProfile>
    @Environment(\.managedObjectContext) private var context
    @Namespace private var tabAnimation
    @State private var selectedSession: Int = 0
    @State private var previousSession: Int = 0
    @State private var bgImageId: Int = 0
    @State private var showModeSetting = false
    @Binding var selectedTab: Int
    @State private var isFading: Bool = false
    @Binding var isTabBarHidden: Bool
    @State private var showSessionSettingSheet = false
    @State private var isLocationEnabled: Bool = true
    @AppStorage("themeColorHex") var themeColorHex: String = "#FF9500"

    var userProfile: UserProfile? {
        profiles.first
    }

    let sessions: [SessionInfo] = [
        SessionInfo(
            imageName: "3min",
            subtitle: "일상의 작은 틈 속에서",
            title: "3min Challenge",
            timeDesc: "3분 세션",
            guide: "떠오르는 생각들을 빠르게 적어보아요.",
            backgroundImage: "bg_3min"
        ),
        SessionInfo(
            imageName: "5min",
            subtitle: "5분은 생각보다 길다",
            title: "5min Challenge",
            timeDesc: "5분 세션",
            guide: "더 깊은 생각속에 더 깊이 빠져보세요.",
            backgroundImage: "bg_5min"
        ),
        SessionInfo(
            imageName: "7min",
            subtitle: "진정한 몰입의 7분",
            title: "7min Challenge",
            timeDesc: "7분 세션",
            guide: "몰입해서 나만의 이야기를 써보세요.",
            backgroundImage: "bg_7min"
        )
    ]

    var body: some View {
        ZStack {
            SessionMapView()
                .offset(y: {
                    #if targetEnvironment(macCatalyst)
                    0
                    #else
                    UIDevice.current.userInterfaceIdiom == .pad ? 0 : 20
                    #endif
                }())
            // 지도 중앙에 프로필 오버레이 (흰 원 + 진한 하얀 테두리)
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 55, height: 55)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 0)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
                if let data = userProfile?.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 43, height: 43)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.gray)
                }
            }
            .offset(y: -45)
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.white.opacity(0.2), location: 0.3),
                    .init(color: Color.white.opacity(0.3), location: 0.4),
                    .init(color: Color.white.opacity(0.6), location: 0.6),
                    .init(color: Color.white.opacity(1.0), location: 1.0)
                ]),
                center: .center,
                startRadius: 0,
                endRadius: UIScreen.main.bounds.width * 0.7
            )
            .ignoresSafeArea()
            VStack(spacing: 0) {
                // 상단 프로필 전체를 Button으로 감싸기
                Button(action: {
                    selectedTab = 3
                }) {
                    HStack(spacing: 12) {
                        if let data = userProfile?.imageData, let uiImage = UIImage(data: data) {
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
                        Text(userProfile?.nickname ?? "Letgo")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 12)
                }

                // 세션 캐러셀
                SessionCarouselView(sessions: sessions, selectedSession: $selectedSession)
                    .frame(height: 170)
                    .padding(.top, 10)
                    .onChange(of: selectedSession) { oldValue, newValue in
                        previousSession = oldValue
                        isFading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isFading = false
                            previousSession = newValue
                        }
                    }

                // 가이드 메시지
//                Text(sessions[selectedSession].guide)
//                    .font(.system(size: 18, weight: .semibold))
//                    .foregroundColor(.black)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 40)
//                    .padding(.top, 30)

                // 시작하기 버튼
                let themeColor = Color(hex: themeColorHex)
                let isDarkColor: Bool = {
                    let uiColor = UIColor(themeColor)
                    var red: CGFloat = 0
                    var green: CGFloat = 0
                    var blue: CGFloat = 0
                    uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
                    // 밝기 계산 (RGB 평균)
                    let brightness = (red + green + blue) / 3.0
                    return brightness < 0.8  // 0.6보다 어두우면 흰색 텍스트
                }()

                Button(action: {
                    showModeSetting = true
                }) {
                    Text("시작하기")
                        .font(.system(size: 27, weight: .bold))
                        .foregroundColor(
                            isDarkColor ? .white : .black
                        )
                        .frame(width: 150, height: 150)
                        .background(
                            Circle()
                                .fill(Color.theme)
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 0)
                        )
                }
                .padding(.top, 190)

                // 세션 설정 버튼
                Button(action: { showSessionSettingSheet = true }) {
                    Text("글쓰기 설정")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.white))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 0)
                }
                .padding(.top, 28)
                .sheet(isPresented: $showSessionSettingSheet) {
                    ModeSettingView()
                        .presentationDetents([.medium, .large])
                }

                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showModeSetting) {
            SessionTimerView(duration: (selectedSession == 0 ? 180 : selectedSession == 1 ? 300 : 420), isLocationEnabled: isLocationEnabled)
                .onAppear { isTabBarHidden = true }
                .onDisappear { isTabBarHidden = false }
        }
    }
}

#Preview {
    SessionView(
        selectedTab: .constant(0),
        isTabBarHidden: .constant(false)
    )
}
