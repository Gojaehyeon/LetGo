import SwiftUI
import SwiftData

enum HomeFilter: String, CaseIterable {
    case all = "전체보기"
    case oneLine = "오늘의 한마디"
    case liked = "좋아요 표시한 항목"
}

struct HomeView: View {
    @ObservedObject var profileData: ProfileData
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Writing.date, order: .reverse)]) var writings: [Writing]
    @State private var showFilterMenu = false
    @State private var selectedFilter: HomeFilter = .all
    @Binding var selectedWriting: Writing?

    var filteredWritings: [Writing] {
        switch selectedFilter {
        case .all:
            return writings
        case .oneLine:
            return writings.filter { $0.writingType == .oneLine }
        case .liked:
            return writings.filter { $0.isLiked }
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                // 상단 전체보기 영역
                ZStack(alignment: .top) {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 56)
                    Button(action: { showFilterMenu = true }) {
                        HStack {
                            Text(selectedFilter.rawValue)
                                .font(.system(size: 22, weight: .bold))
                                .padding(.leading, 20)
                                .foregroundColor(.black)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .medium))
                                .padding(.top, 2)
                            Spacer()
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    }
                    .confirmationDialog("", isPresented: $showFilterMenu, titleVisibility: .hidden) {
                        ForEach(HomeFilter.allCases, id: \ .self) { filter in
                            Button(filter.rawValue) { selectedFilter = filter }
                        }
                    }
                }
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3))
                    .padding(.bottom, 8)


                // 본문
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(filteredWritings, id: \ .id) { writing in
                            WritingCard(writing: writing, onDelete: { w in
                                modelContext.delete(w)
                            })
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    selectedWriting = writing
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
            // WritingDetailView 오버레이
            if let writing = selectedWriting {
                WritingDetailView(writing: writing, onClose: {
                    withAnimation(.easeInOut) {
                        selectedWriting = nil
                    }
                })
                .transition(.move(edge: .trailing))
                .zIndex(1)
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy.MM.dd"
    return df
}()

#Preview {
    HomeView(profileData: ProfileData(), selectedWriting: .constant(nil))
} 
