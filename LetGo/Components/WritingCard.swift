import SwiftUI
import UIKit

struct WritingCard: View {
    let writing: Writing
    var onDelete: ((Writing) -> Void)? = nil
    var onEdit: (() -> Void)? = nil
    var showEllipsis: Bool = true
    
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
    @Environment(\.managedObjectContext) private var context
    @State private var showShareSheet = false
    @State private var isLiked: Bool = false

    // 공유 텍스트 미리 계산
    var shareText: String {
        if !writing.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "#" + writing.title + "\n" + writing.content
        } else {
            return writing.content
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(writing.title)
                    .font(.system(size: 18, weight: .bold))
                Text(writing.writingType.localized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        (writing.writingType == .oneLine ? Color.theme :
                         writing.writingType == .free ? Color.blue :
                         Color.theme).opacity(0.1)
                    )
                    .cornerRadius(4)
                Spacer()
                if showEllipsis {
                    Button(action: {
                        showActionSheet = true
                    }) {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                            .font(.system(size: 19, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(width: 24, height: 24)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .confirmationDialog("", isPresented: $showActionSheet, titleVisibility: .hidden) {
                        Button(NSLocalizedString("delete", comment: ""), role: .destructive) {
                            onDelete?(writing)
                        }
                        Button(NSLocalizedString("edit", comment: "")) {
                            onEdit?()
                        }
                        Button(NSLocalizedString("cancel", comment: ""), role: .cancel) {}
                    }
                }
            }
            HStack {
                Text((writing.value(forKey: "date") as? Date)?.formatted(date: .abbreviated, time: .shortened) ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
            }
            Text(writing.content)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
                .opacity(0.65)
                .lineLimit(3)

            if showEllipsis {
                HStack {
                    Button(action: {
                        isLiked.toggle()
                        writing.isLiked = isLiked
                        try? context.save()
                    }) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(.theme)
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
                        ActivityView(activityItems: [shareText])
                            .presentationDetents([.medium, .large])
                    }
                }
                .padding(.top, 6)
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.18))
                    .padding(.top, 2)
            }
        }
        .background(Color(.systemBackground))
        .contentShape(Rectangle())
        .padding(.horizontal, 4)
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
    let context = PersistenceController.shared.container.viewContext
    let writing = Writing(context: context, title: "샘플 제목", content: "이것은 샘플 내용입니다. 글쓰기 앱의 카드 뷰를 보여주기 위한 예시입니다.", date: Date(), type: .oneLine)
    return WritingCard(writing: writing, showEllipsis: false)
        .environment(\.managedObjectContext, context)
        .padding()
} 
 