import SwiftUI
import PhotosUI

struct ProfileView: View {
    @ObservedObject var profileData: ProfileData
    @State private var showImagePicker = false
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .fill(Color.white)
                .frame(height: 56)
            HStack {
                Text("내 정보 편집")
                    .font(.system(size: 22, weight: .bold))
                    .padding(.leading, 20)
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
    Rectangle()
        .frame(height: 1)
        .foregroundColor(.gray.opacity(0.3))
        VStack(spacing: 32) {
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
            .padding(.top, 24)
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
                .font(.system(size: 18, weight: .semibold))
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.white))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
                .multilineTextAlignment(.center)
                .padding(.horizontal, 64)

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
