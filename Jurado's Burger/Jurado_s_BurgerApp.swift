//
//  Jurado_s_BurguerApp.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 24/6/25.
//

import SwiftUI
import CloudKit

@main
struct Jurado_s_BurgerApp: App {
    
    var body: some Scene {
        @State var locationManager = LocationManager()
        
        WindowGroup {
            CustomTabView()
                .environment(locationManager)
                .task {
                    await locationManager.loadAllData()
                }
        }
    }
}



