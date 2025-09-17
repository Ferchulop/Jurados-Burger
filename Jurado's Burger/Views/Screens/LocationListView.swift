//
//  LocationListView.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 24/6/25.
//

import SwiftUI

struct LocationListView: View {
    
    @Environment(LocationManager.self) private var locationManager
    @State private var viewModel = LocationListViewModel()
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(locationManager.locations) { location in
                    NavigationLink(destination: LocationDetailView(location: location)) {
                        LocationRow(location: location, checkedInProfiles: viewModel.checkedInProfiles[location.id] ?? [])
                    }
                }
            }
            .navigationTitle("Burgers Locations")
            .task {
                await viewModel.getCheckedInProfiles()
            }
        }
    }
}

struct AvatarView: View {
    var imageData: Data?
    var size: CGFloat
    var body: some View {
        Group {
            if let data = imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(.avatarPreview)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}

struct LocationRow: View {
    var location: JuradosLocation
    var checkedInProfiles: [JuradosProfile]
    
    var body: some View {
        HStack {
            if location.avatarAsset != nil {
                Image(uiImage: location.createAvatarImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
            } else {
                Image(.juradoSBurguerLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
            
            VStack(alignment:.leading) {
                Text(location.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.90)
                
                if checkedInProfiles.isEmpty {
                    Text("Nobody is here yet!")
                        .padding(.vertical, 1)
                        .foregroundStyle(.secondary)
                    
                } else {
                    
                    HStack {
                        ForEach(checkedInProfiles.prefix(3), id: \.id) { profile in
                            AvatarView(imageData: profile.avatarData, size: 35)
                        }
                        if checkedInProfiles.count > 3  {
                            AddLocationProfileRow(number: checkedInProfiles.count - 3)
                            
                        }
                    }
                }
                
            }
            .padding(.leading)
        }
        .accessibilityElement(children:.ignore)
        .accessibilityLabel(checkedInProfiles.isEmpty ? "\(location.name). Nobody is here yet!" : "\(location.name) \(checkedInProfiles.count) \(checkedInProfiles.count == 1 ? "person" : "people")checked in")
        
    }
}

struct AddLocationProfileRow: View {
    
    var number: Int
    
    var body: some View {
        Text("+\(number)")
            .font(.system(size: 14, weight: .semibold))
            .frame(width: 35, height: 35)
            .foregroundStyle(.white)
            .background(Color.myPrimaryColor)
            .clipShape(Circle())
    }
    
}

