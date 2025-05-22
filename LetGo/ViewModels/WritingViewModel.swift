import Foundation
import SwiftUI

class WritingViewModel: ObservableObject {
    @Published var writings: [Writing] = []
    
    func addWriting(_ writing: Writing) {
        writings.append(writing)
    }
    
    func deleteWriting(at indexSet: IndexSet) {
        writings.remove(atOffsets: indexSet)
    }
    
    func updateWriting(_ writing: Writing) {
        if let index = writings.firstIndex(where: { $0.id == writing.id }) {
            writings[index] = writing
        }
    }
    
    func getWritingsByType(_ type: WritingType) -> [Writing] {
        return writings.filter { $0.type == type }
    }
} 