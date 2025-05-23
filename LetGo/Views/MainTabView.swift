import SwiftUI

struct MainTabView: View {
    @StateObject private var profileData = ProfileData()
    @State private var selectedTab: Int = 0 // 0: 홈, 1: 세션, 2: 프로필

    var body: some View {
        VStack(spacing: 0) {
            if selectedTab == 0 {
                HomeView(profileData: profileData)
            } else if selectedTab == 1 {
                SessionView(profileData: profileData)
            } else {
                ProfileView(profileData: profileData)
            }
            HStack(spacing: 60) {
                TabBarItem(icon: "house.fill", title: "홈", isSelected: selectedTab == 0)
                    .onTapGesture { selectedTab = 0 }
                TabBarItem(icon: "square.and.pencil", title: "세션", isSelected: selectedTab == 1)
                    .onTapGesture { selectedTab = 1 }
                TabBarItem(icon: "person.fill", title: "프로필", isSelected: selectedTab == 2)
                    .onTapGesture { selectedTab = 2 }
            }
            .frame(height: 100)
            .background(Color.white)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 
