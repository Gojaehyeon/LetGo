import SwiftUI

struct TabBarItem: View {
    let icon: String
    let isSelected: Bool
    var isSessionView: Bool = false
    
    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 24))
            .foregroundColor(
                isSelected ? (isSessionView ? .white.opacity(0.8) : Color.black.opacity(0.85)) : .gray
            )
    }
}

#Preview {
    HStack {
        TabBarItem(icon: "line.3.horizontal.square", isSelected: true)
        TabBarItem(icon: "square.and.pencil", isSelected: false)
        TabBarItem(icon: "person.fill", isSelected: false)
    }
    .padding()
} 
