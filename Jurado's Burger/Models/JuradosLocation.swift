//
//  JuradosLocation.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 7/7/25.
//
import UIKit
import Foundation
import CloudKit

// MARK: - Location Model
/// Representa un local  (Jurado's Burger)  dentro de la app.
///
/// Este modelo se inicializa a partir de un `CKRecord` de CloudKit y expone propiedades como nombre, dirección, descripción, imágenes y coordenadas.
///
/// Conforma a `Identifiable` para proporcionar un ID único y usarlo en listas/ForEach.
struct JuradosLocation: Identifiable {
    
    // MARK: - Cloudkit Keys
    /// Su uso es para mapear campos de CloudKit al modelo.
    static let keyName = "name"
    static let keyAddress = "address"
    static let keyDescription = "description"
    static let keyAvatarAsset = "avatarAsset"
    static let keyBannerAsset = "bannerAsset"
    static let keyWebsite = "website"
    static let keyPhone = "phone"
    static let keyLocation = "location"
    
    
    // MARK: - Properties
    let id: CKRecord.ID
    let name: String
    let address: String
    let description: String
    let avatarAsset: CKAsset!
    let bannerAsset: CKAsset!
    let website: String
    let phone: String
    let location: CLLocation
    
    // MARK: - Initializer
    /// Inicializa `JuradosLocation` a partir de un `CKRecord`.
    init(record: CKRecord) {
        id = record.recordID
        name = record[JuradosLocation.keyName] as? String ?? "N/A"
        description = record[JuradosLocation.keyDescription] as? String ?? "N/A"
        address = record[JuradosLocation.keyAddress] as? String ?? "N/A"
        avatarAsset = record[JuradosLocation.keyAvatarAsset] as? CKAsset
        bannerAsset = record[JuradosLocation.keyBannerAsset] as? CKAsset
        location = record[JuradosLocation.keyLocation] as? CLLocation ?? CLLocation(latitude: 0, longitude: 0)
        website = record[JuradosLocation.keyWebsite] as? String ?? "N/A"
        phone = record[JuradosLocation.keyPhone] as? String ?? "N/A"
        
    }
    
    // MARK: - Image Conversion
    
    /// Esta función convierte `avatarAsset` en  `UIImage`.
    ///
    /// Si no existiese devolvería un placeholder por defecto.
    
    func createAvatarImage() -> UIImage {
        guard let asset = avatarAsset else { return PlaceholderImage.avatarUIImage }
        return asset.convertToUIImage(for: .avatar)
        
    }
    /// Esta función convierte `bannerAsset` en `UIImage`.
    ///
    /// Si no existiese devolvería un placeholder por defecto.
    func createBannerImage() -> UIImage {
        guard let asset = bannerAsset else { return PlaceholderImage.bannerUIImage }
        return asset.convertToUIImage(for: .banner)
    }
}

