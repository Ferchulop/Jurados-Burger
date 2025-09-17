//
//  LocationMapView.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 24/6/25.
//

import SwiftUI
import MapKit
struct LocationMapView: View {
    
    @Environment(LocationManager.self) private var locationManager
    @State private  var viewModel = LocationMapViewModel()
    var body: some View {
        ZStack {
            Map(initialPosition: viewModel.cameraPosition) {
                
                UserAnnotation()
                
                ForEach(locationManager.locations) { location in
                    
                    Annotation("", coordinate: location.location.coordinate ) {
                        MapLocationView(location: location, numberOfPeople: viewModel.checkedInCounts[location.id, default: 0])
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Map showing \(locationManager.locations.count) Jurado's Burger locations")
            .mapStyle(viewModel.mapStyle)
            
            
            VStack {
                HStack {
                    Spacer()
                    MapStyleButton(viewModel: viewModel)
                        .padding(.horizontal, 5)
                        .padding(.top,480)
                }
                
            }
        }
        
        .ignoresSafeArea(edges:[.leading, .trailing, .bottom])
        
        .alert(viewModel.showingError? .title ?? "Error", isPresented: $viewModel.unableLocation) {
            Button("OK", role: .cancel) {}
            
        } message: {
            Text(viewModel.showingError? .message ?? "An error occurred while fetching the location")
        }
        .fullScreenCover(isPresented: $viewModel.isShowOnBoarding) {
            OnBoardingInfoView()
                .task {
                    try? await Task.sleep(for: .seconds(10))
                    viewModel.isShowOnBoarding = false
                    viewModel.markOnboardingAsSeen()
                }
        }
        .task {
            await viewModel.fetchCheckedInCounts()
            await viewModel.fetchLocations(locationManager: locationManager)
            
        }
    }
}

#Preview {
    LocationMapView()
        .environment(LocationManager())
}

struct BurguerLogoView: View {
    var body: some View {
        Image(.juradoSBurguerLogo)
            .resizable()
            .scaledToFit()
            .frame(height: 100)
            .padding(60)
            .shadow(radius: 20)
    }
}


struct MapLocationView: View {
    var location: JuradosLocation
    var numberOfPeople: Int
    var body: some View {
        VStack(spacing: -8) {
            ZStack {
                
                Image(.juradosburguerMap3)
                    .resizable()
                    .frame(width: 60, height: 90)
                    .shadow(radius: 10)
                
                
                if numberOfPeople > 0 {
                    Text("\(numberOfPeople)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        .padding(6)
                        .background(Circle().fill(Color(.myPrimary)))
                        .offset(x: -12, y: 18)
                        .transition(.scale)
                        .animation(.easeInOut, value: numberOfPeople)
                }
            }
            
            Text(location.name)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 2)
        }
    }
}

struct MapStyleButton: View {
    let viewModel: LocationMapView.LocationMapViewModel
    @State private var isLocating = false
    
    var mapIcon: String {
        switch viewModel.currentMode {
        case .standard:
            return "map"
        case .hybrid:
            return "map.fill"
        case .realistic:
            return "globe.americas.fill"
        }
    }
    
    var body: some View {
        Button {
            viewModel.toggleMapMode()
        } label: {
            Image(systemName: mapIcon)
                .font(.title2)
                .foregroundStyle(.white)
                .padding(12)
                .background(Circle().fill(Color.black.opacity(0.7)))
                .shadow(radius: 4)
        }
        .accessibilityLabel("Change map style")
        .accessibilityHint("Currently showing \(viewModel.currentMode) map")
    }
}

