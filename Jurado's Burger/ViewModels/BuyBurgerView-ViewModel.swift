//
//  BuyBurgerView-ViewModel.swift
//  Jurado's Burger
//
//  Created by Fernando Jurado on 5/9/25.
//

import Foundation
import SwiftUI



// MARK: - BuyBurgerView - ViewModel
extension BuyBurgerView {
    
    /// ViewModel con la macro `@bservable` para la gestión completa del proceso de creación de hamburguesas.
    ///
    /// `BuyBurgerViewModel` maneja toda la lógica de negocio relacionada con la personalización de hamburguesas, incluyendo selección de ingredientes, cálculos de precios y gestión del carrito
    ///  de compras.
    ///
    ///   ## Tipos de burger soportados
    /// - **Burger** (Por defecto): $9.99
    /// - **Smash**: $8.99
    /// - **Double**: $12.99
    
    @Observable
    final class BuyBurgerViewModel {
        let availableIngredients = Ingredient.availableIngredients
        var currentBurgerImage = "normalBurger"
        var selectedType = "Burger"
        var selectedIngredients: [Ingredient] = []
        var showBurgerTop = false
        var showBurgerBase = false
        var cartCount: Int = 0
        
        
        ///  Este método añade la burger personalizada al carrito con animación.
        ///
        /// Ejecuta una secuencia animada que simula la construcción de la burger,
        /// incrementa el contador del carrito y resetea automáticamente la vista
        /// después de 1.5 segundos.
        ///
        /// ## Secuencia de animación
        /// 1. Activa `showBurgerTop` y `showBurgerBase` con animación suave
        /// 2. Incrementa el contador del carrito inmediatamente
        /// 3. Espera 1.5 segundos para mostrar la animación completa
        /// 4. Resetea la vista para permitir una nueva personalización
        func addToCart() {
            
            withAnimation(.easeOut(duration: 0.6)) {
                showBurgerTop  = true
                showBurgerBase = true
            }
            
            cartCount += 1
            
            Task {
                try? await Task.sleep(for: .seconds(1.5))
                
                await MainActor.run {
                    resetView()
                }
            }
        }
        
        /// Este método resetea la vista a su estado inicial para una nueva personalización.
        ///
        /// Limpia todas las selecciones del usuario y restaura la configuración por defecto, preparando la interfaz para crear una nueva hamburguesa.
        ///
        ///
        /// ## Estado después del reset
        /// - Ingredientes seleccionados: vacío
        /// - Tipo de burger: "Burger" (Por defecto)
        /// - Imagen: "normalBurger"
        /// - Animaciones: desactivadas
        ///
        ///
        /// - Note: Se llama automáticamente después de `addToCart()`.
        /// - Important: Ejecuta en el `MainActor` para actualizaciones de la UI.
        func resetView() {
            
            showBurgerTop  = false
            showBurgerBase = false
            selectedIngredients.removeAll()
            currentBurgerImage = "normalBurger"
            selectedType = "Burger"
        }
        
        
        /// Este método añade o quita un ingrediente de la selección actual.
        ///
        /// Se implementa una lógica tipo "toggle" para ingredientes: si ya está seleccionado
        /// lo quita, si no está lo añade. La operación incluye animación spring para transiciones suaves.
        ///
        /// - Parameters:
        ///     - ingredient: El ingrediente a añadir o quitar de la selección.
        ///
        /// - Important: Utiliza animación spring optimizada para feedback táctil.
        /// - Note: La animación tiene `response: 0.5` y `dampingFraction: 0.7` para suavidad.
        func addOrRemoveIngredient(_ ingredient: Ingredient) {
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                if let index = selectedIngredients.firstIndex(of: ingredient) {
                    selectedIngredients.remove(at: index)
                } else {
                    selectedIngredients.append(ingredient)
                }
            }
        }
        
        /// Este método calcula el precio total de la hamburguesa personalizada.
        ///
        /// Combina el precio base del tipo de  hamburguesa seleccionado con el coste adicional de todos los ingredientes añadidos.
        ///
        /// ## Estructura de precios
        /// - **Precio base por tipo**:
        ///   - Burger: $9.99
        ///   - Smash: $8.99
        ///   - Double: $12.99
        /// - **Ingredientes**: $0.75 cada uno
        ///
        /// - Returns: Precio total como `Double` con centavos incluidos.
        ///
        /// - Note: El cálculo es dinámico y se actualiza automáticamente con cambios.
        /// - Important: Siempre retorna un valor válido, siendo asignado por defecto a "Burger" para tipos desconocidos.
        func calculatePrice() -> Double {
            
            let basePrice: Double = {
                switch selectedType {
                case "Smash": return 8.99
                case "Double": return 12.99
                default: return 9.99
                }
            }()
            
            let ingredientPrice = Double(selectedIngredients.count) * 0.75
            return basePrice + ingredientPrice
        }
        
    }
}
