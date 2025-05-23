import SwiftUI
import SwiftData

struct OneLineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Writing.date, order: .reverse)]) var allWritings: [Writing]
    @State private var oneLineText = ""
    
    var oneLines: [Writing] {
        allWritings.filter { $0.type == WritingType.oneLine.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("오늘의 한마디를 입력하세요", text: $oneLineText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal, 24)
            Button(action: {
                let trimmed = oneLineText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    let writing = Writing(title: "오늘의 한마디", content: trimmed, date: Date(), type: .oneLine)
                    modelContext.insert(writing)
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
                ForEach(oneLines, id: \ .self) { writing in
                    Text(writing.content)
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