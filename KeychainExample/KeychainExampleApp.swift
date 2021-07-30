//
//  KeychainExampleApp.swift
//  KeychainExample
//
//  Created by Raymond Donkemezuo on 7/29/21.
//

import SwiftUI

@main
struct KeychainExampleApp: App {
    let userManager: UserAuthenticationManager = UserAuthenticationManager.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userManager)
        }
    }
}
