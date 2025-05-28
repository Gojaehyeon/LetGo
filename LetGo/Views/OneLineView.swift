import SwiftUI
import CoreData

struct OneLineView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: Writing.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Writing.date, ascending: true)],
        animation: .default
    ) var allWritings: FetchedResults<Writing>
    @State private var oneLineText = ""
    @State private var keyboardHeight: CGFloat = 0
    @FocusState private var isTextFieldFocused: Bool
    @State private var showCopiedToast = false
    
    var oneLines: [Writing] {
        allWritings.filter { $0.type == WritingType.oneLine.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            OneLineHeader()
            Spacer()
            ZStack(alignment: .bottom) {
                Color(.white).ignoresSafeArea()
                OneLineList(
                    oneLines: oneLines,
                    context: context,
                    showCopiedToast: $showCopiedToast,
                    onDelete: { w in
                        context.delete(w)
                        try? context.save()
                    },
                    onCopy: { content in
                        UIPasteboard.general.string = content
                        showCopiedToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showCopiedToast = false
                        }
                    }
                )
                OneLineInputBar(
                    oneLineText: $oneLineText,
                    isTextFieldFocused: _isTextFieldFocused,
                    onSend: { trimmed in
                        let writing = Writing(context: context, title: "오늘의 한마디", content: trimmed, date: Date(), type: .oneLine)
                        try? context.save()
                        oneLineText = ""
                    },
                    keyboardHeight: keyboardHeight
                )
            }
            .onAppear {
                subscribeToKeyboardNotifications()
            }
            .onDisappear {
                unsubscribeFromKeyboardNotifications()
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .overlay(
                Group {
                    if showCopiedToast {
                        Text("복사되었습니다")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: showCopiedToast)
                , alignment: .top
            )
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

struct OneLineHeader: View {
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color.white)
                .frame(height: 56)
            HStack {
                Text("생각 한마디")
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
    }
}

struct OneLineInputBar: View {
    @Binding var oneLineText: String
    @FocusState var isTextFieldFocused: Bool
    var onSend: (String) -> Void
    var keyboardHeight: CGFloat
    var body: some View {
        HStack(spacing: 8) {
            TextField("생각 한마디를 입력하세요", text: $oneLineText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray5))
                .cornerRadius(20)
                .focused($isTextFieldFocused)
                .foregroundColor(.black)
            Button(action: {
                let trimmed = oneLineText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    onSend(trimmed)
                }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .resizable()
                    .frame(width: 36, height: 36)
                    .foregroundColor(Color.theme)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.clear)
        .padding(.bottom, keyboardHeight > 0 ? min(keyboardHeight, 350) : 90)
        .animation(.easeInOut(duration: 0.2), value: keyboardHeight)
    }
}

struct OneLineList: View {
    let oneLines: [Writing]
    let context: NSManagedObjectContext
    @Binding var showCopiedToast: Bool
    var onDelete: (Writing) -> Void
    var onCopy: (String) -> Void
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(oneLines, id: \.objectID) { writing in
                        OneLineRow(
                            writing: writing,
                            onDelete: onDelete,
                            onCopy: onCopy
                        )
                    }
                }
                .padding(.bottom, 80)
            }
            .onChange(of: oneLines.count) { _ in
                if let last = oneLines.last {
                    withAnimation {
                        proxy.scrollTo(last.objectID, anchor: .bottom)
                    }
                }
            }
        }
    }
}

struct OneLineRow: View {
    let writing: Writing
    let onDelete: (Writing) -> Void
    let onCopy: (String) -> Void

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(writing.content)
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.theme.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(18)
                    .contextMenu {
                        Button {
                            onCopy(writing.content)
                        } label: {
                            Label("복사", systemImage: "doc.on.doc")
                        }
                        Button(role: .destructive) {
                            onDelete(writing)
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

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy.MM.dd"
    return df
}()

#Preview {
    OneLineView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
} 
