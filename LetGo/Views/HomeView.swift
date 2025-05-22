import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            // 상단 (예시)
            HStack(spacing: 12) {
                Image(systemName: "house.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.gray)
                Text("LetGo 홈")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.top, 32)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .background(Color.white)

            // 본문 (임시)
            ZStack {
                Color(white: 0.6).opacity(0.7).ignoresSafeArea()
                VStack {
                    Spacer()
                    Text("홈 화면 컨텐츠 영역")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }
    }
}

struct MainTabView: View {
    @StateObject private var profileData = ProfileData()
    @State private var selectedTab: Int = 0 // 0: 홈, 1: 세션, 2: 프로필

    var body: some View {
        VStack(spacing: 0) {
            if selectedTab == 0 {
                HomeView()
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 
