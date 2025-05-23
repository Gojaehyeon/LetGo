import SwiftUI
import SwiftData

struct OneLineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Writing.date, order: .forward)]) var allWritings: [Writing]
    @State private var oneLineText = ""
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    @Binding var selectedTab: Int
    
    var oneLines: [Writing] {
        allWritings.filter { $0.type == WritingType.oneLine.rawValue }
    }
    var sentToday: Bool {
        oneLines.contains { Calendar.current.isDateInToday($0.date) }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemGray6).ignoresSafeArea()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(oneLines) { writing in
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(writing.content)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color(.systemGray4))
                                        .foregroundColor(.black)
                                        .cornerRadius(18)
                                        .id(writing.id)
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
                    .padding(.top, 20)
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
            // 입력창 & 전송 버튼
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    TextField(sentToday ? "" : "오늘의 한마디를 입력하세요", text: $oneLineText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .cornerRadius(20)
                        .focused($isTextFieldFocused)
                        .disabled(sentToday)
                        .foregroundColor(sentToday ? .gray : .primary)
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
                            .foregroundColor(sentToday ? Color(.systemGray3) : Color.blue)
                    }
                    .disabled(sentToday)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemBackground).opacity(0.95))
                .padding(.bottom, keyboardHeight)
                .animation(.easeInOut(duration: 0.2), value: keyboardHeight)
            }
        }
        .onAppear {
            subscribeToKeyboardNotifications()
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
    OneLineView(selectedTab: .constant(0))
} 