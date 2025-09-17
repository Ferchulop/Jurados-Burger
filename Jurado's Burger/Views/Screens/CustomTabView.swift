//
//  CustomTabView.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 24/6/25.
//

import SwiftUI

struct CustomTabView: View {
    
    @State private var burgerViewModel =  BuyBurgerView.BuyBurgerViewModel()
    
    var body: some View {
        TabView {
            Tab("Map", systemImage: "map.circle") {
                LocationMapView()
            }
            Tab("Locations", systemImage: "building.2.crop.circle.fill") {
                LocationListView()
            }
            
            Tab("Profile",systemImage: "person.circle.fill") {
                ProfileView()
            }
            
            Tab("Buy",systemImage:"cart.circle") {
                BuyBurgerView()
                    .environment(burgerViewModel)
                
            }
            
            .badge(burgerViewModel.cartCount > 0 ? burgerViewModel.cartCount : 0)
            .accessibilityLabel("Buy, \(burgerViewModel.cartCount) \(burgerViewModel.cartCount == 1 ? "item" : "items") in cart")
            
        }
        .tint(.myPrimaryColor)
        .task {
            do {
                try await CloudKitManager.shared.getUserRecord()
            } catch {
                
                print(error.localizedDescription)
            }
            
        }
    }
}

#Preview {
    CustomTabView()
    
}
