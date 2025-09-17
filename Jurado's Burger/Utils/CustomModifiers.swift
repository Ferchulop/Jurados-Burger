//
//  CustomModifiers.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 3/7/25.
//

import SwiftUI

// MARK: - PlaceholderStyle
/// Modificador personalizado que proporciona funcionalidad de placeholder avanzada.
///
/// `PlaceholderStyle` implementa un sistema de placeholder completamente personalizable que supera las limitaciones del placeholder nativo de `TextField`. Permite  control  sobre colores,
/// tipografía y comportamiento del texto.
///
/// - Important: Diseñado para usarse con la extensión `View.customPlaceholder()`.
/// - Note: El placeholder se oculta automáticamente cuando hay texto presente.
struct PlaceholderStyle: ViewModifier {
    let placeholder: String
    @Binding var text: String
    var placeholderColor: Color
    var textColor: Color
    var weight: Font.Weight
    var lineLimit: Int?
    var minimumScaleFactor: CGFloat?
    var autocapitalization: TextInputAutocapitalization
    
    
    /// Construye la vista modificada con funcionalidad de placeholder.
    ///
    /// Implementa la lógica principal del modificador, creando una superposición  para mostrar el placeholder cuando es necesario y aplicar el estilo  tanto al placeholder como al contenido. Ya que de
    /// forma nativa tiene sus propias limitaciones.
    ///
    /// ## Comportamiento del modificador
    /// 1. **Cuando el texto está vacío**: Muestra el placeholder con el color y estilo especificados
    /// 2. **Cuando hay texto**: Oculta el placeholder y muestra el contenido con su estilo
    /// 3. **Ambos estados**: Aplican las mismas propiedades de fuente y limitaciones
    ///
    ///
    /// - Parameter content: La vista original que se está modificando (en este caso es un `TextField`).
    /// - Returns: Una vista compuesta con funcionalidad de placeholder superpuesta.
    ///
    /// - Important: El `ZStack` usa alineación `.leading` para posicionamiento correcto del texto.
    /// - Note: Ambos textos (placeholder y contenido) comparten las mismas propiedades de fuente.
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(placeholderColor)
                    .fontWeight(weight)
                    .lineLimit(lineLimit)
                    .minimumScaleFactor(minimumScaleFactor ?? 0.75)
            }
            
            content
                .foregroundStyle(textColor)
                .fontWeight(weight)
                .lineLimit(lineLimit)
                .minimumScaleFactor(minimumScaleFactor ?? 0.75)
                .textInputAutocapitalization(autocapitalization)
        }
    }
}
