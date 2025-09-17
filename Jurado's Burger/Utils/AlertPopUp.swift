//
//  AlertPopUp.swift
//  Jurado's Burguer
//
//  Created by Fernando Jurado on 8/7/25.
//

import SwiftUI

/// Estructura centralizada para todos los alertas y mensajes de la aplicación.
///
/// `AlertPopUp` proporciona varias alertas predefinidas comunes utilizadas a través de toda la aplicación, garantizando consistencia en mensajes de error, éxito y información para el usuario.
///
/// ## Categorías de alertas
/// - **Ubicaciones**: Errores relacionados con servicios de localización
/// - **Perfiles**: Estados de creación, actualización y guardado de perfiles
/// - **Check-in/Check-out**: Problemas con registro de entrada/salida
/// - **CloudKit**: Errores de conectividad y datos de usuario
///
/// - Important: Todos los alertas son instancias estáticas para reutilización eficiente.
/// - Note: Los mensajes incluyen instrucciones claras para que el usuario resuelva problemas.
struct AlertPopUp {
    let title: String
    let message: String
    
    static let unableToGetLocations = AlertPopUp(
        title: ("Unable to get locations"),
        message: ("Unable location services at this time.\nPlease try again later."))
    
    static let locationRestricted = AlertPopUp(
        title: ("Location services restricted"),
        message: ("Location services are restricted on this device.\nPlease go to settings and enable location services."))
    
    static let deniedLocationAccess = AlertPopUp(
        title: ("Location access denied"),
        message: ("Location access is denied for this app.\nPlease go to settings and enable location access."))
    
    static let disabledLocationAccess = AlertPopUp(
        title: ("Location access disabled"),
        message: ("Location access is disabled.\nPlease go to settings and enable location access."))
    
    static let incompleteProfile = AlertPopUp( title: "Please complete your profile", message: "You must complete your profile before tapping the button. Your bio must be at least 90 characters long. \nPlease try again.")
    
    static let failedToFetchUserRecord = AlertPopUp(
        title: "User Record Not Found",
        message: "We couldn’t fetch your iCloud user information.\nPlease make sure you are signed in and try again.")
    
    static let profileSavedSuccessfully = AlertPopUp(
        title: "Profile Saved",
        message: "Your profile has been saved successfully. Welcome to Jurado's Burger! 🍔✨")
    
    static let errorSavingProfile = AlertPopUp(
        title: "Save Failed",
        message: "We couldn’t save your profile.\nPlease check your connection and try again.")
    
    static let profileUpdated = AlertPopUp(
        title: "Profile Updated",
        message: "Your profile has been successfully updated.")
    
    static let profileCreated = AlertPopUp(
        title: "Profile Created",
        message: "Your new profile has been created successfully.")
    
    static let unableToGetCheckinStatus = AlertPopUp(
        title: "Check-in Status Unavailable",
        message: "We couldn’t get your check-in status.\nPlease try again later.")
    
    static let unableToGetProfile = AlertPopUp(
        title: "Profile Unavailable",
        message: "We couldn’t get your profile.\nPlease try again later.")
    
    static let unableToCheckInOrCheckOut = AlertPopUp(
        title: "Check-in/Check-out Unavailable",
        message: "We couldn’t check you in or check you out.\nPlease try again later.")
    
}


