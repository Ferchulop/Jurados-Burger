//
//  LoadingView.swift
//  Jurado's Burger
//
//  Created by Fernando Jurado on 26/7/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack{
            Color(.systemBackground)
                .opacity(0.8)
                .ignoresSafeArea()
            
            ProgressView()
                .tint(.myPrimary)
                .scaleEffect(4)
        }
    }
}

#Preview {
    LoadingView()
}
