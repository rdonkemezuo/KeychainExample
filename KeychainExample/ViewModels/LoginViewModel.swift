//
//  LoginViewModel.swift
//  KeychainExample
//
//  Created by Raymond Donkemezuo on 7/29/21.
//

import Foundation

class LoginViewModel: ObservableObject {
    struct Constants {
        static let keychain_account_name_key = "keychain_account" /// The acocunt name in the keychain where we are storing the login credentials
        static let userNameKey = "userName" /// The key to our stored username value
        static let passwordKey = "password" /// The key to our stored password value
    }
    @Published var showAlert = false
    @Published var showingActivityIndicator = false 
    @Published var username = ""
    @Published var password = ""
    @Published var alert: AppAlert = .saveKeychain
    var disableLoginButton: Bool {
        return username.isEmpty || password.isEmpty
    }
    let keychainHandler = KeychainHandler.shared
    let biometricAuthenticationHandler = BiometricAuthenticationHandler.shared
    
    init() {
        let credentialsStoredInKeychain = keychainHandler.fetchLoginCredentialsFromKeychain()
        self.username = credentialsStoredInKeychain?.username ?? ""
        self.password = credentialsStoredInKeychain?.password ?? ""
        self.callBiometricAuthentication()
    }
    
    func authenticateUser(completionHandler: @escaping(Bool) -> ()) {
        showingActivityIndicator = true
        guard !username.isEmpty else
        {
            showingActivityIndicator = false
            alert = .missingCredentials("username field")
            showAlert.toggle()
            return;
        }
        
        
        guard !password.isEmpty else
        {
            showingActivityIndicator = false
            alert = .missingCredentials("password field")
            showAlert.toggle()
            return;
        }
        /// Perform server authenticaton and if successful --- Person below
        if keychainHandler.areCredentialsSavedInKeychain {
            alert = .successfulLogin
            showAlert = true
            showingActivityIndicator = false
            return;
        }
        alert = .saveKeychain
        showAlert = true
        showingActivityIndicator = false
    }
    
    
    /// - TAG: A method that calls biometric authentication on our login view
    /// The first check is to see if we should request for user to setup biometric authentication - if yes, show alert
    /// If we shouldn't we check to see if biometric authentication is already approved, if yes, try to authenticate user if password is stored in keychain
    func callBiometricAuthentication() {
        guard !biometricAuthenticationHandler.requestBiometricAuthFromUser else
        {
            return;
        }

        guard biometricAuthenticationHandler.isBiometricAuthenticationEnabled else
        {
            return;
        }
        guard !username.isEmpty,
              !password.isEmpty else
        {
            return;
        }
        biometricAuthenticationHandler.handleBiometricAuthentication { result in
            if result {
                DispatchQueue.main.async {
                    self.alert = .successfulLogin
                    self.showAlert = true
                }
            } else {
                return;
            }
        }
    }

    /// - TAG: A method that calls biometric authentication setup on alert
    func callSetupBiometricAuthentication() {
        biometricAuthenticationHandler.setupBiometricAuthentication { result in
            if result {
                DispatchQueue.main.async {
                    self.alert = .successfulLogin
                    self.showAlert = true
                }
            } else {
                return;
            }
        }
    }
    
    ///- TAG: A method that calls store rejected biometric authentication request
    func callRejectedAuthenticationRequest() {
        biometricAuthenticationHandler.storeBiometricAuthenticationResultAndTimeLocally(false)
        self.alert = .successfulLogin
        self.showAlert = true
    }
    ///- TAG: A method that calls store save credentials to keychain
    func callSaveLoginCredentialsToKeychain() {
        keychainHandler.saveCredentialsToKeychain(username, password) { didSave in
            DispatchQueue.main.async {
                if didSave {
                   self.alert = .biometricAuth(_: self.biometricAuthenticationHandler.supportedBioAuthenticationType)
                   ////// self.alertMessage = .saveKeychain
                    self.showAlert = true
                } else {
                    self.alert = .successfulLogin
                    self.showAlert = true
                }
            }
        }
    }
}


