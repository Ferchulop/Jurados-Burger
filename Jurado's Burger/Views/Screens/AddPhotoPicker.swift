//
//  AddPhotoView.swift
//  Jurado's Burger
//
//  Created by Fernando Jurado on 21/7/25.
//

import SwiftUI
import PhotosUI

struct AddPhotoView: View {
    @Binding var imageData: Data?
    @State  private var selectedItems: PhotosPickerItem?
    var body: some View {
        PhotosPicker(selection: $selectedItems, matching: .images, photoLibrary: .shared()) {
            AvatarView(imageData: imageData, size:  100)
        }
        .task(id: selectedItems) {
            if let data = try? await selectedItems?.loadTransferable(type: Data.self) {
                imageData = data
                
            }
        }
    }
}

#Preview {
    AddPhotoView(imageData:.constant(nil))
}
