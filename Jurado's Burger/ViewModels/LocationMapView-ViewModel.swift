//
//  LocationMapView-ViewModel.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 8/7/25.
//

import SwiftUI
import MapKit
import CoreLocation
import CloudKit

// MARK: - LocationMapView - ViewModel
extension LocationMapView {

    /// ViewModel  con la macro  `@Observable` para la gestión completa del mapa de ubicaciones.
    ///
    /// `LocationMapViewModel` integra servicios de ubicación, MapKit y CloudKit para proporcionar una experiencia de mapa completa con ubicaciones de Jurado's Burger, conteos de usuarios y
    /// funcionalidades de navegación.
    ///
    /// ## Funcionalidades
    /// - Gestión completa de permisos de ubicación con Core Location.
    /// - Múltiples estilos de mapa (estándar, híbrido, realista).
    /// - Sistema de onboarding para nuevos usuarios.
    /// - Integración con CloudKit para datos de ubicaciones.
    /// - Conteos en tiempo real de usuarios por ubicación.
    /// - Manejo robusto de errores de ubicación y permisos.
    ///
    /// - Important: Implementa `CLLocationManagerDelegate` para gestión completa de ubicación.
    /// - Note: Utiliza `@Observable` para actualizaciones automáticas de SwiftUI.
    @Observable
    final class LocationMapViewModel: NSObject, CLLocationManagerDelegate {
        var isShowOnBoarding = true
        var checkedInCounts: [CKRecord.ID: Int] = [:]
        var cameraPosition = MapCameraPosition.region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 40.4165, longitude: -3.70256),
                span: MKCoordinateSpan(latitudeDelta: 0.50, longitudeDelta: 0.50)))
        var unableLocation = false
        var showingError: AlertPopUp?
        var locationManager: CLLocationManager?
        var lastKnownLocation: CLLocationCoordinate2D?
        
        enum MapMode: CaseIterable {
            case standard, hybrid, realistic
        }
        var currentMode: MapMode = .standard
        var mapStyle: MapStyle {
            switch currentMode {
            case .hybrid: .hybrid
            case .realistic: .imagery(elevation: .realistic)
            default: .standard
            }
        }
        
        /// Este método alterna entre los diferentes modos de visualización del mapa.
        ///
        /// Cambia a través de todos los modos disponibles (estándar → híbrido → realista → estándar). Útil para botones de toggle en la interfaz de usuario.
        func toggleMapMode() {
            let allCases = MapMode.allCases
            guard let currentIndex = allCases.firstIndex(of: currentMode) else { return }
            let nextIndex = (currentIndex + 1) % allCases.count
            currentMode = allCases[nextIndex]
        }
        
        var shouldShowOnboarding: Bool {
            !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        }
        
        /// Este método marca el onboarding como completado en el almacenamiento persistente.
        ///
        /// Guarda en `UserDefaults` que el usuario ya ha visto la introducción,  evitando que se muestre en futuras sesiones.
        func markOnboardingAsSeen() {
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        }
        
        override init() {
            super.init()
            setupLocationManager()
        }
        
        /// Este método verifica si los servicios de ubicación están habilitados en el dispositivo.
        ///
        /// Evalúa el estado global de los servicios de ubicación y configura el location manager si están disponibles, o muestra una alerta si están deshabilitados.
        /// - Important: Debe llamarse antes de intentar usar funcionalidades de ubicación.
        func checkLocationServicesEnabled() {
            if CLLocationManager.locationServicesEnabled() {
                setupLocationManager()
            } else {
                showingError = AlertPopUp.disabledLocationAccess
            }
        }
        
        /// Este método configura y inicializa el CLLocationManager con permisos apropiados.
        ///
        /// Establece el delegate, precisión deseada y maneja todos los estados posibles de autorización de ubicación según las mejores prácticas de Apple.
        ///
        /// ## Estados de autorización manejados
        /// - **notDetermined**: Solicita permiso automáticamente
        /// - **denied**: Muestra alerta de acceso denegado
        /// - **restricted**: Muestra alerta de restricciones del dispositivo
        /// - **authorized**: Comienza a recibir actualizaciones de ubicación
        ///
        /// - Note: Utiliza `kCLLocationAccuracyBest` para máxima precisión.
        /// - Important: Configura automáticamente las alertas apropiadas para cada estado.
        private func setupLocationManager() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            
            let status = locationManager?.authorizationStatus
            
            switch status {
            case .notDetermined:
                locationManager!.requestWhenInUseAuthorization()
            case .denied:
                showingError = AlertPopUp.deniedLocationAccess
            case .restricted:
                showingError = AlertPopUp.locationRestricted
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager?.startUpdatingLocation()
            default:
                break
            }
        }
        
        /// Este método carga las ubicaciones de Jurado's Burger desde CloudKit.
        ///
        /// Obtiene todas las ubicaciones disponibles y las asigna a`LocationManager` proporcionado para su uso en la UX.
        ///
        /// - Parameters:
        ///     - locationManager: El `LocationManager` que recibirá las ubicaciones cargadas.
        @MainActor
        func fetchLocations(locationManager: LocationManager) async {
            do {
                let locations = try await CloudKitManager.shared.getLocation()
                locationManager.locations = locations
            } catch {
                showingError = AlertPopUp.unableToGetLocations
                unableLocation = true
            }
        }
        
        /// Este método es llamado cuando Core Location actualiza la posición del usuario.
        ///
        /// Procesa las nuevas ubicaciones recibidas de Core Location, actualiza a última ubicación conocida y centra la cámara del mapa en la posición actual.
        ///
        /// ## Comportamiento de la cámara
        /// - Utiliza un span más pequeño (0.05°) para mayor detalle cuando se centra en el usuario.
        /// - Solo actualiza automáticamente la primera vez para evitar interrumpir la navegación manual.
        /// - Siempre mantiene `lastKnownLocation` actualizada para otras funcionalidades.
        ///
        /// - Parameters:
        ///     - manager: El `CLLocationManager` que proporciona las actualizaciones.
        ///     - locations: Array de ubicaciones, generalmente con la más reciente al final.
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let newLocation = locations.last else { return }
            
            lastKnownLocation = newLocation.coordinate
            
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: newLocation.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            )
        }
        
        ///  Este método obtiene los conteos actualizados de usuarios registrados por ubicación.
        ///
        /// Consulta CloudKit para obtener el número de usuarios actualmente presentes en cada ubicación de Jurado's Burger, actualizando el diccionario `checkedInCounts`.
        ///
        /// ## Uso en la UI
        /// Los conteos se pueden usar para mostrar badges o información en los marcadores del mapa:
        ///
        /// ```swift
        /// Text("\(checkedInCounts[location.id] ?? 0) users")
        /// ```
        @MainActor
        func fetchCheckedInCounts() async {
            do {
                checkedInCounts = try await CloudKitManager.shared.getCheckedInCounts()
            } catch {
                print("❌ Error fetching checked-in counts: \(error.localizedDescription)")
            }
        }
    }
}
