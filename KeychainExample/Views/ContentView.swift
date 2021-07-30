//
//  ContentView.swift
//  KeychainExample
//
//  Created by Raymond Donkemezuo on 7/29/21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var usermanager: UserAuthenticationManager
    var body: some View {
        VStack{
            if usermanager.userLoggedIn {
                HomeView()
            } else {
                SigninView()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class UserAuthenticationManager: ObservableObject {
    static let shared = UserAuthenticationManager()
    @Published var userLoggedIn = false
}
