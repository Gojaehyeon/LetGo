import SwiftUI
import CoreData

func isPadOrMac() -> Bool {
    #if targetEnvironment(macCatalyst)
    return true
    #else
    return UIDevice.current.userInterfaceIdiom == .pad
    #endif
}

struct MainTabView: View {
    @State private var selectedTab: Int = 1
    @State private var isTabBarHidden: Bool = false
    @State private var selectedWriting: Writing? = nil
    @State private var selectedEditingWriting: Writing? = nil
    @State private var refreshID = UUID()
    @State private var showWriteModal = false
    @State private var showWriteSheet = false
    @State private var showOneLineOverlay = false
    @State private var oneLineOffset: CGFloat = UIScreen.main.bounds.width
    @Environment(\.managedObjectContext) private var context

    var mainProfile: UserProfile {
        let mainProfileID = "mainProfile"
        let request = NSFetchRequest<UserProfile>(entityName: "UserProfile")
        request.predicate = NSPredicate(format: "id == %@", mainProfileID)
        request.fetchLimit = 1
        if let result = try? context.fetch(request), let profile = result.first {
            return profile
        } else {
            let newProfile = UserProfile(context: context)
            newProfile.id = mainProfileID
            try? context.save()
            return newProfile
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                if selectedTab == 0 {
                    NavigationStack {
                        HomeView(selectedWriting: $selectedWriting, refreshID: $refreshID, selectedEditingWriting: $selectedEditingWriting)
                    }
                } else if selectedTab == 1 {
                    SessionView(selectedTab: $selectedTab, isTabBarHidden: $isTabBarHidden, showOneLineOverlay: $showOneLineOverlay, oneLineOffset: $oneLineOffset)
                } else if selectedTab == 2 {
                    ClusterMapView(isTabBarHidden: $isTabBarHidden)
                } else {
                    ProfileView(userProfile:  mainProfile)
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
                    .fill(selectedTab == 2 ? Color.clear : Color.white)
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
                    TabBarItem(icon: "map", isSelected: selectedTab == 2, isSessionView: false)
                        .offset(y: -18)
                        .onTapGesture { selectedTab = 2 }
                    TabBarItem(icon: "person.fill", isSelected: selectedTab == 3, isSessionView: false)
                        .offset(y: -18)
                        .onTapGesture { selectedTab = 3 }
                }
                .frame(height: 80)
            }
            if showOneLineOverlay {
                ZStack(alignment: .topLeading) {
                    Color.white.ignoresSafeArea()
                    VStack(spacing: 0) {
                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.1)) { oneLineOffset = UIScreen.main.bounds.width }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { showOneLineOverlay = false; oneLineOffset = UIScreen.main.bounds.width }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(.darkGray))
                                    .padding(.leading, 10)
                            }
                            Spacer()
                        }
                        .padding(.top, 16)
                        .padding(.leading, 8)
                        .padding(.bottom, 16)
                        Divider()
                        OneLineView()
                    }
                }
                .offset(x: oneLineOffset)
                .gesture(DragGesture()
                    .onChanged { value in if value.translation.width > 0 { oneLineOffset = value.translation.width } }
                    .onEnded { value in
                        if value.translation.width > 100 {
                            withAnimation(.easeInOut(duration: 0.1)) { oneLineOffset = UIScreen.main.bounds.width }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { showOneLineOverlay = false; oneLineOffset = UIScreen.main.bounds.width }
                        } else { withAnimation { oneLineOffset = 0 } }
                    }
                )
                .zIndex(200)
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
                                Text(NSLocalizedString("write_free", comment: ""))
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
                    .frame(width: 180)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 8)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, isPadOrMac() ? 100 : 80)
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
 
