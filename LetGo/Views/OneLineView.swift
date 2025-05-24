import SwiftUI
import SwiftData

struct OneLineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Writing.date, order: .forward)]) var allWritings: [Writing]
    @State private var oneLineText = ""
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    
    var oneLines: [Writing] {
        allWritings.filter { $0.type == WritingType.oneLine.rawValue }
    }
    var sentToday: Bool {
        oneLines.contains { Calendar.current.isDateInToday($0.date) }
    }
    
    var body: some View {
        // 상단 전체보기 영역
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 56)
                HStack {
                    Text("오늘의 한마디")
                        .font(.system(size: 22, weight: .bold))
                        .padding(.leading, 20)
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
            }
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray.opacity(0.3))
        Spacer()
        ZStack(alignment: .bottom) {
            Color(.white).ignoresSafeArea()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(oneLines) { writing in
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(writing.content)
                                        .font(.system(size: 16, weight: .semibold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color.orange.opacity(0.7))
                                        .foregroundColor(.white)
                                        .cornerRadius(18)
                                        .id(writing.id)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                modelContext.delete(writing)
                                            } label: {
                                                Label("삭제", systemImage: "trash")
                                            }
                                        }
                                    Text(dateFormatter.string(from: writing.date))
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 4)
                                }
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                        }
                    }
//                    .padding(.top, 20)
                    .padding(.bottom, 80)
                }
                .onChange(of: oneLines.count) { _ in
                    if let last = oneLines.last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            // 입력창 & 전송 버튼 (항상 하단에 고정)
            HStack(spacing: 8) {
                TextField(sentToday ? "" : "오늘의 한마디를 입력하세요", text: $oneLineText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray5))
                    .cornerRadius(20)
                    .focused($isTextFieldFocused)
                    .disabled(sentToday)
                    .foregroundColor(sentToday ? .gray : .black)
                    .overlay(
                        Group {
                            if sentToday {
                                Text("하루에 한 개만 입력할 수 있어요.")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                            }
                        }, alignment: .leading
                    )
                Button(action: {
                    let trimmed = oneLineText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty && !sentToday {
                        let writing = Writing(title: "오늘의 한마디", content: trimmed, date: Date(), type: .oneLine)
                        modelContext.insert(writing)
                        oneLineText = ""
                    }
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundColor(sentToday ? Color(.systemGray3) : Color.orange)
                }
                .disabled(sentToday)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.clear)
            .padding(.bottom, keyboardHeight > 0 ? min(keyboardHeight, 350) : 90)
            .animation(.easeInOut(duration: 0.2), value: keyboardHeight)

        }
        .onAppear {
            subscribeToKeyboardNotifications()
        }
        .onDisappear {
            unsubscribeFromKeyboardNotifications()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
    static func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy.MM.dd"
    return df
}()

#Preview {
    OneLineView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
} 
