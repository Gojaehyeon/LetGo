import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 1
    @State private var isTabBarHidden: Bool = false
    @State private var selectedWriting: Writing? = nil
    @State private var selectedEditingWriting: Writing? = nil
    @State private var refreshID = UUID()
    @State private var showWriteModal = false
    @State private var showWriteSheet = false
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                if selectedTab == 0 {
                    NavigationStack {
                        HomeView(selectedWriting: $selectedWriting, refreshID: $refreshID, selectedEditingWriting: $selectedEditingWriting)
                    }
                } else if selectedTab == 1 {
                    SessionView(selectedTab: $selectedTab, isTabBarHidden: $isTabBarHidden)
                } else if selectedTab == 2 {
                    OneLineView()
                } else {
                    ProfileView()
                }
            }
            if let writing = selectedWriting {
                WritingDetailView(writing: writing, onClose: { withTransition in
                    if withTransition {
                        withAnimation(.easeInOut) { selectedWriting = nil }
                    } else {
                        selectedWriting = nil
                    }
                    refreshID = UUID()
                }, selectedEditingWriting: $selectedEditingWriting)
                .transition(.move(edge: .trailing))
                .zIndex(100)
            }
            if let editingWriting = selectedEditingWriting {
                WritingEditView(writing: editingWriting, onSave: {
                    selectedEditingWriting = nil
                    selectedWriting = nil
                    refreshID = UUID()
                })
            }
            if !isTabBarHidden && selectedWriting == nil {
                Rectangle()
                    .fill(Color.white)
                    .frame(height: 85)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: -2)
                    .opacity(selectedTab == 1 ? 0 : 1)
                HStack(spacing: 48) {
                    TabBarItem(icon: "line.3.horizontal.circle.fill", isSelected: selectedTab == 0, isSessionView: false)
                        .offset(y: -18)
                        .onTapGesture { selectedTab = 0 }
                    TabBarItem(icon: "play.circle", isSelected: selectedTab == 1, isSessionView: false)
                        .opacity(selectedTab == 1 ? 0.85 : 1.0)
                        .offset(y: -18)
                        .onTapGesture { selectedTab = 1 }
                    AnimatedPlusButton(isActive: $showWriteModal)
                        .offset(y: -18)
                    TabBarItem(icon: "ellipsis.bubble.fill", isSelected: selectedTab == 2, isSessionView: false)
                        .offset(y: -18)
                        .onTapGesture { selectedTab = 2 }
                    TabBarItem(icon: "person.fill", isSelected: selectedTab == 3, isSessionView: false)
                        .offset(y: -18)
                        .onTapGesture { selectedTab = 3 }
                }
                .frame(height: 80)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .overlay(
            Group {
                if showWriteModal {
                    Color.black.opacity(0.005)
                        .ignoresSafeArea()
                        .onTapGesture { showWriteModal = false }
                    VStack(spacing: 0) {
                        Button(action: {
                            showWriteModal = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                showWriteSheet = true
                            }
                        }) {
                            HStack {
                                Text("자유 글쓰기")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "pencil")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 22)
                            .padding(.vertical, 18)
                        }
                    }
                    .frame(width: 160)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 8)
                    .padding(.top, 550)
//                    .transition(
//                        .asymmetric(
//                            insertion: .move(edge: .bottom).combined(with: .opacity),
//                            removal: .move(edge: .bottom).combined(with: .opacity)
//                        )
//                    )
                }
            }, alignment: .center
        )
        .fullScreenCover(isPresented: $showWriteSheet) {
            WriteView(onSave: {
                showWriteSheet = false
                refreshID = UUID()
            })
        }
        .animation(.easeInOut(duration: 0.3), value: showWriteModal)
    }
}

struct AnimatedPlusButton: View {
    @Binding var isActive: Bool
    var body: some View {
        ZStack {
            // plus.app 아이콘 (비활성화 시만 보임)
            Image(systemName: "plus.app")
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
                .foregroundColor(.gray)
                .rotationEffect(.degrees(isActive ? 90 : 0))
                .opacity(isActive ? 0 : 1)
                .animation(.easeInOut(duration: 0.32), value: isActive)
            // x 아이콘 (활성화 시만 보임)
            Image("x_black")
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
                .rotationEffect(.degrees(isActive ? 0 : -90))
                .opacity(isActive ? 1 : 0)
                .animation(.easeInOut(duration: 0.32), value: isActive)
        }
        .onTapGesture {
            withAnimation {
                isActive.toggle()
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
