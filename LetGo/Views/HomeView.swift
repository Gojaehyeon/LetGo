import SwiftUI

struct HomeView: View {
    @ObservedObject var profileData: ProfileData
    var body: some View {
        VStack(spacing: 0) {
            // 상단 (세션뷰와 동일하게)
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
            }
            .padding(.top)

            // 본문 (탭바 없이 모두 표시)
            ZStack {
                Color(.systemGray5).opacity(0.7).ignoresSafeArea()
                // 오늘의 한마디 + 작성한 글들 모두 표시 (디자인 예정)
            }
            .padding(.top, 12)
        }
    }
}

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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 
