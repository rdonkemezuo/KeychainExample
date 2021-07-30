//
//  AppAlert.swift
//  KeychainExample
//
//  Created by Raymond Donkemezuo on 7/30/21.
//

import Foundation


enum AppAlert {
    case missingCredentials(String)
    case successfulLogin
    case saveKeychain
    case biometricAuth(_ supportedType: String)

    /// alert message 
    var alertMessage: String {
        switch self {
        case .missingCredentials(let missingCredentialField):
            return missingCredentialField + " cannot be empty"
        case .saveKeychain:
            return "Save credentials to keychain to expedite future log in processes"
        case .successfulLogin:
            return "Successfully signed in"
        case .biometricAuth(let supportedBiometricAuthType):
            return "Your device supports \(supportedBiometricAuthType) sign in. You can enable this to expedite future sign in processes"
        }
    }

    /// Title of alert to be presented
    var alertTitle: String {
        switch self {
        case .missingCredentials( _):
            return "Missing field"
        case .saveKeychain:
            return "Save login credentials? "
        case .successfulLogin:
            return "Success"
        case .biometricAuth(_):
            return "Set up biometric authentication"
        }
    }
}
