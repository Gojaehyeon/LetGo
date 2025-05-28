import SwiftUI

struct ModeSettingView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isLocationEnabled") var isLocationEnabled: Bool = true
    var body: some View {
        VStack(spacing: 24) {
            Text("글쓰기 설정")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 32)
            Toggle("위치정보 저장", isOn: $isLocationEnabled)
                .padding(.horizontal, 24)
            Spacer()
//            Button("닫기") {
//                dismiss()
//            }
//            .font(.headline)
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color(.systemGray5))
//            .cornerRadius(12)
//            .padding(.bottom, 32)
        }
        .padding(.horizontal, 24)
    }
}
//
//#Preview {
//    ModeSettingView(isLocationEnabled: .constant(false))
//} 
