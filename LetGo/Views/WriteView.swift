import SwiftUI
import SwiftData
import Foundation

struct WriteView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    @State private var title = ""
    @State private var content = ""
    @State private var selectedType: WritingType = .oneLine
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("제목")) {
                    TextField("제목을 입력하세요", text: $title)
                }
                
                Section(header: Text("내용")) {
                    TextEditor(text: $content)
                        .frame(height: 200)
                }
                
                Section(header: Text("유형")) {
                    Picker("유형 선택", selection: $selectedType) {
                        ForEach(WritingType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
            }
            .navigationTitle("새 글 작성")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        let writing = Writing(context: managedObjectContext, title: title, content: content, date: Date(), type: selectedType)
                        managedObjectContext.insert(writing)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let context = PersistenceController.shared.container.viewContext
    return WriteView()
        .environment(\.managedObjectContext, context)
} 
