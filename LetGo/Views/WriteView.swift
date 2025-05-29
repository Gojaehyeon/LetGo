import SwiftUI
import SwiftData
import Foundation

struct WriteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    @StateObject private var locationManager = LocationManager()
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var address: String = "위치 정보 없음"
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isContentFocused: Bool
    @State private var showCancelDialog = false
    var onSave: (() -> Void)? = nil
    @AppStorage("isLocationEnabled") var isLocationEnabled: Bool = true
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            // 상단 저장 버튼
            ZStack {
                HStack {
                    Button(action: {
                        if title.isEmpty && content.isEmpty {
                            isContentFocused = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onSave?()
                                dismiss()
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
                        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedTitle.isEmpty && !trimmedContent.isEmpty else { return }
                        let newWriting = Writing(context: context, title: trimmedTitle, content: trimmedContent, date: Date(), type: .free, address: isLocationEnabled ? address : nil)
                        try? context.save()
                        isContentFocused = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onSave?()
                            dismiss()
                        }
                    }) {
                        Text("등록")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor((!title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? .theme : .gray)
                    }
                    .padding(.trailing, 20)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
                        .padding(.bottom, -8)
                }
                TextField("", text: $title)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 24)
                    .padding(.bottom, 14)
                    .padding(.horizontal, 16)
                    .focused($isTitleFocused)
                    .onSubmit {
                        isTitleFocused = false
                        isContentFocused = true
                    }
                    .onChange(of: title) { newValue in
                        let koreanOnly = newValue.range(of: "^[가-힣]+$", options: .regularExpression) != nil
                        let maxLength = koreanOnly ? 15 : 25
                        if newValue.count > maxLength {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.warning)
                            title = String(newValue.prefix(maxLength))
                        }
                    }
            }
            .padding(.top, 0)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // 위치 표시 바 (주소)
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text(isLocationEnabled ? address : "위치정보 저장이 해제되어 있습니다.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .padding(.bottom, -8)
                    // 본문 입력란
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("잘 써야 한다는 부담 없이 자유롭게 적어보세요!")
                                .foregroundColor(Color(.systemGray3))
                                .font(.system(size: 16))
                                .padding(.horizontal, 20)
                                .padding(.top, 8)
                        }
                        TextEditor(text: $content)
                            .font(.system(size: 16))
                            .lineSpacing(3)
                            .padding(.horizontal, 14)
                            .background(Color.clear)
                            .focused($isContentFocused)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 180, maxHeight: keyboardHeight > 0 ? 320 : .infinity, alignment: .top)
                    }
                    .padding(.horizontal, 0)
                }
                .padding(.bottom, keyboardHeight > 0 ? max(keyboardHeight - 80, 0) : 0)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
        .confirmationDialog("작성중인 글을 취소하시겠습니까? 수정사항은 저장되지 않습니다.", isPresented: $showCancelDialog, titleVisibility: .visible) {
            Button("작성취소", role: .destructive) {
                isContentFocused = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onSave?()
                    dismiss()
                }
            }
            Button("취소", role: .cancel) {}
        }
        .onAppear {
            address = locationManager.currentAddress
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTitleFocused = true
            }
        }
        .onReceive(locationManager.$currentAddress) { newAddress in
            address = newAddress
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                keyboardHeight = keyboardFrame.height
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    return WriteView()
        .environment(\.managedObjectContext, context)
} 
