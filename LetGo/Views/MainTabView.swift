import SwiftUI

struct MainTabView: View {
    @StateObject private var profileData = ProfileData()
    @State private var selectedTab: Int = 1 // 0: 홈, 1: 세션, 2: 한마디, 3: 프로필

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                if selectedTab == 0 {
                    HomeView(profileData: profileData)
                } else if selectedTab == 1 {
                    SessionView(profileData: profileData, selectedTab: $selectedTab)
                } else if selectedTab == 2 {
                    OneLineView()
                } else {
                    ProfileView(profileData: profileData)
                }
            }
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 85)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: -2)
                    .opacity(selectedTab == 1 ? 0 : 1)
                HStack(spacing: 60) {
                    TabBarItem(icon: "line.3.horizontal.circle.fill", isSelected: selectedTab == 0, isSessionView: false)
                        .offset(y: -18)
                        .onTapGesture { selectedTab = 0 }
                    TabBarItem(icon: "plus.app.fill", isSelected: selectedTab == 1, isSessionView: selectedTab == 1)
                        .offset(y: -18)
                        .onTapGesture { selectedTab = 1 }
                    TabBarItem(icon: "ellipsis.bubble.fill", isSelected: selectedTab == 2, isSessionView: false)
                        .offset(y: -18)
                        .onTapGesture { selectedTab = 2 }
                    TabBarItem(icon: "person.fill", isSelected: selectedTab == 3, isSessionView: false)
                        .offset(y: -18)
                        .onTapGesture { selectedTab = 3 }
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
