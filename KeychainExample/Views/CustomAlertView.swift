//
//  CustomAlertView.swift
//  KeychainExample
//
//  Created by Raymond Donkemezuo on 7/30/21.
//

import Foundation
import SwiftUI


struct CustomAlertView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @EnvironmentObject var usermanager: UserAuthenticationManager
    var body: some View {
        VStack {

        }.alert(isPresented: $loginViewModel.showAlert) {
            switch loginViewModel.alert {

            case .missingCredentials(_):
                return Alert(title: Text(loginViewModel.alert.alertTitle), message: Text(loginViewModel.alert.alertMessage), dismissButton: .default(Text("Okay"), action: {
                    return;
                }))

            case .saveKeychain:
                return Alert(title: Text(loginViewModel.alert.alertTitle), message: Text(loginViewModel.alert.alertMessage), primaryButton: .default(Text("No"), action: {
                    usermanager.userLoggedIn = true
                }), secondaryButton: .default(Text("Save"), action: {
                    loginViewModel.callSaveLoginCredentialsToKeychain()
                }))

            case .successfulLogin:
                return Alert(title: Text(loginViewModel.alert.alertTitle), message: Text(loginViewModel.alert.alertMessage), dismissButton: .default(Text("Okay"), action: {
                    usermanager.userLoggedIn = true
                }))

            case .biometricAuth(_):
                return Alert(title: Text(loginViewModel.alert.alertTitle), message: Text(loginViewModel.alert.alertMessage), primaryButton: .default(Text("Not Now"), action: {
                    loginViewModel.callRejectedAuthenticationRequest()
                    usermanager.userLoggedIn = true
                }), secondaryButton: .default(Text("Setup Now"), action: {
                    loginViewModel.callSetupBiometricAuthentication()
                }))
            }
        }
    }

}
