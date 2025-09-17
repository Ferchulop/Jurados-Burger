//
//  CKAsset+Ext .swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 14/7/25.
//

import Foundation
import UIKit
import SwiftUI
import CloudKit

// MARK: - Placeholder Images
/// Enumeración de imágenes que hacen de placeholder cuando no hay  avatar o banner disponible.
enum PlaceholderImage {
    static let avatar = Image(systemName: "person.circle.fill")
    static let banner = Image(systemName: "photo.fill.on.rectangle.fill")
    
    static let avatarUIImage = UIImage(systemName: "person.circle.fill") ?? UIImage()
    static let bannerUIImage = UIImage(systemName: "photo.fill.on.rectangle.fill") ?? UIImage()
}

// MARK: - Image Dimension
/// Enumeración que define el tipo de imagen (avatar o banner) y proporciona su placeholder correspondiente.
enum ImageDimension {
    case  avatar, banner
    
    var placeholderImage: Image {
        switch self {
        case .avatar: return PlaceholderImage.avatar
        case .banner: return PlaceholderImage.banner
        }
    }
}

// MARK: - CKAsset Extension
/// Extensión de `CKAsset` para convertir los assets de CloudKit en `UIImage`.
extension CKAsset {
    
    /// Esta función convierte `CKAsset` a`UIImage`.
    ///
    /// - Parameters:
    ///     - dimension:  Indica si se trata de avatar o banner para devolver un placeholder adecuado en caso de error.
    ///
    /// - Returns: `UIImage` cargada desde el asset, o placeholder si falla.
    ///
    ///
    func convertToUIImage(for dimension: ImageDimension) -> UIImage {
        guard let fileURL = self.fileURL else {
            return PlaceholderImage.avatarUIImage
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data) ?? PlaceholderImage.avatarUIImage
        } catch {
            return PlaceholderImage.avatarUIImage
        }
    }
}
