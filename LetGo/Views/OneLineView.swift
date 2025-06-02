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
            ZStack(alignment: .bottom) {
                let isPhone: Bool = {
#if os(iOS)
                    return UIDevice.current.userInterfaceIdiom == .phone
#else
                    return false
#endif
                }()
                Color(.white)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if isPhone {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
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
                    },
                    keyboardHeight: $keyboardHeight
                )
                .allowsHitTesting(!(isPhone && isTextFieldFocused))
                OneLineInputBar(
                    oneLineText: $oneLineText,
                    isTextFieldFocused: _isTextFieldFocused,
                    onSend: { trimmed in
                        let writing = Writing(context: context, title: NSLocalizedString("one_line_title", comment: ""), content: trimmed, date: Date(), type: .oneLine)
                        try? context.save()
                        oneLineText = ""
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            NotificationCenter.default.post(name: Notification.Name("ScrollToBottom"), object: nil)
                        }
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
                        Text(NSLocalizedString("copied", comment: ""))
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
//        HStack {
//            Text(NSLocalizedString("one_line_title", comment: ""))
//                .font(.system(size: 22, weight: .bold))
//                .padding(.leading, 20)
//            Spacer()
//        }
//        .padding(.top, 16)
//        .padding(.bottom, 8)
//        .background(Color.white)
//        Divider()
    }
}

struct OneLineInputBar: View {
    @Binding var oneLineText: String
    @FocusState var isTextFieldFocused: Bool
    var onSend: (String) -> Void
    var keyboardHeight: CGFloat
    var body: some View {
        let isPhone: Bool = {
#if os(iOS)
            return UIDevice.current.userInterfaceIdiom == .phone
#else
            return false
#endif
        }()
        HStack(spacing: 8) {
            TextField(NSLocalizedString("write_placeholder", comment: ""), text: $oneLineText)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray5))
                .cornerRadius(20)
                .focused($isTextFieldFocused)
                .foregroundColor(.black)
                .onSubmit {
                    if !isPhone {
                        let trimmed = oneLineText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            onSend(trimmed)
                        }
                    }
                    // iPhone에서는 줄바꿈만, 전송 안 함
                }
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
    @Binding var keyboardHeight: CGFloat

    var body: some View {
        let datedRows: [(Writing, String?)] = oneLines.enumerated().map { index, writing in
            let currentDate = writing.date
            let isLast = index == oneLines.count - 1
            let nextDate = isLast ? nil : oneLines[index + 1].date

            let sameMinuteAsNext = nextDate != nil &&
                Calendar.current.isDate(currentDate, equalTo: nextDate!, toGranularity: .minute)

            let showTime = !sameMinuteAsNext
            let isLastOfDay = isLast ||
                !Calendar.current.isDate(currentDate, inSameDayAs: nextDate!)

            let dateText: String? = showTime
                ? (isLastOfDay ? fullFormatter.string(from: currentDate) : timeFormatter.string(from: currentDate))
                : nil

            return (writing, dateText)
        }
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(datedRows, id: \.0.objectID) { writing, dateText in
                        OneLineRow(
                            writing: writing,
                            onDelete: onDelete,
                            onCopy: onCopy,
                            dateText: dateText
                        )
                    }
                    Color.clear
                        .frame(height: 140 + keyboardHeight)
                        .id("bottomSpacer")
                }
                .padding(.bottom, 150)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        proxy.scrollTo("bottomSpacer", anchor: .bottom)
                    }
                }
            }
            .onChange(of: oneLines.count) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation {
                        proxy.scrollTo("bottomSpacer", anchor: .bottom)
                    }
                }
            }
            .onChange(of: keyboardHeight) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation {
                        proxy.scrollTo("bottomSpacer", anchor: .bottom)
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("ScrollToBottom"))) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation {
                        proxy.scrollTo("bottomSpacer", anchor: .bottom)
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
    let dateText: String?

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
                            Label(NSLocalizedString("copy", comment: ""), systemImage: "doc.on.doc")
                        }
                        Button(role: .destructive) {
                            onDelete(writing)
                        } label: {
                            Label(NSLocalizedString("delete", comment: ""), systemImage: "trash")
                        }
                    }
                if let dateText = dateText {
                    Text(dateText)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.trailing, 4)
                }
            }
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 12)
    }
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    df.timeStyle = .none
    df.locale = Locale.current
    return df
}()

private let timeFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .none
    df.timeStyle = .short
    df.locale = Locale.current
    return df
}()

private let fullFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateStyle = .medium
    df.timeStyle = .short
    df.locale = Locale.current
    return df
}()

#Preview {
    OneLineView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
}
