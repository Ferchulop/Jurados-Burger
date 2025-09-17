//
//  UImageData+Ext.swift
//  Jurado's Burger
//
//  Created by Fernando Jurado on 21/7/25.
//

import Foundation
import UIKit
import CloudKit

// MARK: - Extensión UIImage
/// Esta extensión agrega funcionalidades a UIImage para trabajar fácilmente con CloudKit.
extension UIImage {
    /// Esta función convierte `UIImage` a `CKAsset` para  subir a CloudKit.
    ///
    /// - Returns: Un CKAsset opcional que contiene la imagen o nil si ocurre un error.
    func convertToCKAsset() -> CKAsset? {
        
        guard let imageData = self.jpegData(compressionQuality: 0.8) else { return nil }
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL, options: [.atomic])
            
            return CKAsset(fileURL: fileURL)
        } catch {
            
            print("Error writing image data to temporary file: \(error.localizedDescription)")
            return nil
        }
    }
}

