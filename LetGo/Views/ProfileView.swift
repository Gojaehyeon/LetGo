import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 0) {
            // 상단 프로필 헤더
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 60, height: 60)
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading) {
                    Text("고재현")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("스케치북 프로필")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
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
                    Text("프로필 화면 컨텐츠 영역")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Spacer()
                }
            }

            // 하단 탭바 (SessionView와 동일)
            HStack(spacing: 60) {
                TabBarItem(icon: "house.fill", title: "홈", isSelected: false)
                TabBarItem(icon: "square.and.pencil", title: "세션", isSelected: false)
                TabBarItem(icon: "person.fill", title: "프로필", isSelected: true)
            }
            .frame(height: 100)
            .background(Color.white)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    ProfileView()
} 