//
//  HapticsManager.swift
//  Jurado's Burger
//
//  Created by Fernando Jurado on 12/8/25.
//

import SwiftUI
import CoreHaptics

// MARK: Haptics Manager

/// Enumeración que centralizará todos los efectos hápticos de la app.
///
/// `HapcticsManager` se encargará de proporcionar feedback háptico en toda la app, desde vibraciones básicas hasta patrones personalizados más complejos.
///
///  ## Configuración inicial
/// ```swift
/// // En tu App
/// HapticsManager.prepareHaptics()
/// ```
///
/// ## Uso básico
/// ```swift
/// // Feedback de éxito estándar
/// HapticsManager.success()
///
/// // Feedback de éxito personalizado para burgers
/// HapticsManager.successBurger()
/// ```
///
/// - Important: Se llama a `prepareHaptics()` al inicio de la app para mejorar rendimiento.
/// - Note: Automáticamente verificará la compatibilidad del hardware antes de ejecutar.

enum HapticsManager {
    
    /// Motor de hápticos compartido para personalizaciones.
    private static var engine: CHHapticEngine?
    
    /// Este método configura `CHHapticEngine` y lo deja operativo para poder ejecutar cualquier patrón háptico personalizado.
    ///
    /// - Important: Maneja automáticamente errores de inicialización del motor.
    /// - Note: Solo se ejecuta en dispositivos que soportan hápticos.
    static func prepareHaptics() {
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }
    
    /// Ejecuta un patrón háptico de éxito estandar del sistema.
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
        
    }
    /// Ejecuta un patrón personalizado de éxito al añadir al carrito una hamburguesa.
    ///
    /// Crea una secuencia de vibraciones con intensidades y tiempos específicos
    ///
    ///  ## Patrón de vibración
    /// 1. **0.0s**: Vibración intensa (1.0 intensidad, 1.0 sharpness)
    /// 2. **0.12s**: Vibración suave (0.5 intensidad, 0.6 sharpness)
    /// 3. **0.24s**: Vibración alta (0.9 intensidad, 0.9 sharpness)
    /// 4. **0.36s**: Vibración final (0.4 intensidad, 0.5 sharpness)
    ///
    ///  - Important: Requiere que `prepareHaptics()` haya sido llamado anteriormente.
    ///  - Warning: Maneja automáticamente errores de reproducción.
    static func successBurger() {
        
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        let highVibration1 = CHHapticEvent(eventType: .hapticTransient,
                                           parameters: [
                                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
                                           ],
                                           relativeTime: 0)
        
        let lowVibration1 = CHHapticEvent(eventType: .hapticTransient,
                                          parameters: [
                                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5),
                                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
                                          ],
                                          relativeTime: 0.12)
        
        let highVibration2 = CHHapticEvent(eventType: .hapticTransient,
                                           parameters: [
                                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9),
                                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
                                           ],
                                           relativeTime: 0.24)
        
        let lowVibration2 = CHHapticEvent(eventType: .hapticTransient,
                                          parameters: [
                                            CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.4),
                                            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
                                          ],
                                          relativeTime: 0.36)
        
        do {
            let pattern = try CHHapticPattern(events: [highVibration1,lowVibration1, highVibration2, lowVibration2], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            print("Reproduced haptics failed: \(error.localizedDescription)")
        }
    }
} 


