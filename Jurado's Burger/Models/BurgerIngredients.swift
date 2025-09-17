//
//  BurgerIngredients.swift
//  Jurado's Burger
//
//  Created by Fernando Jurado on 1/9/25.
//

import Foundation

// MARK: - Ingredient Model
/// Representa un ingrediente individual de la hamburguesa.
///
/// Conforma a `Identifiable` para proporcionar un ID único y usarlo en listas/ForEach.
///
/// Conforma a `Equatable` para poder comparar instancias.

struct Ingredient: Identifiable, Equatable {
    
    // MARK: - Properties
    let id = UUID()
    let name: String
    let imageName: String
    let offset: CGFloat
    
    // MARK: - Equatable Conformance
    /// Se considera igual si comparten el mismo `id`.
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Ingredient Presets
extension Ingredient {
    
    /// Ingredientes disponibles en la app.
    ///
    /// `offset` ajusta manualmente el efecto visual al apilar cada ingrediente.
    static let availableIngredients = [
        Ingredient(name: "Sauce", imageName: "sauce", offset: 4),
        Ingredient(name: "Cheese", imageName: "cheese", offset: -4),
        Ingredient(name: "Bacon", imageName: "bacon", offset: -8),
        Ingredient(name: "Avocado", imageName: "avocado", offset: -8),
        Ingredient(name: "Gherkin", imageName: "gherkin", offset: -8),
        Ingredient(name: "Mushroom", imageName: "mushroom", offset: -8),
        Ingredient(name: "Fried Egg", imageName: "friedEgg", offset: -10),
        Ingredient(name: "Tomato", imageName: "tomato", offset: -10),
        Ingredient(name: "Onion", imageName: "onion", offset: -8),
        Ingredient(name: "Lettuce", imageName: "lettuce", offset: -8)
        
    ]
}
