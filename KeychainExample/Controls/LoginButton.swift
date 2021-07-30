//
//  LoginButton.swift
//  KeychainExample
//
//  Created by Raymond Donkemezuo on 7/29/21.
//

import SwiftUI

struct LoginButton: View {
    @ObservedObject var loginViewModel: LoginViewModel
    var geometry: GeometryProxy
    var buttonPressedBlock: (() -> ())?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var body: some View {
        Button(action: {
            if let block = buttonPressedBlock {
                block()
            }
        }, label: {
            Text("Sign In")
                .frame(width: horizontalSizeClass == .compact ? (geometry.size.height/4) * 0.5 : (geometry.size.width/4) * 0.5  , height: horizontalSizeClass == .compact ? (geometry.size.height/4) * 0.5 : (geometry.size.width/4) * 0.5)
                .contentShape(Rectangle())
                .background(loginViewModel.disableLoginButton ? Color.blue.opacity(0.3) : Color(UIColor.systemBlue).opacity(0.9))
                .cornerRadius(5)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(loginViewModel.disableLoginButton ? Color.primary : .white)
                .disabled(loginViewModel.disableLoginButton)
                .overlay(
                    VStack {
                        if loginViewModel.showingActivityIndicator {
                            ActivityIndicator(isAnimating: $loginViewModel.showingActivityIndicator, style: .large)
                        }
                    }
                )
        })
        .disabled(loginViewModel.disableLoginButton)
    }
}
