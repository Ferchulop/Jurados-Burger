//
//  Profile.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 7/7/25.
//

import Foundation
import CloudKit
import UIKit

// MARK: - Profile Model
/// Representa un perfil de usuario dentro de la app.
///
/// Este modelo se inicializa a partir de un `CKRecord` de CloudKit y expone propiedades como: nombre completo, avatar, profesión, biografía y estados de localización (`check-in` ó `check-out`)
///
/// Conforma a `Identifiable` para proporcionar un ID único y usarlo en listas/ForEach.

struct JuradosProfile: Identifiable {
    
    // MARK: - Cloudkit Keys
    /// Su uso es para mapear campos de CloudKit al modelo.
    static let keyFullName = "fullName"
    static let keyAvatar = "avatar"
    static let keyProfession = "profession"
    static let keyBiography = "biography"
    static let keyisHere = "isHere"
    static let keyisHereNil = "isHereNil"
    
    // MARK: - Properties
    let id: CKRecord.ID
    let fullName: String
    let avatar: CKAsset!
    let profession: String
    let biography: String
    let isHere: CKRecord.Reference?
    
    // MARK: - Initializer
    /// Inicializa `JuradosProfile` a partir de `CKRecord`
    init(record: CKRecord) {
        
        id = record.recordID
        fullName = record[JuradosProfile.keyFullName] as?  String ?? "N/A"
        avatar = record[JuradosProfile.keyAvatar] as? CKAsset
        profession = record[JuradosProfile.keyProfession] as? String ?? "N/A"
        biography = record[JuradosProfile.keyBiography] as? String ?? "N/A"
        isHere = record[JuradosProfile.keyisHere] as? CKRecord.Reference
    }
}
// MARK: - Methods and Computed Properties
extension JuradosProfile {
    
    /// Obtiene los datos binarios (`Data`) del avatar almacenado en CloudKit. Devuelve `nil` si no existe o hay un error al acceder al archivo.
    var avatarData: Data? {
        guard let avatar = avatar,
              let url = avatar.fileURL else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error obteniendo avatar data para \(fullName): \(error)")
            return nil
        }
    }
    
    ///  Esta función convierte `CKAsset` en  UIImage`
    ///
    ///  Si no existiese devolvería un placeholder por defecto.
    func createAvatarImage() -> UIImage {
        guard let avatar = avatar else {
            return PlaceholderImage.avatarUIImage
        }
        return avatar.convertToUIImage(for: .avatar)
    }
    
    /// Verificar si el perfil tiene un avatar asignado.
    var hasAvatar: Bool {
        return avatar != nil
    }
    // MARK: - Name Utilities
    /// Obtiene el primer nombre a partir de `fullName`
    var firstName: String {
        let components = fullName.components(separatedBy: " ")
        return components.first ?? fullName
    }
    
    /// Obtiene las iniciales del usuario, por ej: ("Fernando Jurado" = "FJ").
    var initials: String {
        let components = fullName.components(separatedBy: " ")
        let firstInitial = components.first?.first ?? Character(" ")
        let lastInitial = components.count > 1 ? components.last?.first ?? Character(" ") : Character(" ")
        return "\(firstInitial)\(lastInitial)".trimmingCharacters(in: .whitespaces)
    }
}


