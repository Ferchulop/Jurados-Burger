//
//  ProfileExpandableView.swift
//  Jurado's Burger
//
//  Created by Fernando Jurado on 30/7/25.
//

import SwiftUI

struct ProfileExpandableView: View {
    var profile: JuradosProfile
    var namespace: Namespace.ID
    var onClose: () -> Void
    
    var body: some View {
        ZStack {
            
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            VStack(spacing: 10) {
                
                AvatarView(imageData: profile.avatarData, size: 100)
                    .matchedGeometryEffect(id: "\(profile.id)-pic", in: namespace)
                    .accessibilityHidden(true)
                
                Text(profile.fullName)
                    .fontWeight(.bold)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .matchedGeometryEffect(id: "\(profile.id)-name", in: namespace)
                    .minimumScaleFactor(0.70)
                    .accessibilityLabel("Full Name:\(profile.fullName)" )
                
                Text(profile.profession)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .accessibilityLabel("Profession:\(profile.profession)")
                
                Text(profile.biography)
                    .font(.body)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .accessibilityLabel("Biography:\(profile.biography)")
                
                Button("Close") {
                    onClose()
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(Color.myPrimary)
                .foregroundStyle(.black)
                .clipShape(Capsule())
                .accessibilityLabel("Close profile")
            }
            .padding(40)
            .accessibilityAddTraits(.isModal)
        }
    }
}

#Preview {
    @Previewable @Namespace var namespace
    return ProfileExpandableView(
        profile: JuradosProfile(record: SampleData.profile),
        namespace: namespace,
        onClose: {}
    )
}
