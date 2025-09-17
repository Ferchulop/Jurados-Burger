//
//  View+Ext.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 3/7/25.
//

import SwiftUI

// MARK: - Extension CustomPlaceholder
/// Aplica un estilo de placeholder personalizado a cualquier vista.
extension View {
    
    /// Esta función permite agregar un placeholder totalmente personalizable a cualquier  campo de texto.
    ///
    /// - Parameters:
    ///     - placeholder: El texto que se muestra cuando el campo está vacío.
    ///     - text: Binding al texto de campo de entrada.
    ///     - placeholderColor: Color del texto placeholder. Por defecto: `.gray`
    ///     - font: Fuente del texto. Por defecto: `.title2`
    ///     - textColor: Color del texto cuando hay contenido. Por defecto: `.white`
    ///     - weight: Peso de la fuente. Por defecto: `.regular`
    ///     - lineLimit: Número máximo de líneas. Por defecto: `1`
    ///     - minimumScaleFactor: Factor mínimo de escala del texto. Por defecto: `0.75`
    ///     - autocapitalization: Configuración de auto-capitalización. Por defecto: `.never`
    ///
    /// - Returns: Una vista modificada con el estilo del placeholder personalizada.
    ///
    /// - Important: Asegurarse de que `PlaceholderStyle` haya sido implementado correctamente.
    func customPlaceholder(
        _ placeholder: String,
        text: Binding<String>,
        placeholderColor: Color = .gray,
        font: Font = .title2,
        textColor: Color = .white,
        weight: Font.Weight = .regular,
        lineLimit: Int? = 1,
        minimumScaleFactor: CGFloat? = 0.75,
        autocapitalization: TextInputAutocapitalization = .never
    ) -> some View {
        self.modifier(PlaceholderStyle(
            placeholder: placeholder,
            text: text,
            placeholderColor: placeholderColor,
            textColor: textColor,
            weight: weight,
            lineLimit: lineLimit,
            minimumScaleFactor: minimumScaleFactor,
            autocapitalization: autocapitalization
        ))
    }
}
