import SwiftUI

struct WritingDetailView: View {
    let writing: Writing
    var onClose: (Bool) -> Void
    @Environment(\.managedObjectContext) private var context
    @State private var showShareSheet = false
    @State private var showActionSheet = false
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedEditingWriting: Writing?
    @State private var offset: CGFloat = 0
    @State private var isLiked: Bool = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 0) {
                // 커스텀 Back 버튼
                HStack {
                    Button(action: { 
                        withAnimation(.easeInOut(duration: 0.1)) {
                            offset = UIScreen.main.bounds.width
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onClose(false)
                        }
                    }) {
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
                                    (writing.writingType == .oneLine ? Color.theme : Color.blue).opacity(0.2)
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
                        // 장소 정보
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Text(writing.address ?? "위치 정보 없음")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 0)
                        Text((writing.value(forKey: "date") as? Date)?.formatted(date: .long, time: .shortened) ?? "")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                        Divider()
                            .padding(.vertical, 14)
                        Text(writing.content)
                            .font(.system(size: 15))
                            .lineSpacing(3)
                            .foregroundColor(.black.opacity(0.8))
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
                                isLiked.toggle()
                                writing.isLiked = isLiked
                                try? context.save()
                            }) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(.theme)
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
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if value.translation.width > 0 {
                            offset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        if value.translation.width > 100 {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                offset = UIScreen.main.bounds.width
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onClose(false)
                            }
                        } else {
                            withAnimation {
                                offset = 0
                            }
                        }
                    }
            )
        }
        .confirmationDialog("", isPresented: $showActionSheet, titleVisibility: .hidden) {
            Button("삭제", role: .destructive) {
                context.delete(writing)
                try? context.save()
                onClose(false)
            }
            Button("편집") {
                onClose(true)
                selectedEditingWriting = writing
            }
            Button("취소", role: .cancel) {}
        }
        .onAppear {
            isLiked = writing.isLiked
        }
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    WritingDetailView(writing: Writing(
        context: context,
        title: "이것은 제목입니다",
        content: "이것은 본문입니다. 3분 세션동안 글을 썼습니다. 안녕하세요. 한 세줄정도까지는 여기서 보이도록 하되 그 이상을 넘어가서 몇 글자 이상 넘어가면 어떻게 할까 생각 그건 점으로 처리합니다. 하지만 여긴 상세보기니까 자세히 볼 수 있죠.",
        date: Date(),
        type: .threeMin
    ), onClose: { _ in }, selectedEditingWriting: .constant(nil))
}
