import SwiftUI
import SwiftData
import Combine

// 세션 타이머 및 글쓰기 화면
struct SessionTimerView: View {
    let duration: Int // 총 세션 시간(초)
    let isLocationEnabled: Bool
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    @State private var remaining: Int
    @State private var text: String = ""
    @FocusState private var isTextFocused: Bool
    @State private var timer: Timer? = nil
    @State private var timerCancellable: AnyCancellable? = nil
    @State private var showEndAlert = false
    @State private var showCancelDialog = false
    @State private var title: String = ""
    @FocusState private var isTitleFocused: Bool
    @Environment(\.managedObjectContext) private var managedObjectContext
    @StateObject private var locationManager = LocationManager()

    init(duration: Int, isLocationEnabled: Bool = true) {
        self.duration = duration
        self.isLocationEnabled = isLocationEnabled
        _remaining = State(initialValue: duration)
    }

    var progress: CGFloat {
        CGFloat(remaining) / CGFloat(duration)
    }

    var timeString: String {
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    var sessionTitle: String {
        switch duration {
        case 180: return "3분 세션"
        case 300: return "5분 세션"
        case 420: return "7분 세션"
        default: return "글쓰기 세션"
        }
    }
    var sessionType: WritingType {
        switch duration {
        case 180: return .threeMin
        case 300: return .fiveMin
        case 420: return .sevenMin
        default: return .threeMin
        }
    }

    var locationText: String {
        if isLocationEnabled {
            return locationManager.currentAddress
        } else {
            return "위치정보 저장이 해제되어 있습니다."
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 상단 주황색 프로그레스 바
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.orange.opacity(0.3))
                            .frame(height: 16)
                        Rectangle()
                            .fill(remaining <= 30 ? Color.red : Color.orange)
                            .frame(width: geometry.size.width * progress, height: 16)
                    }
                    .frame(height: 16)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 16)
            // 남은 시간 & 등록 버튼
            ZStack {
                Text(timeString)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(remaining <= 30 ? .red : .black)
                HStack {
                    Button(action: {
                        showCancelDialog = true
                    }) {
                        Text("취소")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundColor(Color(.darkGray))
                    }
                    .padding(.leading, 20)
                    Spacer()
                    Button(action: { if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { showEndAlert = true } }) {
                        Text("등록")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor((!title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? .orange : .gray)
                    }
                    .padding(.trailing, 20)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding(.vertical, 12)
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
                        isTextFocused = true
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
            // 위치 표시 바
            HStack(spacing: 4) {
                Image(systemName: "mappin.and.ellipse")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                Text(locationText)
                    .font(.system(size: 14, weight: (isLocationEnabled ? .regular : .light)))
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .padding(.bottom, -8)

            // 본문 입력란
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("잘 써야 한다는 부담 없이 자유롭게 적어보세요!")
                        .foregroundColor(Color(.systemGray3))
                        .font(.system(size: 16))
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }
                TextEditor(text: $text)
                    .font(.system(size: 16))
                    .lineSpacing(3)
                    .padding(.horizontal, 14)
                    .background(Color.clear)
                    .focused($isTextFocused)
                    .scrollContentBackground(.hidden)
            }
            .frame(minHeight: 180, maxHeight: 260)
            .padding(.horizontal, 0)
            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            isTitleFocused = true
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
            timerCancellable?.cancel()
        }
        .alert("작성을 종료하시겠습니까?", isPresented: $showEndAlert) {
            Button("아니오", role: .cancel) {}
            Button("네", role: .destructive) { saveAndExit() }
        } message: {
            Text("작성한 내용이 저장됩니다.")
        }
        .confirmationDialog("작성을 종료하시겠습니까? 작성한 내용이 저장되지 않습니다.", isPresented: $showCancelDialog, titleVisibility: .visible) {
            Button("작성취소", role: .destructive) { presentationMode.wrappedValue.dismiss() }
            Button("취소", role: .cancel) {}
        }
    }

    func saveAndExit() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            let writing = Writing(
                context: managedObjectContext,
                title: trimmedTitle.isEmpty ? sessionTitle : trimmedTitle,
                content: trimmed,
                date: Date(),
                type: sessionType,
                address: locationManager.currentAddress
            )
            managedObjectContext.insert(writing)
        }
        presentationMode.wrappedValue.dismiss()
    }

    func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if remaining > 0 {
                    remaining -= 1
                } else {
                    timerCancellable?.cancel()
                    // 세션 종료: 자동 저장 후 뒤로 가기
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        saveAndExit()
                    }
                }
            }
    }
} 

#Preview {
    let context = PersistenceController.shared.container.viewContext
    return SessionTimerView(duration: 35)
        .environment(\.managedObjectContext, context)
}
