import SwiftUI

struct ModeSettingView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isLocationEnabled") var isLocationEnabled: Bool = true
    @AppStorage("themeColorHex") var themeColorHex: String = "#FF9500" // 기본 오렌지
    @AppStorage("selectedColorIndex") var selectedColorIndex: Int = 1  // 기본값은 오렌지(두번째)
    let availableColors: [Color] = [
        .red, .orange, .yellow, .green, .mint, .blue,
        .purple, .pink, .brown, .cyan, .gray, .black
    ]
    var body: some View {
        VStack(spacing: 24) {

            Text("글쓰기 설정")
                .font(.system(size: 16, weight: .bold))
                .padding(.top, 24)
            // 위치정보 저장 토글
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemGray5))
                    .frame(height: 90)
                HStack {
                    Text("위치정보 저장하기")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                    Spacer()
                    Toggle("", isOn: $isLocationEnabled)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
            }
            .padding(.horizontal, 18)
            // 색상 선택
            Text("테마 컬러")
                .font(.system(size: 16, weight: .bold))
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemGray5))
                    .frame(height: 150)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 6), spacing: 18) {
                    ForEach(Array(availableColors.enumerated()), id: \.element) { index, color in
                        Circle()
                            .fill(color)
                            .frame(width: 38, height: 38)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 0)
                                    .opacity(selectedColorIndex == index ? 1 : 0)
                            )
                            .onTapGesture {
                                selectedColorIndex = index
                                themeColorHex = color.toHex()
                            }
                    }
                }
                .padding(.vertical, 18)
                .padding(.horizontal, 18)
            }
            .padding(.horizontal, 18)
            Spacer()
        }
        .padding(.top, 0)
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            // 현재 themeColorHex에 해당하는 색상의 인덱스를 찾아서 설정
            if let index = availableColors.firstIndex(where: { $0.toHex() == themeColorHex }) {
                selectedColorIndex = index
            }
        }
    }
}

#Preview {
    ModeSettingView()
} 
