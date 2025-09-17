//
//  LocationDetailView-ViewModel.swift
//  Jurado's Burger
//
//  Created by Fernando Jurado on 28/7/25.
//

import Foundation
import SwiftUI
import MapKit
import CloudKit

// MARK: - LocationDetailView - ViewModel
extension LocationDetailView {
    
    enum CheckInStatus { case checkedIn, checkedOut }
    
    /// ViewModel  con la macro `@Observable` para la gestión completa de detalles de ubicación.
    ///
    /// `LocationDetailViewModel` maneja toda la funcionalidad relacionada con una ubicación específica de Jurado's Burger, incluyendo check-in/check-out, navegación con mapas, llamadas
    ///  telefónicas y gestión de perfiles presentes.
    ///
    ///
    /// ## Funcionalidades principales
    /// - Check-in/Check-out en ubicaciones con sincronización CloudKit.
    /// - Navegación integrada con Apple Maps.
    /// - Llamadas telefónicas directas desde la app.
    /// - Lista en tiempo real de usuarios presentes en la ubicación.
    /// - Manejo robusto de errores con alertas informativas.
    @Observable
    final class LocationDetailViewModel {
        let columns     = [ GridItem(.adaptive(minimum: 50), spacing: 40)]
        var isCheckedIn = false
        var checkedInProfiles: [JuradosProfile] = []
        var location: JuradosLocation
        var unableToCheckIn: AlertPopUp?
        var unableProfile = false
        
        init(location: JuradosLocation) {
            self.location = location
        }
        
        /// Este método abre Apple Maps con direcciones sugiriendo varias elecciones para ir hacia la ubicación.
        ///
        /// Crea un `MKMapItem` con las coordenadas de la ubicación y lo abre en la app de Maps con direcciones sugiriendo varias elecciones para ir preconfiguradas.
        ///
        /// ```swift
        /// Button("Get Directions") {
        ///     viewModel.navigateToLocationInMaps()
        /// }
        /// ```
        ///
        /// ## Funcionalidad
        /// - Crea un placemark con las coordenadas exactas.
        /// - Configura el nombre de la ubicación en Maps.
        /// - Lanza Maps con modo de direcciones.
        ///
        /// - Note: Utiliza `MKLaunchOptionsDirectionsModeWalking` para optimizar rutas peatonales.
        /// - Important: Requiere que el dispositivo tenga la app Maps instalada.
        func navigateToLocationInMaps() {
            let coordinate = location.location.coordinate
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = location.name
            
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
            ])
        }
        
        /// Este método inicia una llamada telefónica al número de la ubicación.
        ///
        /// Valida el número de teléfono, verifica la capacidad del dispositivo para realizar llamadas y ejecuta la llamada con manejo de errores.
        ///
        /// ```swift
        /// Button("Call Location") {
        ///     viewModel.callLocationNumber()
        /// }
        /// ```
        ///
        /// ## Proceso de validación
        /// 1. Construye la URL telefónica con formato `tel://`.
        /// 2. Verifica que la URL sea válida.
        /// 3. Confirma que el dispositivo pueda abrir URLs de llamada.
        /// 4. Ejecuta la llamada con completion handler.
        ///
        /// - Important: Solo funciona en dispositivos con capacidad de llamadas (no en simulador).
        /// - Note: Incluye logging detallado para debugging de errores.
        func callLocationNumber() {
            guard let phoneURL = URL(string: "tel://\(location.phone)") else {
                print("🚫 Error: Número de teléfono inválido.")
                return
            }
            
            guard UIApplication.shared.canOpenURL(phoneURL) else {
                print("🚫 Error: No se puede abrir la URL de llamada.")
                return
            }
            
            
            UIApplication.shared.open(phoneURL, options: [:]) { success in
                if success {
                    print("✅ Llamada iniciada con éxito.")
                } else {
                    print("🚫 Error: No se pudo iniciar la llamada.")
                }
            }
        }
        
        /// Este método obtiene el estado actual de check-in del usuario para la ubicación.
        ///
        /// Consulta CloudKit para determinar si el usuario actual está registrado en esta ubicación específica, actualizando `isCheckedIn`.
        ///
        /// ## Lógica de verificación
        /// 1. Obtiene el ID del perfil del usuario actual.
        /// 2. Busca el registro del perfil en CloudKit.
        /// 3. Verifica si la referencia de ubicación coincide con la ubicación.
        /// 4. Actualiza `isCheckedIn` basándose en el resultado.
        @MainActor
        func getCheckedInStatus() async {
            guard let profileRecordID = CloudKitManager.shared.profileRecordID else { return }
            
            do {
                let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                if let reference = record[JuradosProfile.keyisHere] as? CKRecord.Reference {
                    isCheckedIn = reference.recordID == location.id
                } else {
                    isCheckedIn = false
                }
            } catch {
                unableToCheckIn = .unableToGetCheckinStatus
            }
        }
        
        /// Este método actualiza el estado de check-in del usuario en CloudKit.
        ///
        /// Modifica el registro del usuario en CloudKit para reflejar su nuevo estado de presencia en la ubicación, y actualiza la lista local de perfiles.
        ///
        /// ```swift
        /// Button(viewModel.isCheckedIn ? "Check Out" : "Check In") {
        ///     await viewModel.updateCheckInStatus(
        ///         to: viewModel.isCheckedIn ? .checkedOut : .checkedIn
        ///     )
        /// }
        /// ```
        ///
        /// ## Proceso para Check-In
        /// 1. Crea una referencia a la ubicación actual.
        /// 2. Establece `keyisHereNil` en 1.
        /// 3. Añade el perfil a la lista local de usuarios presentes.
        ///
        /// ## Proceso para Check-Out
        /// 1. Remueve la referencia de ubicación (devuelve nil).
        /// 2. Limpia `keyisHereNil` (devuelve nil).
        /// 3. Elimina el perfil de la lista local.
        ///
        /// - Parameters:
        ///     - checkInStatus: El nuevo estado deseado (`.checkedIn` o `.checkedOut`).
        ///
        /// - Important: Actualiza tanto CloudKit como el estado local de manera automática.
        /// - Note: Incluye manejo robusto de errores con alertas específicas.
        @MainActor
        func updateCheckInStatus(to checkInStatus: CheckInStatus) async {
            guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
                unableToCheckIn = .unableToGetProfile
                return
            }
            
            do {
                let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                
                switch checkInStatus {
                case .checkedIn:
                    record[JuradosProfile.keyisHere] = CKRecord.Reference(recordID: location.id, action: .none)
                    record[JuradosProfile.keyisHereNil] = 1
                case .checkedOut:
                    record[JuradosProfile.keyisHere] = nil
                    record[JuradosProfile.keyisHereNil] = nil
                }
                
                let savedRecord = try await CloudKitManager.shared.save(record: record)
                let profile = JuradosProfile(record: savedRecord)
                
                switch checkInStatus {
                case .checkedIn:
                    checkedInProfiles.append(profile)
                case .checkedOut:
                    checkedInProfiles.removeAll { $0.id == profile.id }
                }
                
                isCheckedIn = checkInStatus == .checkedIn
                
                
            } catch {
                unableToCheckIn = .unableToCheckInOrCheckOut
            }
        }
        
        /// Este método actualiza tanto el estado de check-in como la lista de perfiles.
        ///
        /// Combina la verificación del estado del usuario y la carga de todos los perfiles presentes en la ubicación.
        ///
        /// - Important: Ejecuta ambas operaciones secuencialmente para datos consistentes.
        /// - Note: Es útil para refrescar completamente la vista después de cambios.
        @MainActor
        func refreshProfiles() async {
            await getCheckedInStatus()
            await getCheckedInProfiles()
        }
        
        /// Este método obtiene la lista actualizada de perfiles presentes en la ubicación.
        ///
        /// Consulta CloudKit para obtener todos los usuarios que están actualmente registrados en la ubicación específica.
        ///
        /// - Important: Actualiza `checkedInProfiles` con la información más reciente.
        /// - Note: Maneja errores configurando la alerta apropiada automáticamente.
        @MainActor
        func getCheckedInProfiles() async {
            do {
                let profiles = try await CloudKitManager.shared.getCheckedInProfiles(for: location.id)
                checkedInProfiles = profiles
            } catch {
                unableToCheckIn = .unableToGetProfile
            }
        }
    }
    
}

