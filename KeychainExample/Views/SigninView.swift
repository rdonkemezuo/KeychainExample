//
//  SigninView.swift
//  KeychainExample
//
//  Created by Raymond Donkemezuo on 7/29/21.
//

import SwiftUI

struct SigninView: View {
    @ObservedObject var signinViewModel = LoginViewModel()
    @EnvironmentObject var usermanager: UserAuthenticationManager
    var body: some View {
        GeometryReader { geomery in
            ZStack(alignment: .center) {
                ScrollView(.vertical) {
                    VStack(alignment: .center) {
                        UserNameTextField(caption: "UserName", value: $signinViewModel.username)
                        PasswordTextField(caption: "Password", value: $signinViewModel.password)
                        LoginButton(loginViewModel: signinViewModel, geometry: geomery) {
                            signinViewModel.authenticateUser { _ in
                            }
                        }
                    }.frame(width: geomery.size.width, height: geomery.size.height, alignment: .center)
                }.frame(width: geomery.size.width, height: geomery.size.height, alignment: .center)
                .padding()
            }.frame(width: geomery.size.width, height: geomery.size.height, alignment: .center)
            CustomAlertView(loginViewModel: signinViewModel)
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Color.secondary)
    }
}


