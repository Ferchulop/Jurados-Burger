//
//  sampleVIew.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 17/7/25.
//

import SwiftUI


struct OnBoardingInfoView: View {
    
    @Environment(\.dismiss) var dismiss
    
    struct ItemSymbol: Identifiable {
        let id = UUID()
        let icon: String
        let title: String
        let content: String
    }
    
    let items: [ItemSymbol] = [
        ItemSymbol(icon: "location.fill", title: "Find on Map", content: "See what’s cooking near you!"),
        ItemSymbol(icon: "building.2.crop.circle", title: "Burger Locations", content: "Find a place and flex your foodie status!"),
        ItemSymbol(icon: "person.circle.fill", title: "Profile", content: "Create your profile and connect with others."),
        ItemSymbol(icon: "cart.fill", title: "Buy", content: "Buy burgers and take it away with style.")
    ]
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(.myPrimary), location: 0.3),
                .init(color: Color(red: 0.690, green: 0.180, blue: 0.180), location: 0.3)], center: .top, startRadius: 200, endRadius: 590)
            
            VStack(spacing: -30) {
                Image(.juradoSBurguerLogo)
                    .resizable()
                    .scaledToFit()
                    .shadow(radius: 8)
                    .frame(width: 256, height: 256)
                
                Grid(alignment: .leading, verticalSpacing: 16) {
                    ForEach(items) { item in
                        GridRow {
                            Image(systemName: item.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48, height: 48)
                                .foregroundStyle(.myPrimary)
                            
                            VStack(alignment: .leading, spacing: 2.0) {
                                Text(item.title)
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                
                                Text(item.content)
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                }
                
            }
        }
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .padding()
                    .foregroundStyle(Color(red: 0.690, green: 0.180, blue: 0.180))
            }
        }
        
    }
}
#Preview {
    OnBoardingInfoView()
}
