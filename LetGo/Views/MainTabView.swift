import SwiftUI

struct MainTabView: View {
    @StateObject private var profileData = ProfileData()
    @State private var selectedTab: Int = 0 // 0: 홈, 1: 세션, 2: 프로필

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                if selectedTab == 0 {
                    HomeView(profileData: profileData)
                } else if selectedTab == 1 {
                    SessionView(profileData: profileData)
                } else {
                    ProfileView(profileData: profileData)
                }
            }
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 80)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: -2)
                HStack(spacing: 60) {
                    TabBarItem(icon: "line.3.horizontal.circle.fill", title: "홈", isSelected: selectedTab == 0)
                        .onTapGesture { selectedTab = 0 }
                    TabBarItem(icon: "plus.app.fill", title: "세션", isSelected: selectedTab == 1)
                        .onTapGesture { selectedTab = 1 }
                    TabBarItem(icon: "person.fill", title: "프로필", isSelected: selectedTab == 2)
                        .onTapGesture { selectedTab = 2 }
                }
                .frame(height: 80)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 
