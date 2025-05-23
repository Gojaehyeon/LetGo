import SwiftUI

struct WritingCard: View {
    let writing: Writing
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: writing.writingType.icon)
                    .foregroundColor(.blue)
                Text(writing.title)
                    .font(.headline)
                Spacer()
                Text(writing.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(writing.content)
                .font(.body)
                .lineLimit(3)
            
            Text(writing.writingType.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    WritingCard(writing: Writing(
        title: "샘플 제목",
        content: "이것은 샘플 내용입니다. 글쓰기 앱의 카드 뷰를 보여주기 위한 예시입니다.",
        date: Date(),
        type: .daily
    ))
    .padding()
} 