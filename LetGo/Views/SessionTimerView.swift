import SwiftUI
import SwiftData
import Combine

// 세션 타이머 및 글쓰기 화면
struct SessionTimerView: View {
    let duration: Int // 총 세션 시간(초)
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) private var presentationMode
    @State private var remaining: Int
    @State private var text: String = ""
    @FocusState private var isTextFocused: Bool
    @State private var timer: Timer? = nil
    @State private var timerCancellable: AnyCancellable? = nil
    @State private var showEndAlert = false
    @State private var title: String = ""
    @FocusState private var isTitleFocused: Bool

    init(duration: Int) {
        self.duration = duration
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

    var body: some View {
        VStack(spacing: 0) {
            // 상단 주황색 프로그레스 바
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    ZStack(alignment: .leading) {
                        // 배경 바
                        Rectangle()
                            .fill(Color.orange.opacity(0.3))
                            .frame(height: 16)
                        
                        // 진행 바
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
                    Spacer()
                    Button(action: { showEndAlert = true }) {
                        Text("등록")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.orange)
                    }
                    .padding(.trailing, 20)
                }
            }
            .padding(.vertical, 12)
            Divider()
            // 제목 입력란 (placeholder 분리)
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
                        isTextFocused = true
                    }
            }
            .padding(.top, 0)
            Divider()
                .padding(.horizontal, 16)
                .padding(.bottom, 0)
            // 본문 입력란
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text("잘 써야 한다는 부담 없이 자유롭게 적어보세요!")
                        .foregroundColor(Color(.systemGray3))
                        .font(.system(size: 16))
                        .padding(.horizontal, 20)
                        .padding(.top, 22)
                }
                TextEditor(text: $text)
                    .font(.system(size: 16))
                    .lineSpacing(3)
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
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
    }

    func saveAndExit() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            let writing = Writing(title: trimmedTitle.isEmpty ? sessionTitle : trimmedTitle, content: trimmed, date: Date(), type: sessionType)
            modelContext.insert(writing)
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
    SessionTimerView(duration: 35)
}
