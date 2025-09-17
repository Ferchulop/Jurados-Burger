//
//  LocationManager.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 10/7/25.
//

import Foundation
import CloudKit

// MARK: - Location Manager
/// Gestor con la macro `@Observable` para ubicaciones y datos relaciones de Jurado's Burger.
///
///`LocationManager` manejará  todas las ubicaciones de la aplicación, su carga inicial, actualización de datos y  seguimiento del estado de carga. Proporcionará  actualizaciones automáticas a la UI.
///
/// - Important: Utiliza `@MainActor` para garantizar que las actualizaciones de UI ocurran en el hilo principal.
/// - Note: Los datos se cargan automáticamente en el inicializador usando `Task`.

@Observable
final class LocationManager {
    
    var locations: [JuradosLocation] = []
    var checkedInCounts: [CKRecord.ID: Int] = [:]
    var hasLoadedInitialData = false
    var errorMessage: String?
    
    init() {
        
        Task {
            await loadAllData()
        }
    }
    
    /// Este método carga todos los datos necesarios desde CloudKit.
    ///
    /// Centralizará la lógica de carga, obteniendo ubicaciones,
    /// conteos de usuarios y configurando el estado del usuario actual.
    /// Implementa un sistema de caché para evitar cargas innecesarias.
    ///
    /// ## Proceso de carga
    /// 1. Verifica si ya se cargaron los datos iniciales
    /// 2. Obtiene el registro de usuario si no existe.
    /// 3. Carga todas las ubicaciones.
    /// 4. Obtiene conteos actualizados de usuarios por ubicación.
    /// 5. Actualiza los estados correspondientes.
    @MainActor
    func loadAllData() async {
        guard !hasLoadedInitialData else { return }
        
        errorMessage = nil
        
        do {
            
            if CloudKitManager.shared.userRecord == nil {
                try await CloudKitManager.shared.getUserRecord()
            }
            
            
            let fetchedLocations = try await CloudKitManager.shared.getLocation()
            
            self.locations = fetchedLocations
            self.checkedInCounts = try await CloudKitManager.shared.getCheckedInCounts()
            hasLoadedInitialData = true
            
        } catch {
            errorMessage = "Error loading locations: \(error.localizedDescription)"
            print("❌ Error loading initial data: \(error)")
        }
    }
}


