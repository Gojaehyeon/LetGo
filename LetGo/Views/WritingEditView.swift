import SwiftUI

struct WritingEditView: View {
    var writing: Writing
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var content: String
    @State private var showCancelDialog = false
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isContentFocused: Bool
    @FocusState private var isTitleFocused: Bool
    var onSave: (() -> Void)? = nil

    init(writing: Writing, onSave: (() -> Void)? = nil) {
        self.writing = writing
        self._title = State(initialValue: writing.title)
        self._content = State(initialValue: writing.content)
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 0) {
            // 상단 저장 버튼
            ZStack {
                HStack {
                    Button(action: { 
                        if title == writing.title && content == writing.content {
                            isContentFocused = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onSave?()
                            }
                        } else {
                            showCancelDialog = true
                        }
                    }) {
                        Text("취소")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(Color(.darkGray))
                    }
                    .padding(.leading, 20)

                    Spacer()
                    Button(action: {
                        writing.title = title
                        writing.content = content
                        try? modelContext.save()
                        isContentFocused = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onSave?()
                            dismiss()
                        }
                    }) {
                        Text("등록")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    .padding(.trailing, 20)
                }
            }
            .padding(.vertical, 18)
            Divider()
            // 제목 입력란
            ZStack(alignment: .leading) {
                if title.isEmpty {
                    Text("제목")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 0)
                }
                TextField("", text: $title)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 24)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 16)
                    .focused($isTitleFocused)
                    .onSubmit {
                        isTitleFocused = false
                        isContentFocused = true
                    }
            }
            .padding(.top, 0)
            Divider()
                .padding(.horizontal, 16)
                .padding(.bottom, 0)
            // 본문 입력란 (SessionTimerView와 통일)
            ZStack(alignment: .topLeading) {
                if content.isEmpty {
                    Text("잘 써야 한다는 부담 없이 자유롭게 적어보세요!")
                        .foregroundColor(Color(.systemGray3))
                        .font(.system(size: 16))
                        .padding(.horizontal, 20)
                        .padding(.top, 22)
                }
                TextEditor(text: $content)
                    .font(.system(size: 16))
                    .lineSpacing(3)
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                    .background(Color.clear)
                    .focused($isContentFocused)
                    .scrollContentBackground(.hidden)
            }
            .frame(minHeight: 180, maxHeight: 260)
            .padding(.horizontal, 0)
            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
        .confirmationDialog("작성중인 글을 취소하시겠습니까? 수정사항은 저장되지 않습니다.", isPresented: $showCancelDialog, titleVisibility: .visible) {
            Button("작성취소", role: .destructive) { 
                isContentFocused = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onSave?()
                }
            }
            Button("취소", role: .cancel) {}
        }
        .onAppear {
            subscribeToKeyboardNotifications()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTitleFocused = true
            }
        }
        .onDisappear {
            unsubscribeFromKeyboardNotifications()
        }
    }
    
    // MARK: - Keyboard Handling
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { notif in
            if let frame = notif.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                let height = UIScreen.main.bounds.height - frame.origin.y
                keyboardHeight = max(0, height)
            }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            keyboardHeight = 0
        }
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

#Preview {
    let writing = Writing(title: "샘플 제목", content: "샘플 본문입니다.", date: Date(), type: .threeMin)
    WritingEditView(writing: writing)
} 
