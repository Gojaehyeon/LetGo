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
                                .padding(.leading, 8)
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
    @Published var currentAddress: String = NSLocalizedString("location_none", comment: "")
    private var fixedAddress: String? = nil
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
            guard let self = self else { return }
            if let placemark = placemarks?.first, error == nil {
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
                let address = addressComponents.prefix(2).joined(separator: " ")
                if self.fixedAddress == nil && !address.isEmpty {
                    self.fixedAddress = address
                }
                self.currentAddress = self.fixedAddress ?? NSLocalizedString("location_none", comment: "")
            } else {
                // 위치가 없어져도 기존 fixedAddress 유지
                self.currentAddress = self.fixedAddress ?? NSLocalizedString("location_none", comment: "")
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
            subtitle: NSLocalizedString("session_3min_sub", comment: ""),
            title: NSLocalizedString("session_3min", comment: ""),
            timeDesc: NSLocalizedString("session_3min_time", comment: ""),
            guide: NSLocalizedString("session_3min_guide", comment: ""),
            backgroundImage: "bg_3min"
        ),
        SessionInfo(
            imageName: "5min",
            subtitle: NSLocalizedString("session_5min_sub", comment: ""),
            title: NSLocalizedString("session_5min", comment: ""),
            timeDesc: NSLocalizedString("session_5min_time", comment: ""),
            guide: NSLocalizedString("session_5min_guide", comment: ""),
            backgroundImage: "bg_5min"
        ),
        SessionInfo(
            imageName: "7min",
            subtitle: NSLocalizedString("session_7min_sub", comment: ""),
            title: NSLocalizedString("session_7min", comment: ""),
            timeDesc: NSLocalizedString("session_7min_time", comment: ""),
            guide: NSLocalizedString("session_7min_guide", comment: ""),
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
            let isPadOrMac: Bool = {
                #if targetEnvironment(macCatalyst)
                return true
                #else
                return UIDevice.current.userInterfaceIdiom == .pad
                #endif
            }()
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
                        Text((userProfile?.nickname?.isEmpty == false ? userProfile?.nickname : "Letgo") ?? "Letgo")
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
                    .frame(height: {
                        #if os(iOS)
                        let isPad = UIDevice.current.userInterfaceIdiom == .pad
                        let isLandscape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
                        
                        if isPad && isLandscape {
                            let width = UIScreen.main.bounds.width
                            if width >= 1366 { // 12.9인치 iPad Pro
                                return 170
                            } else if width >= 1194 { // 11인치 iPad (Air, Pro)
                                return 142
                            } else { // iPad mini
                                return 52
                            }
                        } else {
                            return 170 // 세로모드 또는 iPhone
                        }
                        #else
                        return 170 // Mac
                        #endif
                    }())
                    .padding(.top, 10)
                    .onChange(of: selectedSession) { oldValue, newValue in
                        previousSession = oldValue
                        isFading = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isFading = false
                            previousSession = newValue
                        }
                    }

                if isPadOrMac {
                    Spacer()
                }

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
                    Text(NSLocalizedString("start", comment: ""))
                        .font(.system(size: 27, weight: .bold))
                        .foregroundColor(
                            isDarkColor ? .white : .black
                        )
                        .frame(width: isPadOrMac ? 180 : 150, height: isPadOrMac ? 180 : 150)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            themeColor.opacity(1.0),
                                            themeColor.opacity(0.9),
                                            themeColor.opacity(0.8)
                                        ]),
                                        startPoint: .bottomLeading,
                                        endPoint: .topTrailing
                                    )
                                )
                                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 0)
                        )
                }
                .padding(.top, 190)

                // 세션 설정 버튼
                Button(action: { showSessionSettingSheet = true }) {
                    Text(NSLocalizedString("write_setting", comment: ""))
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Color.white))
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 0)
                }
                .padding(.top, isPadOrMac ? 50 : 28)
                .sheet(isPresented: $showSessionSettingSheet) {
                    ModeSettingView()
                        .presentationDetents([.medium, .large])
                }
                // 조건부 바텀 패딩
                .padding(.bottom, isPadOrMac ? 130 : 0)

                if !isPadOrMac {
                    Spacer()
                }
            }
        }
        .fullScreenCover(isPresented: $showModeSetting) {
            SessionTimerView(duration: (selectedSession == 0 ? 180 : selectedSession == 1 ? 300 : 420))
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
