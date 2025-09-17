//
//  LocationDetailView.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 29/6/25.
//

import SwiftUI
import UIKit

struct LocationDetailView: View {
    @State private var viewModel: LocationDetailViewModel
    @State private var selectedUser: JuradosProfile? = nil
    @Namespace private var animation
    
    init(location: JuradosLocation) {
        self.viewModel = LocationDetailViewModel(location: location)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 15) {
                    BannerView(image: viewModel.location.createBannerImage(), location: viewModel.location)
                    
                    HStack {
                        AddressView(address: viewModel.location.address)
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    DescriptionView(text: viewModel.location.description)
                    
                    Text("Jurado's Burger Info:")
                        .fontWeight(.bold)
                        .font(.title3)
                    
                    ZStack {
                        Capsule()
                            .fill(.thinMaterial)
                            .frame(height: 80)
                            .opacity(0.8)
                            .shadow(radius: 5)
                        
                        HStack(spacing: 25) {
                            Link(destination: URL(string: viewModel.location.website)!, label: {
                                LocationButtons(color: .myPrimary, imageName: "network")
                                    .accessibilityLabel("Go to website")
                            })
                            
                            Button {
                                viewModel.callLocationNumber()
                            } label: {
                                LocationButtons(color: .myPrimary, imageName: "phone.fill")
                                    .accessibilityLabel("Call \(viewModel.location.name)")
                            }
                            
                            Button {
                                Task {
                                    await viewModel.updateCheckInStatus(to: viewModel.isCheckedIn ? .checkedOut : .checkedIn)
                                    HapticsManager.success()
                                }
                            } label: {
                                LocationButtons(color: viewModel.isCheckedIn ? .red : .myPrimary, imageName: viewModel.isCheckedIn ? "person.fill.badge.minus" : "person.fill.badge.plus")
                                    .accessibilityLabel(viewModel.isCheckedIn ? "Check out" : "Check in")
                            }
                            
                            Button {
                                viewModel.navigateToLocationInMaps()
                            } label: {
                                LocationButtons(color: .myPrimary, imageName: "location.fill")
                                    .accessibilityLabel("Get directions")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Text("Who's eating at Jurado's now?")
                        .fontWeight(.bold)
                        .font(.title3)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Who's eating at Jurado's now? \(viewModel.checkedInProfiles.count) checked in.")
                        .accessibilityHint("Bottom section is scrollable.")
                    
                    ZStack {
                        if viewModel.checkedInProfiles.isEmpty {
                            Text("Nobody is here yet!")
                                .foregroundStyle(.secondary)
                            
                        } else {
                            ScrollView {
                                LazyVGrid(columns: viewModel.columns, spacing: 50) {
                                    ForEach(viewModel.checkedInProfiles) { profile in
                                        FirstNameAvatarView(profile: profile, namespace: animation, selectedUser: $selectedUser)
                                    }
                                }
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .padding(20)
                    
                    Spacer()
                }
                
                
                if let selectedUser = selectedUser {
                    ProfileExpandableView(
                        profile: selectedUser,
                        namespace: animation
                    ) {
                        withAnimation(.spring()) {
                            self.selectedUser = nil
                        }
                    }
                    .zIndex(2) // Evito que la transicion pase por detras de botones
                }
            }
            .onAppear {
                Task {
                    if CloudKitManager.shared.userRecord == nil {
                        do {
                            try await CloudKitManager.shared.getUserRecord()
                        } catch {
                            print("Can't get user record in LocationDetailView")
                        }
                    }
                    await viewModel.getCheckedInStatus()
                    await viewModel.getCheckedInProfiles()
                }
            }
            .alert(viewModel.unableToCheckIn? .title ?? "Error", isPresented: $viewModel.unableProfile) {
                Button("OK", role: .cancel) {}
                
            } message: {
                Text(viewModel.unableToCheckIn? .message ?? "An error occurred while getting the profile")
            }
            .navigationTitle(viewModel.location.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct LocationButtons: View {
    var color: Color
    var imageName: String
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(color)
                .frame(width: 60, height: 60)
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(.black)
        }
    }
}

struct FirstNameAvatarView: View {
    var profile: JuradosProfile
    var namespace: Namespace.ID
    @Binding var selectedUser: JuradosProfile?
    
    var body: some View {
        VStack {
            AvatarView(imageData:profile.avatarData, size: 50)
                .matchedGeometryEffect(id: "\(profile.id)-pic", in: namespace)
            Text(profile.firstName)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.60)
                .matchedGeometryEffect(id: "\(profile.id)-name", in: namespace)
        }
        .opacity(selectedUser == nil ? 1 : 0)
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel("\(profile.fullName), Double tap to view profile")
        .onTapGesture {
            withAnimation(.spring()) {
                selectedUser = profile
            }
        }
    }
}
struct AddressView: View {
    var address: String
    
    var body: some View {
        Label(address, systemImage: "mappin.and.ellipse")
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.80)
    }
}

struct DescriptionView: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.subheadline)
            .lineLimit(3)
            .minimumScaleFactor(0.75)
            .padding(.horizontal)
    }
}

struct BannerView: View {
    var image: UIImage
    var location: JuradosLocation
    
    var body: some View {
        if location.bannerAsset != nil {
            Image(uiImage: location.createBannerImage())
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
        } else {
            Image(.burguerBanner)
                .resizable()
                .scaledToFit()
                .accessibilityHidden(true )
        }
    }
}

