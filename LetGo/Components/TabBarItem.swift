import SwiftUI

struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: icon)
                .font(.system(size: 28))
        }
        .offset(y: -10)
        .foregroundColor(isSelected ? Color(.black) : .gray)
        .frame(minWidth: 40, minHeight: 40)
    }
}

#Preview {
    HStack {
        TabBarItem(icon: "line.3.horizontal.square", title: "홈", isSelected: true)
        TabBarItem(icon: "square.and.pencil", title: "세션", isSelected: false)
        TabBarItem(icon: "person.fill", title: "프로필", isSelected: false)
    }
    .padding()
} 
