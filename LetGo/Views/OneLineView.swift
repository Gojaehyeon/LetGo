import SwiftUI

struct OneLineView: View {
    @State private var oneLineText = ""
    @State private var lines: [String] = []
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("오늘의 한마디를 입력하세요", text: $oneLineText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 24)
            Button(action: {
                let trimmed = oneLineText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    lines.insert(trimmed, at: 0)
                    oneLineText = ""
                }
            }) {
                Text("저장")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 24)
            List {
                ForEach(lines, id: \.self) { line in
                    Text(line)
                        .padding(.vertical, 8)
                }
            }
            .listStyle(PlainListStyle())
        }
        .padding(.top, 40)
        .background(Color.clear)
    }
}

#Preview {
    OneLineView()
} 