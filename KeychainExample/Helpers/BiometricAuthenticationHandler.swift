//
//  BiometricAuthenticationHandler.swift
//  KeychainExample
//
//  Created by Raymond Donkemezuo on 7/29/21.
//

import Foundation
import Security
import LocalAuthentication

/// - TAG: A class that handles biometric (TouchID && FaceID) authentication
class BiometricAuthenticationHandler {
    struct Constants {
        static let localizedMessage = "Access requires authentication"
        static let biometric_auth_authorization_requestKey = "biometricAuthorizationRequest"
        static let biometric_auth_authorizedKey = "biometricAuthorized"
        static let biometric_auth_authorization_request_response_dateKey = "responseDate"
    }
    static let shared = BiometricAuthenticationHandler()
    private var isDeviceSupported = false
    private var userAuthorizedBiometricAuth = false
    var requestBiometricAuthFromUser: Bool { /// A variable that returns if we should request biometric authentication from user
        return requestForBiometricAuthentication()
    }
    private var supportedType: String? = nil
    private let userDefaults = UserDefaults.standard
    private var authorizationRequestResponseDate: Date?
    
    var isBiometricAuthenticationEnabled: Bool { //// A varriable that returns if the user enabled biometric authentication 
        return userAuthorizedBiometricAuth
    }
    var isBiometricSupportedOnDevice: Bool { /// A variable that tells if the current device supports biometric authentication
        return isDeviceSupported
    }
    var supportedBioAuthenticationType: String { /// A variable that tells the type of biometric authentication that is supported. i.e TouchID or FaceID
        return supportedType ?? ""
    }
    
    init() {
        checkForBiometricAuthentication()
        fetchLocalBiometricAuthenticationResult()
    }
    
    /// - TAG: A method that checks if the current device support/biometric authentiction is enabled
    private func checkForBiometricAuthentication() {
        let context = LAContext()
        var contextError: NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &contextError) {
            isDeviceSupported = true
            supportedType = context.biometryType == .faceID ? "FaceID" : "TouchID"
        }
    }
    
    /// - TAG: A method that setup biometric authentication to expedite future sign in process
    /// - parameter completionHandler: A closure to call
    func setupBiometricAuthentication(completionHandler: @escaping(Bool) -> ()) {
        let context = LAContext()
        var contextError: NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &contextError) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: Constants.localizedMessage) { result, error in
                if contextError != nil {
                    completionHandler(false) /// Replace this implementation with code to handle the error appropriately
                } else {
                    self.storeBiometricAuthenticationResultAndTimeLocally(_: result)
                    completionHandler(result)
                }
            }
        }
    }
    
    /// - TAG: A method that stores the response and date of biometric authentication request
    /// With a successful biometric setup stored locally, when user launches the app in the future, we will just present the biometric sign in to expedite the sign in process
    /// Though this response can be stored differently, I am currently storing in user-defaults, so if the user deletes the app, the message to setup a biometric authentication  will show again
    func storeBiometricAuthenticationResultAndTimeLocally(_ result: Bool) {
        let responseData: [String: Any] = [Constants.biometric_auth_authorizedKey: result, Constants.biometric_auth_authorization_request_response_dateKey: Date()]
        userDefaults.setValue(responseData, forKey: Constants.biometric_auth_authorization_requestKey)
    }
    
    /// - TAG: A method that retrieves the biometric authorization status and response date
    func fetchLocalBiometricAuthenticationResult() {
        guard let storedResponseData = userDefaults.dictionary(forKey: Constants.biometric_auth_authorization_requestKey) else
        {
            return;
        }
        guard let authorizationResponse = storedResponseData[Constants.biometric_auth_authorizedKey] as? Bool,
              let responseDate = storedResponseData[Constants.biometric_auth_authorization_request_response_dateKey] as? Date
        else {
            return;
        }
        authorizationRequestResponseDate = responseDate
        userAuthorizedBiometricAuth = authorizationResponse
    }
    
    /// - TAG: A method to check if we should request biometric authentication from user
    ////  We have to check if the device supports biometric authentication else don't ask
    /// We have to check if biometric authentication is has previously been approved by user
    //// We have to check if the user had previously declined request, if yes, since how many days ago
    func requestForBiometricAuthentication() -> Bool {
        guard isBiometricSupportedOnDevice else
        {
            return false;
        }
        
        guard !isBiometricAuthenticationEnabled else
        {
            return false;
        }
        
        /// If we haven't requested authorization from user before, then we should request
        guard let lastRequestResponseDate = authorizationRequestResponseDate else
        {
            return true
        }
        
        let numberDaysSinceLastResponse = Date().daysBetweenDates(startDate: lastRequestResponseDate)
        if numberDaysSinceLastResponse < 5 { //// This is a constant value and can be changed to fit the use case. Basically checking if the user rejected to setup biometric auth less than 5 days ago. if yes, no need asking again
            return false
        } else {
            return true
        }
    }

    /// - TAG: A method that handles biometric authorization
    func handleBiometricAuthentication(completionHandler: @escaping(Bool) -> ()) {
        guard isBiometricAuthenticationEnabled else
        {
            completionHandler(false)
            return;
        }
        let context = LAContext()
        var contextError: NSError?
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &contextError) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: Constants.localizedMessage) { result, error in
                if contextError != nil {
                    completionHandler(false)
                } else {
                    if result {
                        completionHandler(true) //// Successful sign in
                    } else {
                        completionHandler(false) /// failed to sign in using biometric sign
                    }
                }
            }
        }
    }
}



