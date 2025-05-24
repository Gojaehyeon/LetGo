import SwiftUI
import UIKit

struct WritingCard: View {
    let writing: Writing
    var onDelete: ((Writing) -> Void)? = nil
    
    var firstSentence: String {
        let trimmed = writing.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count <= 10 {
            return trimmed
        } else {
            let idx = trimmed.index(trimmed.startIndex, offsetBy: 10)
            return String(trimmed[..<idx]) + ".."
        }
    }
    
    @State private var showActionSheet = false
    @Environment(\.modelContext) private var modelContext
    @State private var showShareSheet = false
    @State private var isLiked: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                //                Image(systemName: writing.writingType.icon)
                //                    .foregroundColor(.blue)
                Text(firstSentence)
                    .font(.system(size: 18, weight: .bold))
                Text(writing.writingType.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        (writing.writingType == .oneLine ? Color.orange : Color.blue).opacity(0.1)
                    )
                    .cornerRadius(4)
                Spacer()
                Button(action: {
                    showActionSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
                .confirmationDialog("", isPresented: $showActionSheet, titleVisibility: .hidden) {
                    Button("삭제", role: .destructive) {
                        onDelete?(writing)
                    }
                    Button("편집") {
                        // 편집 기능은 추후 구현
                    }
                    Button("취소", role: .cancel) {}
                }
            }
            HStack {
                Text(writing.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            Text(writing.content)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
                .opacity(0.65)
                .lineLimit(3)

            HStack {
                Button(action: {
                    isLiked.toggle()
                    writing.isLiked = isLiked
                    try? modelContext.save()
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(.orange)
                        .font(.system(size: 23))
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
                Button(action: {
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.gray)
                        .font(.system(size: 21))
                }
                .buttonStyle(PlainButtonStyle())
                .sheet(isPresented: $showShareSheet) {
                    ActivityView(activityItems: [writing.content])
                }
            }
            .padding(.top, 6)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray.opacity(0.18))
                .padding(.top, 2)
            
        }
        .background(Color(.systemBackground))
        .padding(.horizontal, 4)
//        .cornerRadius(15)
//        .shadow(color: Color.gray.opacity(0.5), radius: 5, x: 0, y: 0)
        .onAppear {
            isLiked = writing.isLiked
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
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
