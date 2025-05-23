import SwiftUI

struct ModeSettingView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 24) {
            Text("모드 설정")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 32)
            Text("여기에 모드 관련 설정 UI를 추가하세요.")
                .foregroundColor(.gray)
            Spacer()
            Button("닫기") {
                dismiss()
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray5))
            .cornerRadius(12)
            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    ModeSettingView()
} 