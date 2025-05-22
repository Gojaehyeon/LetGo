import SwiftUI
import PhotosUI

struct ProfileView: View {
    @ObservedObject var profileData: ProfileData
    @State private var showImagePicker = false
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            // 프로필 이미지
            ZStack {
                if let data = profileData.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color(.systemGray4))
                        .frame(width: 120, height: 120)
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.white)
                }
            }
            .onTapGesture { showImagePicker = true }
            .photosPicker(isPresented: $showImagePicker, selection: $pickerItem)
            .onChange(of: pickerItem) { newItem in
                if let item = newItem {
                    item.loadTransferable(type: Data.self) { result in
                        if case .success(let data?) = result {
                            DispatchQueue.main.async {
                                profileData.imageData = data
                            }
                        }
                    }
                }
            }

            // 닉네임
            TextField("닉네임", text: $profileData.nickname)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Spacer()
        }
        .background(Color(.systemBackground))
        .navigationTitle("프로필")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView(profileData: ProfileData())
} 