import SwiftUI

struct WritingDetailView: View {
    let writing: Writing
    var onClose: () -> Void
    @Environment(\.modelContext) private var modelContext
    @State private var showShareSheet = false
    @State private var showActionSheet = false
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedEditingWriting: Writing?

    var body: some View {
        VStack(spacing: 0) {
            // 커스텀 Back 버튼
            HStack {
                Button(action: onClose) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24))
                        .foregroundColor(Color(.darkGray))
                        .padding(.leading, 10)
                }
                Spacer()
            }
            .padding(.top, 16)
            .padding(.leading, 8)
            .padding(.bottom, 16)
            Divider()
            // 기존 상세 내용
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(writing.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(writing.writingType.rawValue)
                            .font(.caption)
                            .foregroundColor(.black.opacity(0.7))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                (writing.writingType == .oneLine ? Color.orange : Color.blue).opacity(0.1)
                            )
                            .cornerRadius(6)
                            .padding(.top, 4)
                        Spacer()
                        Button(action: { showActionSheet = true }) {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90))
                                .foregroundColor(.gray)
                                .font(.system(size: 19, weight: .medium))
                                .padding(.top, 12)
                        }
                    }
                    Text(writing.date.formatted(date: .long, time: .shortened))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    Divider()
                        .padding(.vertical, 14)
                    Text(writing.content)
                        .font(.system(size: 16))
                        .lineSpacing(3)
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 0)
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 40)
            }
            .background(Color.white.ignoresSafeArea())
            .overlay(
                VStack(spacing: 0) {
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray.opacity(0.18))
                        .shadow(color: Color.black.opacity(0.08), radius: 8, y: -2)
                        .padding(.bottom, 0)
                    HStack {
                        Button(action: {
                            writing.isLiked.toggle()
                            try? modelContext.save()
                        }) {
                            Image(systemName: writing.isLiked ? "heart.fill" : "heart")
                                .foregroundColor(.orange)
                                .font(.system(size: 28))
                        }
                        Spacer()
                        Button(action: {
                            showShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.gray)
                                .font(.system(size: 26))
                        }
                        .sheet(isPresented: $showShareSheet) {
                            ActivityView(activityItems: [writing.content])
                                .presentationDetents([.medium, .large])
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                    .padding(.top, 8)
                }
                , alignment: .bottom
            )
        }
        .background(Color.white.ignoresSafeArea())
        .confirmationDialog("", isPresented: $showActionSheet, titleVisibility: .hidden) {
            Button("삭제", role: .destructive) {
                modelContext.delete(writing)
                onClose()
            }
            Button("편집") {
                onClose()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    selectedEditingWriting = writing
                }
            }
            Button("취소", role: .cancel) {}
        }
    }
}

#Preview {
    WritingDetailView(writing: Writing(
        title: "이것은 제목입니다",
        content: "이것은 본문입니다. 3분 세션동안 글을 썼습니다. 안녕하세요. 한 세줄정도까지는 여기서 보이도록 하되 그 이상을 넘어가서 몇 글자 이상 넘어가면 어떻게 할까 생각 그건 점으로 처리합니다. 하지만 여긴 상세보기니까 자세히 볼 수 있죠.",
        date: Date(),
        type: .threeMin
    ), onClose: {}, selectedEditingWriting: .constant(nil))
}
