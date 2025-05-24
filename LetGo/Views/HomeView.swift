import SwiftUI
import SwiftData

struct HomeView: View {
    @ObservedObject var profileData: ProfileData
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Writing.date, order: .reverse)]) var writings: [Writing]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(.white).ignoresSafeArea()
            Color.white.ignoresSafeArea(edges: .top)
            VStack(spacing: 0) {
                // 상단 전체보기 영역
                    ZStack(alignment: .top) {
                        Rectangle()
                            .fill(Color.white)
                            .frame(height: 56)
                        HStack {
                            Text("전체보기")
                                .font(.system(size: 22, weight: .bold))
                                .padding(.leading, 20)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16, weight: .medium))
                                .padding(.top, 2)
                            Spacer()
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    }
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3))
//                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: 2)


                // 본문
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(writings, id: \ .self) { writing in
                            ZStack(alignment: .topTrailing) {
                                WritingCard(writing: writing)
//                                HStack(spacing: 0) {
//                                    Button(action: {
//                                        // 공유 액션 (임시)
//                                    }) {
//                                        Image(systemName: "square.and.arrow.up")
//                                            .foregroundColor(.gray)
//                                    }
//                                    .padding(.trailing, 8)
//                                    Button(action: {
//                                        // 삭제 로직
//                                        modelContext.delete(writing)
//                                    }) {
//                                        Image(systemName: "trash")
//                                            .foregroundColor(.red)
//                                    }
//                                }
//                                .padding(.top, 8)
//                                .padding(.trailing, 12)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
                .background(Color.white)
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy.MM.dd"
    return df
}() 
