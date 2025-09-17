//
//  CloudKitManager.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 7/7/25.
//

import Foundation
import CloudKit

// MARK: - CloudKitManager
/// Gestor que centralizará todas las operaciones de CloudKit en la app.
///
/// `CloudKitManager` unifica la interfaz para poder interactuar con CloudKit. Proporcionando gestión de perfiles de usuarios, operaciones CRUD y otras consultas.
/// - Important: Todas las operaciones son asíncronas, y pueden lanzar errores de CloudKit.
/// - Note: Cachea `userRecord` en memoria para mejorar el rendimiento.

final class CloudKitManager {
    
    /// Tipos de registros utilizados en CloudKit.
    ///
    /// Centralizará todos los tipos de registros para evitar inconsistencias y facilitar así su mantenimiento.
    enum RecordType {
        /// Tipo de registro para ubicaciones de Jurado's Burger.
        static let location = "JuradosLocation"
    }
    
    static  let shared    = CloudKitManager()
    private let container = CKContainer.default()
    private let publicDB  =  CKContainer.default().publicCloudDatabase
    var userRecord: CKRecord?
    
    /// ID del registro de perfil del usuario actual.
    ///
    /// Implementa una estrategia de caché híbrida:
    /// 1. Primero intenta obtener en `UserDefaults` para un acceso rápido
    /// 2. Si no está disponible, busca en `userRecord` como fallback
    /// 3. Guarda automáticamente en `UserDefaults` cuando lo encuentra
    ///
    /// - Returns: El `CKRecord.ID` del perfil del usuario o `nil` si no está disponible.
    /// - Note: Optimiza el rendimiento cacheando el ID en `UserDefaults`.
    var profileRecordID: CKRecord.ID? {
        
        if let recordName = UserDefaults.standard.string(forKey: "userProfileID") {
            print("✅ ProfileID recuperado de UserDefaults: \(recordName)")
            return CKRecord.ID(recordName: recordName)
        }
        
        if let reference = userRecord?["userProfile"] as? CKRecord.Reference {
            UserDefaults.standard.set(reference.recordID.recordName, forKey: "userProfileID")
            return reference.recordID
        }
        
        return nil
    }
    
    private init() {}
    
    /// Este método obtiene y cachea el registro actual del usuario.
    ///
    /// Recupera el registro del usuario asociado con el móvil actual y lo almacena en `userRecord` para su uso posterior.
    ///
    /// - Throws: Errores de CloudKit si la operación falla.
    /// - Important: Debe llamarse antes de usar funcionalidades que dependan de `userRecord`.
    func getUserRecord() async throws {
        let recordID    = try await container.userRecordID()
        let record      = try await publicDB.record(for: recordID)
        self.userRecord = record
        
    }
    
    /// Este método obtiene todos los perfiles que están registrados en una ubicación específica.
    ///
    /// Buscará perfiles que tengan una referencia activa a la ubicación que se de, indicando que esta "checked-in" en esa ubicación.
    ///
    /// - Parameters:
    ///     - locationRecordID:  ID de la ubicación a consultar.
    ///
    /// - Returns: Array de perfiles que están en la ubicación especificada.
    /// - Throws: Errores de Cloudkit si falla la consulta.
    func getCheckedInProfiles(for locationRecordID: CKRecord.ID) async throws -> [JuradosProfile] {
        let reference = CKRecord.Reference(recordID: locationRecordID, action: .none)
        let predicate = NSPredicate(format: "%K == %@", JuradosProfile.keyisHere, reference)
        let query = CKQuery(recordType: "JuradosProfile", predicate: predicate)
        
        return try await withCheckedThrowingContinuation { continuation in
            publicDB.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let (matchResults, _)):
                    var profiles: [JuradosProfile] = []
                    
                    for (_, matchResult) in matchResults {
                        switch matchResult {
                        case .success(let record):
                            let profile = JuradosProfile(record: record)
                            profiles.append(profile)
                        case .failure(let error):
                            print("Profile error fetching: \(error.localizedDescription)")
                        }
                    }
                    
                    continuation.resume(returning: profiles)
                }
            }
        }
    }
    /// Este método obtiene un contador de usuarios registrados por ubicación.
    ///
    /// Devuelve un diccionario donde cada ID de ubicación es el número de usuarios que actualmente están registrados en esa ubicación.
    ///
    /// - Returns: Diccionario de conteos de usuarios por ubicación.
    /// - Throws: Errores de CloudKit si la consulta falla.
    func getCheckedInCounts() async throws -> [CKRecord.ID: Int] {
        let predicate = NSPredicate(format: "%K == 1", JuradosProfile.keyisHereNil)
        let query = CKQuery(recordType: "JuradosProfile", predicate: predicate)
        
        return try await withCheckedThrowingContinuation { continuation in
            publicDB.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let (matchResults, _)):
                    var counts: [CKRecord.ID: Int] = [:]
                    for (_, matchResult) in matchResults {
                        if case let .success(record) = matchResult,
                           let reference = record[JuradosProfile.keyisHere] as? CKRecord.Reference {
                            counts[reference.recordID, default: 0] += 1
                        }
                    }
                    continuation.resume(returning: counts)
                }
            }
        }
    }
    
    /// Este método obtiene perfiles agrupados por ubicación.
    ///
    /// Devuelve un diccionario donde cada ID de ubicación es un valor de array de todos los perfiles registrados en esa ubicación.
    ///
    /// - Returns: Diccionario con arrays de perfiles agrupados por ubicación.
    /// - Throws: Errores de Cloudkit si la consulta falla.
    func getCheckedInProfilesDictionary() async throws -> [CKRecord.ID: [JuradosProfile]] {
        let predicate = NSPredicate(format: "%K == 1", JuradosProfile.keyisHereNil)
        let query = CKQuery(recordType: "JuradosProfile", predicate: predicate)
        
        return try await withCheckedThrowingContinuation { continuation in
            publicDB.fetch(withQuery: query, inZoneWith: nil, desiredKeys: nil, resultsLimit: CKQueryOperation.maximumResults) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let (matchResults, _)):
                    var dictionary: [CKRecord.ID: [JuradosProfile]] = [:]
                    
                    for (_, matchResult) in matchResults {
                        if case let .success(record) = matchResult {
                            let profile = JuradosProfile(record: record)
                            if let reference = record[JuradosProfile.keyisHere] as? CKRecord.Reference {
                                dictionary[reference.recordID, default: []].append(profile)
                            }
                        }
                    }
                    
                    continuation.resume(returning: dictionary)
                }
            }
        }
    }
    
    /// Este método obtiene todas las ubicaciones de Jurado's Burger.
    ///
    /// Recupera todas las ubicaciones disponibles y las muestra.
    ///
    /// - Returns: Array de ubicaciones.
    /// - Throws: Errores de CloudKit si la consulta falla.
    func getLocation() async throws -> [JuradosLocation] {
        let sortDescriptor = NSSortDescriptor(key: JuradosLocation.keyName, ascending: true)
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: RecordType.location, predicate: predicate)
        query.sortDescriptors = [sortDescriptor]
        
        return try await withCheckedThrowingContinuation { continuation in
            publicDB.fetch(withQuery: query,inZoneWith: nil,desiredKeys: nil,resultsLimit: CKQueryOperation.maximumResults) { result in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                    
                case .success(let (matchResults, _)):
                    var locations: [JuradosLocation] = []
                    
                    for (_, matchResult) in matchResults {
                        switch matchResult {
                        case .success(let record):
                            let location = JuradosLocation(record: record)
                            locations.append(location)
                        case .failure(let error):
                            print(error.localizedDescription)
                            
                        }
                    }
                    
                    continuation.resume(returning: locations)
                }
            }
        }
    }
    
    /// Este método guarda múltiples registros en una sola operación.
    ///
    /// Utiliza `CKModifyRecordsOperation` para guardar varios registros de manera eficiente en una sola operación.
    ///
    /// - Parameters:
    ///     - records: Array de registros de CloudKit para guardar.
    /// - Throws: Errores de CloudKit si la operación falla.
    /// - Important: Si fallase la operación no se guardaría ningún registro.
    /// - Note: Actualizará automáticamente `userRecord` si se incluyese un registro de tipo "Users".
    func saveMultipleRecords(records: [CKRecord]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let operation = CKModifyRecordsOperation(recordsToSave: records)
            operation.savePolicy = .allKeys
            
            
            operation.modifyRecordsResultBlock = { result in
                switch result {
                case .success:
                    print("Successfully saved records")
                    
                    for record in records {
                        if record.recordType == "Users" {
                            self.userRecord = record
                            print("✅ UserRecord actualizado en memoria")
                        }
                    }
                    continuation.resume()
                case .failure(let error):
                    print("Failed to save records, error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
            
            
            publicDB.add(operation)
            
        }
        
    }
    
    /// Este método guarda un registro individual en CloudKit.
    ///
    /// - Parameters:
    ///     - record: El registro de CloudKit a guardar.
    /// - Returns: El registro guardado con metadatos actualizados.
    /// - Throws: Errores de CloudKit si la operación falla.
    func save(record: CKRecord) async throws -> CKRecord {
        try await publicDB.save(record)
    }
    
    /// Obtiene un registro específico por su ID.
    ///
    /// Recuperará un registro individual usando su identificacor único.
    ///
    /// - Parameters:
    ///     - id: El ID del registro a obtener.
    /// - Returns: El registro de CloudKit correspondiente.
    /// - Throws: Errores de CloudKit si el registro no existiese o fallase la operación.
    func fetchRecord(with id: CKRecord.ID) async throws -> CKRecord {
        return try await publicDB.record(for: id)
    }
}

