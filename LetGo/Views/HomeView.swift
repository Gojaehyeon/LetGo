import SwiftUI
import SwiftData

struct HomeView: View {
    @ObservedObject var profileData: ProfileData
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Writing.date, order: .reverse)]) var writings: [Writing]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color(.systemGray5).ignoresSafeArea()
            Color.white.ignoresSafeArea(edges: .top)
            VStack(spacing: 0) {
                // 상단 프로필
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 12) {
                        if let data = profileData.imageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 44, height: 44)
                                .clipShape(Circle())
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray4))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.white)
                            }
                        }
                        Text(profileData.nickname)
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 0)
                    .background(Color.white)
                }
                .padding(.top)
                .padding(.bottom, 24)

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
