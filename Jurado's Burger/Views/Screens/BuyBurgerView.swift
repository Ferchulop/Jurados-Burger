//
//  BuyBurguerView.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 24/6/25.
//

import SwiftUI

struct BuyBurgerView: View {
    
    @Environment(BuyBurgerView.BuyBurgerViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                ZStack {
                    if viewModel.showBurgerTop {
                        Image(.burgerTop)
                            .resizable()
                            .scaledToFit()
                            .zIndex(3)
                            .offset(x: 2, y: -50)
                            .rotation3DEffect(.degrees(-40), axis: (x: 1, y: 0, z: 10))
                            .shadow(radius: 5)
                            .transition(.opacity.combined(with: .slide))
                        
                        
                    }
                    if viewModel.showBurgerBase {
                        Image(.burgerBase)
                            .resizable()
                            .scaledToFit()
                            .zIndex(0)
                            .offset(y: 35)
                            .rotation3DEffect(.degrees(0), axis: (x: -10, y: 0, z: 0))
                            .shadow(radius: 5)
                            .transition(.opacity.combined(with: .slide))
                        
                    }
                    
                    Image(viewModel.currentBurgerImage)
                        .resizable()
                        .scaledToFit()
                        .shadow(radius: 10)
                        .animation(.easeInOut, value: viewModel.currentBurgerImage)
                        .offset(x: -4, y: 10)
                        .zIndex(1)
                    
                    ForEach(Array(viewModel.selectedIngredients.enumerated()), id: \.element.id) { index, ingredient in
                        Image(ingredient.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70 , height: 40)
                            .offset(y: ingredient.offset - CGFloat(index * 1))
                            .scaleEffect(3)
                            .animation(.spring(response: 0.6, dampingFraction: 0.9), value: viewModel.selectedIngredients)
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .offset(y: -80)),
                                removal: .scale.combined(with: .opacity)
                            ))
                    }
                    .zIndex(2)
                }
                .frame(height: 180)
                
                Grid(horizontalSpacing: 18) {
                    GridRow {
                        Button("Smash") {
                            viewModel.currentBurgerImage = "smashBurger"
                            viewModel.selectedType = "Smash"
                        }
                        .buttonStyle(BurgerButton(isSelected: viewModel.selectedType == "Smash"))
                        .accessibilityLabel("Smash burger")
                        .accessibilityHint("Double tap to select smash style")
                        .accessibilityAddTraits(viewModel.selectedType == "Smash" ? .isSelected : [])
                        
                        
                        Button("Burger") {
                            viewModel.currentBurgerImage = "normalBurger"
                            viewModel.selectedType = "Burger"
                        }
                        .buttonStyle(BurgerButton(isSelected: viewModel.selectedType == "Burger"))
                        .accessibilityLabel("Regular burger")
                        .accessibilityHint("Double tap to select regular style")
                        .accessibilityAddTraits(viewModel.selectedType == "Burger" ? .isSelected : [])
                        
                        Button("Double") {
                            viewModel.currentBurgerImage = "doubleBurger"
                            viewModel.selectedType = "Double"
                        }
                        .buttonStyle(BurgerButton(isSelected: viewModel.selectedType == "Double"))
                        .accessibilityLabel("Double burger")
                        .accessibilityHint("Double tap to select double style")
                        .accessibilityAddTraits(viewModel.selectedType == "Double" ? .isSelected : [])
                    }
                }
                
                VStack {
                    HStack {
                        Text("Select your ingredients:")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("\(viewModel.selectedIngredients.count)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(.myPrimary)
                            .clipShape(Circle())
                    }
                    .padding(.horizontal)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Select your ingredients\(viewModel.selectedIngredients.count)of 10 selected")
                    .accessibilityHint("Swipe left or right to explore available ingredients")
                    
                    ZStack {
                        Capsule()
                            .fill(.thinMaterial)
                            .frame(height: 80)
                            .opacity(0.8)
                            .shadow(radius: 5)
                            .accessibilityHidden(true)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(viewModel.availableIngredients) { ingredient in
                                    IngredientButton(
                                        ingredient: ingredient,
                                        isSelected: viewModel.selectedIngredients.contains(ingredient)
                                    ) {
                                        viewModel.addOrRemoveIngredient(ingredient)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                }
                
                if !viewModel.selectedIngredients.isEmpty {
                    Button("Clear All") {
                        withAnimation(.spring()) {
                            viewModel.selectedIngredients.removeAll()
                        }
                    }
                    .foregroundStyle(.red)
                    .transition(.opacity.combined(with: .scale))
                }
                
                Spacer()
                
                Button("Add Burger - $\(viewModel.calculatePrice(), specifier: "%.2f")") {
                    viewModel.addToCart()
                    HapticsManager.success()
                }
                .frame(width: 190, height: 50)
                .background(.myPrimary)
                .foregroundStyle(.black)
                .fontWeight(.semibold)
                .clipShape(.capsule)
                .shadow(radius: 5)
                .accessibilityLabel("Add burger to cart, price: \(viewModel.calculatePrice(), specifier: "%.2f") dollars")
                .accessibilityHint("Double tap to add to cart")
                
            }
            .padding(.vertical, 20)
            .navigationBarTitle("Build your Burger", displayMode: .inline)
        }
    }
}
#Preview {
    BuyBurgerView()
        .environment(BuyBurgerView.BuyBurgerViewModel())
}

struct BurgerButton: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 80, height: 40)
            .foregroundStyle(isSelected ? .secondary : .primary)
            .background(.thinMaterial.opacity(0.8))
            .clipShape(.capsule)
            .shadow(radius: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct IngredientButton: View {
    let ingredient: Ingredient
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(ingredient.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .background(.thinMaterial.opacity(isSelected ? 1.0 : 0.8))
                .overlay(
                    Circle()
                        .stroke(isSelected ? .myPrimary : .clear, lineWidth: 2)
                )
                .shadow(radius: isSelected ? 8 : 3)
                .clipShape(Circle())
                .scaleEffect(isSelected ? 1.0 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(ingredient.name)
        .accessibilityHint(isSelected ? "Double tap to remove" : "Double tap to add")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
    
}


