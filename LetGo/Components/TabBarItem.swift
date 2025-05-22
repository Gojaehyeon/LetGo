import SwiftUI

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 30))
            Text(title)
                .font(.caption)
        }
        .offset(y: -10)
        .foregroundColor(isSelected ? Color(.darkGray) : .gray)
        .frame(minWidth: 60)
    }
}

#Preview {
    HStack {
        TabBarItem(icon: "house.fill", title: "홈", isSelected: true)
        TabBarItem(icon: "square.and.pencil", title: "세션", isSelected: false)
        TabBarItem(icon: "person.fill", title: "프로필", isSelected: false)
    }
    .padding()
} 
