//
//  LocationListView-ViewModel.swift
//  Jurado's Burger
//
//  Created by Fernando Jurado on 4/8/25.
//

import Foundation
import CloudKit

// MARK: - LocationListView - ViewModel
extension LocationListView {
    
    /// ViewModel  con la macro `@Observable` para la gestión de la lista principal de ubicaciones.
    ///
    /// `LocationListViewModel` se encarga de coordinar los datos de todas las ubicaciones de Jurado's Burger con sus respectivos usuarios registrados, proporcionando una vista consistente
    ///  para la interfaz de lista principal.
    ///
    /// ## Integración con LocationManager
    /// Trabaja complementariamente con `LocationManager`:
    /// - `LocationManager`: Maneja ubicaciones y conteos.
    /// - `LocationListViewModel`: Maneja perfiles detallados por ubicación.
    @Observable @MainActor
    final class LocationListViewModel {
        
        var checkedInProfiles: [CKRecord.ID: [JuradosProfile]] = [:]
        var alertMessage: String?
        
        
        /// Este método obtiene y actualiza los perfiles registrados para todas las ubicaciones.
        ///
        /// Realiza una consulta consolidada a CloudKit para obtener todos los usuarios que están actualmente registrados en cualquier ubicación de Jurado's Burger, orgnizándolos por ubicación en el
        /// en el diccionario `checkedInProfiles`.
        ///
        /// ## Proceso de actualización
        /// 1. Consulta CloudKit usando `getCheckedInProfilesDictionary()`
        /// 2. Recibe un diccionario ya estructurado con perfiles por ubicación
        /// 3. Actualiza `checkedInProfiles` con los datos frescos
        /// 4. En caso de error, configura `alertMessage` con información descriptiva
        ///
        /// - Important: Automáticamente maneja errores sin lanzar excepciones.
        /// - Note: La operación se maneja en el hilo principal gracias a `@MainActor` en la clase.
        /// - Warning: En caso de error, los datos existentes se mantienen intactos.
        func getCheckedInProfiles() async {
            
            do {
                let dictionary = try await CloudKitManager.shared.getCheckedInProfilesDictionary()
                checkedInProfiles = dictionary
                
            } catch {
                
                alertMessage = "Error fetching checked in profiles: \(error.localizedDescription)"
            }
        }
    }
}
