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
        return String(format: "%02d:%02d 남음", m, s)
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
        // 필요시 타입별로 다르게 지정
        return .oneLine
    }

    var body: some View {
        VStack(spacing: 0) {
            // 상단 프로그레스 바
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 28)
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: UIScreen.main.bounds.width * progress, height: 28)
                    .animation(.linear(duration: 0.5), value: remaining)
            }
            .clipShape(RoundedRectangle(cornerRadius: 0))
            .padding(.bottom, 0)

            // 남은 시간 + 작성 완료 버튼
            HStack {
                Text(timeString)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Button(action: { showEndAlert = true }) {
                    Text("작성 완료")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color(.systemGray5))

            // 텍스트 입력 영역
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                TextEditor(text: $text)
                    .font(.system(size: 18))
                    .padding(12)
                    .focused($isTextFocused)
                    .background(Color.clear)
                    .cornerRadius(16)
            }
            .frame(height: 320)
            .padding(.horizontal, 16)
            .padding(.top, 18)

            Spacer()
        }
        .background(Color(.systemGray5).ignoresSafeArea())
        .onAppear {
            isTextFocused = true
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
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            let writing = Writing(title: sessionTitle, content: trimmed, date: Date(), type: sessionType)
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
