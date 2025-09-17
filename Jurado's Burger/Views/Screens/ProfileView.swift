//
//  ProfileView.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 24/6/25.
//

import SwiftUI

struct ProfileView: View {
    @State private  var viewModel = ProfileViewModel()
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    BackgroundView(imageData: $viewModel.imageData, firstLastName: $viewModel.firstLastName, profession: $viewModel.profession)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    BiographyView(bioGraphy: $viewModel.biography)
                        .accessibilityLabel("Biography: \(viewModel.biography)")
                        .accessibilityHint("This biography has a 150 character maximum")
                    
                    HStack {
                        Image(systemName: "link")
                        Image(systemName: "paperplane")
                        Image(systemName: "network")
                        Image(systemName: "message")
                        Spacer()
                        
                        if viewModel.isCheckedIn {
                            Button {
                                Task {
                                    await  viewModel.checkOut()
                                }
                            } label: {
                                Label("Check Out", systemImage: "mappin.and.ellipse")
                            }
                            .buttonStyle(.borderedProminent)
                            .buttonBorderShape(.capsule)
                            .controlSize(.small)
                            .foregroundStyle(.black)
                            .tint(.myPrimary)
                            .accessibilityLabel("Check out of current location")
                        }
                    }
                    
                    .foregroundStyle(.myPrimary)
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 12)
                .padding(.horizontal)
                .offset(y: 130)
                if viewModel.showLoading {
                    LoadingView()
                }
            }
            .task {
                await viewModel.initializeUserRecord()
                await viewModel.loadProfile()
                await viewModel.getCheckedInStatus()
            }
            .alert(viewModel.invalidCredentials? .title ?? "Invalid Profile", isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {}
                
            } message: {
                Text(viewModel.invalidCredentials? .message ?? "An error occurred while saving your profile. \n Please try again later.")
            }
            .navigationBarTitle("Profile", displayMode: .inline)
            Button(viewModel.lastProfileAction == .created ? "Update profile" : "Create profile") {
                Task {
                    await viewModel.createProfile()
                }
            }
            .frame(width: 150, height: 40)
            .background(.myPrimary)
            .foregroundStyle(.black)
            .fontWeight(.semibold)
            .clipShape(.capsule)
            .padding(.vertical, 10)
            .shadow(radius: 5)
        }
    }
}

#Preview {
    ProfileView()
}

struct BackgroundView: View {
    @Binding var imageData: Data?
    @Binding var firstLastName: String
    @Binding var profession: String
    var body: some View {
        Color.black
            .frame(height: 220)
            .overlay(
                HStack(spacing: 12) {
                    AddPhotoView(imageData: $imageData)
                        .padding(.leading)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel("Profile Photo")
                        .accessibilityHint("Open photo library to choose a photo")
                    VStack(alignment: .leading) {
                        TextField("", text: $firstLastName)
                            .customPlaceholder("First & Last Name", text: $firstLastName, weight: .bold)
                            .accessibilityLabel("First & Last name")
                        TextField("", text: $profession)
                            .customPlaceholder("Profession", text: $profession, textColor: .white.opacity(0.6))
                            .accessibilityLabel("Profession")
                        Image(systemName: "square.and.pencil")
                            .foregroundStyle(.white)
                            .offset(x: -72,y: 8)
                        
                    }
                }
                    .padding(.top, -80)
            )
    }
}

struct BiographyView: View {
    @Binding var bioGraphy: String
    private let bioMaxCharacters = 150
    var body: some View {
        Text("Biography: ").foregroundStyle(.black) +
        Text("\(150 - bioGraphy.count)").foregroundStyle(.myPrimary) +
        Text(" Characters remaining...")
            .foregroundStyle(.black)
        TextEditor(text: $bioGraphy)
            .frame(height: 80)
            .scrollContentBackground(.hidden)
            .foregroundStyle(.black)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 0)
            )
            .onChange(of: bioGraphy) {
                if bioGraphy.count > bioMaxCharacters {
                    bioGraphy = String(bioGraphy.prefix(bioMaxCharacters))
                }
                
            }
        
    }
    
    
}
