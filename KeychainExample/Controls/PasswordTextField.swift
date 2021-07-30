//
//  PasswordTextField.swift
//  KeychainExample
//
//  Created by Raymond Donkemezuo on 7/29/21.
//

import SwiftUI

struct PasswordTextField: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var caption: String
    @Binding var value: String
    @State var shouldHidePassword: Bool = true
    var body: some View {
        if (horizontalSizeClass == .compact) {
            VStack(alignment: .leading) {
                Text(caption)
                    .frame(width: 100).frame(alignment: .leading)
                    .lineLimit(10)
                if shouldHidePassword {
                    SecureField("", text: $value)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .modifier(HidePassword(shouldHidePassword: $shouldHidePassword, text: $value))
                } else {
                    TextField("", text: $value)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .modifier(HidePassword(shouldHidePassword: $shouldHidePassword, text: $value))
                }

            }.padding()

        } else {
            HStack {
                Text("\(caption):")
                    .frame(width: 100).frame(alignment: .trailing)
                    .lineLimit(10)
                if shouldHidePassword {
                    SecureField("", text: $value)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .modifier(HidePassword(shouldHidePassword: $shouldHidePassword, text: $value))
                } else {
                    TextField("", text: $value)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .modifier(HidePassword(shouldHidePassword: $shouldHidePassword, text: $value))
                }
            }.padding()
        }
    }
}
struct HidePassword: ViewModifier {
    @Binding var shouldHidePassword: Bool
    @Binding var text: String
    public func body(content: Content) -> some View {
        ZStack(alignment: .trailing) {
            content
            if !text.isEmpty {
            Button(action: {
                shouldHidePassword.toggle()
            }, label: {
                Image(systemName: shouldHidePassword == true ? "eye.fill": "eye.slash.fill")
                    .foregroundColor(.primary)
                    .padding(.trailing, 8)
            })
        }
        }
    }
}

struct PasswordTextField_Previews: PreviewProvider {
    static var previews: some View {
        PasswordTextField(caption: "", value: .constant(""))
    }
}
