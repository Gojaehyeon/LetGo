import SwiftUI
import CoreData

enum HomeFilter: String, CaseIterable {
    case all = "전체보기"
    case liked = "좋아요 표시한 항목"
}

struct HomeView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(
        entity: Writing.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Writing.date, ascending: false)],
        animation: .default
    ) var writings: FetchedResults<Writing>
    @State private var showFilterMenu = false
    @State private var selectedFilter: HomeFilter = .all
    @Binding var selectedWriting: Writing?
    @Binding var refreshID: UUID
    @Binding var selectedEditingWriting: Writing?
    @State private var useTransition: Bool = true
    @State private var refreshCount: Int = 0
    @State private var showCloudKitAlert: Bool = false

    var filteredWritings: [Writing] {
        switch selectedFilter {
        case .all:
            return writings.filter { $0.writingType != .oneLine }
        case .liked:
            return writings.filter { $0.isLiked && $0.writingType != .oneLine }
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
                        ForEach(filteredWritings, id: \.objectID) { writing in
                            WritingCard(writing: writing, onDelete: { w in
                                context.delete(w)
                                try? context.save()
                            }, onEdit: {
                                selectedEditingWriting = writing
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
                    .id(refreshID)
                    .padding(.top, 12)
                    .padding(.bottom, 60)
                }
                .refreshable {
                    refreshCount += 1
                    if refreshCount % 5 == 0 {
                        showCloudKitAlert = true
                    }
                    context.refreshAllObjects()
                    refreshID = UUID()
                }
            }
            // WritingDetailView 오버레이
            if let writing = selectedWriting {
                let transition = useTransition ? AnyTransition.move(edge: .trailing) : .identity
                WritingDetailView(writing: writing, onClose: { withTransition in
                    if withTransition {
                        withAnimation(.easeInOut) { selectedWriting = nil }
                    } else {
                        selectedWriting = nil
                    }
                    useTransition = withTransition
                }, selectedEditingWriting: $selectedEditingWriting)
                .transition(transition)
                .zIndex(1)
            }
        }
        .alert("아이클라우드 동기화가 진행 중입니다.\n빠른 반영을 원하시면 앱을 재실행해주세요.", isPresented: $showCloudKitAlert) {
            Button("확인", role: .cancel) { }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy.MM.dd"
    return df
}()

#Preview {
    HomeView(selectedWriting: .constant(nil), refreshID: .constant(UUID()), selectedEditingWriting: .constant(nil))
} 
