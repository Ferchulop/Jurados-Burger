//
//  SampleData.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 7/7/25.
//

import Foundation
import CloudKit

#if DEBUG
// MARK: - SampleData
/// Datos de muestra para desarrollo y testing.
///
/// Proporciona datos ficticios estructurados para probar la funcionalidad de la app sin depender de CloudKit durante el desarrollo local.
///
/// ## Uso recomendado
/// ```swift
/// // En previews de SwiftUI
/// LocationDetailView(location: JuradosLocation(record: SampleData.location))
///
/// // En tests unitarios
/// let testProfile = JuradosProfile(record: SampleData.profile)
/// ```
///
/// - Important: Solo disponible en builds de DEBUG.
/// - Note: Los datos no reflejan información real de ubicaciones o usuarios.
struct SampleData {
    static var location: CKRecord {
        let record = CKRecord(recordType: "Location")
        record[JuradosLocation.keyName] = "Jurado's Burger"
        record[JuradosLocation.keyAddress] = "123 Gran Via Street, Madrid, Spain"
        record[JuradosLocation.keyDescription] = "Authentic Spanish Burgers. Made with the finest ingredients. More tasty than you can imagine!"
        record[JuradosLocation.keyPhone] = "34600123456"
        record[JuradosLocation.keyWebsite] = "https://www.juradosburger.es"
        record[JuradosLocation.keyLocation] = CLLocation(latitude: 40.416775, longitude: -3.70256)
        
        return record
        
    }
    
    static var profile: CKRecord {
        let record = CKRecord(recordType: "Profile")
        record[JuradosProfile.keyFullName] = "Fernando Jurado"
        record[JuradosProfile.keyProfession] = "Software Developer"
        record[JuradosProfile.keyBiography] = "I am a passionate software developer and a foodie."
        return record
    }
    /* static var locationManager: LocationManager {
     let manager = LocationManager()
     manager.locations = [JuradosLocation(record: SampleData.location)]
     return manager
     }*/
    
}
#endif
