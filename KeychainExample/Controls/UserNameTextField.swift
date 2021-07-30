//
//  UserNameTextField.swift
//  KeychainExample
//
//  Created by Raymond Donkemezuo on 7/29/21.
//

import Foundation
import SwiftUI

struct UserNameTextField: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var caption: String
    @Binding var value: String
    var body: some View {
        if (horizontalSizeClass == .compact) {
            VStack(alignment: .leading) {
                Text(caption)
                    .frame(width: 100).frame(alignment: .leading)
                    .lineLimit(10)
                TextField("", text: $value)                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding()

        } else {
            HStack {
                Text("\(caption):")
                    .frame(width: 100).frame(alignment: .trailing)
                    .lineLimit(10)
                TextField("", text: $value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }.padding()
        }
    }
}
