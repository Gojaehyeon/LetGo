import SwiftUI

struct WritingCard: View {
    let writing: Writing
    
    var firstSentence: String {
        let trimmed = writing.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if let range = trimmed.range(of: ".") {
            return String(trimmed[..<range.upperBound])
        } else {
            return trimmed
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
//                Image(systemName: writing.writingType.icon)
//                    .foregroundColor(.blue)
                Text(firstSentence)
                    .font(.headline)
                Text(writing.writingType.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        (writing.writingType == .oneLine ? Color.orange : Color.blue).opacity(0.1)
                    )
                    .cornerRadius(4)
                Spacer()
            }
            
            Text(writing.content)
                .font(.body)
                .lineLimit(3)
            Text(writing.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.gray)

        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 0)    }
}

#Preview {
    WritingCard(writing: Writing(
        title: "샘플 제목",
        content: "이것은 샘플 내용입니다. 글쓰기 앱의 카드 뷰를 보여주기 위한 예시입니다.",
        date: Date(),
        type: .oneLine
    ))
    .padding()
} 
