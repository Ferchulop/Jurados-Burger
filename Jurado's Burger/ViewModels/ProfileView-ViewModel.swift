//
//  ProfileView-ViewModel.swift
//  Jurado's Burger
//
//  Created by Fernando Jurado on 22/7/25.
//
import Foundation
import CloudKit
import SwiftUI

// MARK: - ProfileView - ViewModel
extension ProfileView {
    
    /// ViewModel  con la macro `@bservable` para la gestión completa de perfiles de usuario.
    ///
    /// `ProfileViewModel` maneja todo el ciclo de vida del perfil del usuario, desde la creación inicial hasta actualizaciones, validaciones y gestión del estado de check-in. Integra CloudKit para
    /// persistencia y sincronización.
    ///
    /// ## Funcionalidades
    /// - Creación y actualización de perfiles.
    /// - Validación de datos de entrada.
    /// - Gestión de imágenes de perfil con conversión a CKAsset.
    /// - Sistema de check-in/check-out integrado
    /// - Carga automática de perfiles existentes.
    /// - Manejo de estados de UI (loading, alerts, errores).
    ///
    /// - Important: Utiliza `@Observable` para actualizaciones de la UI.
    /// - Note: Maneja automáticamente la persistencia del ID de perfil en UserDefaults.
    @Observable
    final class ProfileViewModel {
        var invalidCredentials: AlertPopUp?
        var firstLastName = ""
        var profession = ""
        var biography = ""
        var imageData: Data? = nil
        var showAlert = false
        var showLoading = false
        var isCheckedIn = false
        enum ProfileActionType { case created,updated }
        var lastProfileAction: ProfileActionType? = nil
        
        ///  Este método Inicializa y carga el registro de usuario de CloudKit si no existe.
        ///
        /// Verifica si ya existe un `userRecord` cacheado y, si no, lo obtiene desde CloudKit. También determina si el usuario ya tiene un perfil creado previamente.
        ///
        /// ## Proceso de inicialización
        /// 1. Verifica si `userRecord` ya está en memoria
        /// 2. Si no existe, lo obtiene desde CloudKit
        /// 3. Si encuentra un perfil existente, actualiza `lastProfileAction`
        /// 4. Maneja errores sin interrumpir la experiencia de usuario
        ///
        /// - Important: Debe llamarse antes de otras operaciones de perfil.
        /// - Note: Es seguro llamarla varias veces.
        func initializeUserRecord() async {
            guard CloudKitManager.shared.userRecord == nil
                    
            else {
                print("UserRecord exist")
                return
            }
            
            do {
                try await CloudKitManager.shared.getUserRecord()
                print("UserRecord updated successfully")
                
                if CloudKitManager.shared.profileRecordID != nil {
                    lastProfileAction = .created
                }
            } catch {
                print("Cant get userRecord: \(error)")
            }
        }
        
        /// Este método carga los datos del perfil existente en los campos de la UI.
        ///
        /// Si el usuario ya tiene un perfil creado, este método obtiene toda la información guardada y la presenta en el formulario para  su edición o visualización.
        ///
        ///
        /// ## Datos cargados
        /// - Nombre completo y profesión.
        /// - Biografía del usuario.
        /// - Imagen de perfil (si existe).
        /// - Estado de creación del perfil.
        @MainActor
        func loadProfile() async {
            guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
                print("⚠️ No hay profileRecordID para cargar")
                return
            }
            
            do {
                let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                
                firstLastName = record[JuradosProfile.keyFullName] as? String ?? ""
                profession = record[JuradosProfile.keyProfession] as? String ?? ""
                biography = record[JuradosProfile.keyBiography] as? String ?? ""
                
                if let avatarAsset = record[JuradosProfile.keyAvatar] as? CKAsset,
                   let url = avatarAsset.fileURL {
                    imageData = try? Data(contentsOf: url)
                }
                
                if !firstLastName.isEmpty {
                    lastProfileAction = .created
                }
                
                print("Profile loaded: \(firstLastName)")
                
            } catch {
                print("Can't load profile: \(error)")
            }
        }
        
        /// Este método validará que todos los campos del perfil cumplan con los requisitos.
        ///
        /// Verifica que los campos obligatorios estén llenos y que la biografía tenga la longitud mínima requerida de 90 caracteres.
        ///
        /// ## Validaciones aplicadas
        /// - **Nombre y profesión**: No pueden estar vacíos.
        /// - **Biografía**: Debe tener al menos 90 caracteres.
        /// - **Configuración automática de alertas**: Si falla alguna validación.
        ///
        /// - Returns: `true` si todos los campos son válidos, `false` en caso contrario.
        /// - Important: Configura automáticamente `invalidCredentials` y `showAlert` en caso de error.
        func invalidProfile() -> Bool {
            if firstLastName.trimmingCharacters(in: .whitespaces).isEmpty || profession.trimmingCharacters(in: .whitespaces).isEmpty {
                invalidCredentials = .incompleteProfile
                showAlert = true
                print("name and profession required")
                return false
            }
            if biography.trimmingCharacters(in: .whitespaces).count < 90 {
                invalidCredentials = .incompleteProfile
                showAlert = true
                print("Character count for biography must be greater than 90")
                return false
            }
            return true
        }
        
        /// Este método obtiene el estado actual de check-in del usuario.
        ///
        /// Consulta CloudKit para determinar si el usuario está actualmente registrado en alguna ubicación de Jurado's Burger.
        ///
        ///
        /// - Important: Requiere que el usuario tenga un perfil creado.
        /// - Note: Actualiza automáticamente la propiedad `isCheckedIn`.
        func getCheckedInStatus() async {
            
            guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
                print("Not profile record ID found")
                return
                
            }
            
            do {
                let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                if record[JuradosProfile.keyisHere] is CKRecord.Reference {
                    isCheckedIn = true
                } else {
                    isCheckedIn = false
                }
            } catch {
                invalidCredentials = .unableToGetCheckinStatus
            }
        }
        
        
        /// Este método realiza check-out del usuario de su ubicación actual.
        ///
        /// Elimina la referencia de ubicación del perfil del usuario en CloudKit, marcándolo como no presente en ninguna ubicación.
        ///
        /// ## Proceso de check-out
        /// 1. Obtiene el registro del perfil del usuario.
        /// 2. Limpia los campos `keyisHere` y `keyisHereNil`.
        /// 3. Guarda los cambios en CloudKit.
        /// 4. Actualiza el estado local `isCheckedIn`.
        @MainActor
        func checkOut() async {
            guard let profileRecordID = CloudKitManager.shared.profileRecordID else {
                invalidCredentials = .unableToGetProfile
                showAlert = true
                return
            }
            
            do {
                let record = try await CloudKitManager.shared.fetchRecord(with: profileRecordID)
                
                record[JuradosProfile.keyisHere] = nil
                record[JuradosProfile.keyisHereNil] = nil
                
                _ = try await CloudKitManager.shared.save(record: record)
                
                isCheckedIn = false
                
            } catch {
                print("🚨 Error while checking out: \(error.localizedDescription)")
                invalidCredentials = .unableToCheckInOrCheckOut
                showAlert = true
            }
        }
        
        /// Este método crea un nuevo perfil o actualiza uno existente de manera inteligente.
        ///
        /// Determina automáticamente si debe crear un perfil nuevo o actualizar uno existente, maneja la conversión de imágenes y gestiona todo el proceso de guardado en CloudKit.
        ///
        /// ## Funcionalidad
        /// 1. **Validación**: Verifica que todos los campos sean válidos.
        /// 2. **Preparación de datos**: Convierte imagen a CKAsset si existe.
        /// 3. **Determinación de acción**: Crear nuevo o actualizar existente.
        /// 4. **Configuración de referencias**: Conecta perfil con usuario.
        /// 5. **Guardado**: Guarda usuario y perfil juntos.
        /// 6. **Cache local**: Actualiza UserDefaults con el ID del perfil.
        /// 7. **Actualización de estado**: Obtiene estado de check-in actualizado.
        ///
        /// ## Creación vs Actualización
        /// - **Si no existe perfil**: Crea nuevo registro y referencia desde usuario
        /// - **Si existe perfil**: Actualiza registro existente manteniendo referencias
        ///
        /// - Important:Si falla algo en guardado o actualizado  nada se guarda.
        /// - Note: Incluye indicadores de loading automáticos durante el proceso.
        /// - Warning: Requiere conexión a internet y permisos de iCloud activos.
        func createProfile() async {
            
            guard invalidProfile() else {
                
                invalidCredentials = .incompleteProfile
                
                return
                
            }
            
            var profileValues: [String: CKRecordValue] = [
                JuradosProfile.keyFullName: firstLastName as CKRecordValue,
                JuradosProfile.keyProfession: profession as CKRecordValue,
                JuradosProfile.keyBiography: biography as CKRecordValue
            ]
            
            
            if let data = imageData,
               let image = UIImage(data: data),
               let asset = image.convertToCKAsset() {
                profileValues[JuradosProfile.keyAvatar] = asset
            }
            
            do {
                
                showLoading = true
                if CloudKitManager.shared.userRecord == nil {
                    try await CloudKitManager.shared.getUserRecord()
                }
                
                guard let userRecord = CloudKitManager.shared.userRecord else {
                    invalidCredentials = .failedToFetchUserRecord
                    showAlert = true
                    print("Can't obtain userRecord")
                    return
                }
                var profileRecord: CKRecord
                
                if let reference = userRecord["userProfile"] as? CKRecord.Reference {
                    
                    profileRecord = try await CloudKitManager.shared.fetchRecord(with: reference.recordID)
                    lastProfileAction = .updated
                    invalidCredentials = .profileUpdated
                    
                } else {
                    
                    profileRecord = CKRecord(recordType: "JuradosProfile")
                    userRecord["userProfile"] = CKRecord.Reference(recordID: profileRecord.recordID, action: .deleteSelf)
                    lastProfileAction = .created
                    invalidCredentials = .profileCreated
                }
                
                for (key, value) in profileValues {
                    profileRecord[key] = value
                }
                
                try await CloudKitManager.shared.saveMultipleRecords(records: [userRecord, profileRecord])
                UserDefaults.standard.set(profileRecord.recordID.recordName, forKey: "userProfileID")
                print("ProfileID save to UserDefaults: \(profileRecord.recordID.recordName)")
                invalidCredentials = .profileSavedSuccessfully
                
                await getCheckedInStatus()
                
            } catch {
                print("Processing error: \(error.localizedDescription)")
                invalidCredentials = .errorSavingProfile
                showAlert = true
            }
            showLoading = false
        }
    }
}




