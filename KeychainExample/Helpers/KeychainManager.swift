//
//  KeychainHandler.swift
//  KeychainExample
//
//  Created by Raymond Donkemezuo on 7/29/21.
//

import Foundation

/// - TAG: A class that handles the saving, fetching, deleting and updating of keychain
class KeychainManager {

    struct Constants {
        static let keychain_account_name_key = "keychain_account" /// The acocunt name in the keychain where we are storing the login credentials. Can be named as appropriate
        static let userNameKey = "userName" /// The key to our stored username value
        static let passwordKey = "password" /// The key to our stored password value
        static let areCredentialsSavedInKeychainKey = "areCredentialsSavedInKeychain" /// The key to our userDefault path which tells us if we saved credentials on keychain for this app.
        /// The aim is to enable us clear our keychain records if the app get's deleted by the user
    }

    static let shared = KeychainManager()
    /// A variable that detect if password is stored in keychain
    var areCredentialsSavedInKeychain = false
    let userDefaults = UserDefaults.standard

    /// - TAG: A method that saves the login credentials into keychain
    /// - parameters: username - username string to be stored in chain
    /// - parameters: password - password string to be stored in keychain
    func saveCredentialsToKeychain(_ username: String, _ password: String, completionHandler: @escaping(Bool) -> ()) {
        let userAccountName = Constants.keychain_account_name_key
        let userCredentialsDict: [String: Any] = [Constants.userNameKey: username, Constants.passwordKey: password] /// The dictionary holding our credentials data to be stored in the keychain
        let credentialsInData = try! NSKeyedArchiver.archivedData(withRootObject: userCredentialsDict, requiringSecureCoding: false) /// Converts our dictionary into Data
        let keychainQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword as String,
                                            kSecAttrAccount as String: userAccountName,
                                            kSecValueData as String: credentialsInData]
        SecItemDelete(keychainQuery as CFDictionary)
        let status: OSStatus = SecItemAdd(keychainQuery as CFDictionary, nil) /// Adds login credentials into keychain and returns the status
        if status == noErr { /// no error. Succesfully added to keychain
            self.registerKeychainSaveInUserDefaults()
            completionHandler(true)
            return;
        } else {
            print("Key chain did not save") /// Replace this implementation with code to handle the error appropriately
            completionHandler(false)
        }
    }

    /// - TAG: A method that saves a boolean value in userDefault if we successfully save to keychain
    func registerKeychainSaveInUserDefaults() {
        userDefaults.setValue(true, forKey: Constants.areCredentialsSavedInKeychainKey)
    }

    func didSavedCredentialsOnKeychain() -> Bool {
        return userDefaults.bool(forKey: Constants.areCredentialsSavedInKeychainKey)
    }

    /// - TAG: A method that fetches the stored data in our keychain account and return as a dictionary
    private func fetchKeychainAccountData() -> [String: Any]? {
        let queryToKeychainAccount: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                                     kSecAttrAccount as String: Constants.keychain_account_name_key,
                                                     kSecReturnData as String: kCFBooleanTrue ?? true,
                                                     kSecMatchLimit as String: kSecMatchLimitOne]
        var dataTypeReference: AnyObject? /// The data type to pass to query
        let status: OSStatus = SecItemCopyMatching(queryToKeychainAccount as CFDictionary, &dataTypeReference) /// Makes query to keychain to retrieve the data stored in our keychain account
        if status == noErr { /// request was successful and no error was encountered
            guard let data = dataTypeReference as? Data else
            {
                return nil
            }
            do {
                let dataDict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String: Any]
                return dataDict
            } catch {
                print("Error \(error.localizedDescription) while decoding data") /// Replace this implementation with code to handle the error appropriately
                return nil;
            }

        } else {
            return nil
        }
    }

    /// - TAG: A method that returns the stored username and password strings
    func fetchLoginCredentialsFromKeychain() -> (username: String, password: String)? {

        guard didSavedCredentialsOnKeychain() else {
            /// clear keychain items
            deleteAllKeyChainItems()
            return nil;
        }

        guard let loginCredentialsInKeychainAccount = fetchKeychainAccountData() else
        {
            return nil
        }
        guard let storedUserName = loginCredentialsInKeychainAccount[Constants.userNameKey] as? String,
              let storedPassword = loginCredentialsInKeychainAccount[Constants.passwordKey] as? String else
        {
            return nil
        }
        self.areCredentialsSavedInKeychain = true 
        return (username: storedUserName, password: storedPassword)
    }

    /// - TAG: A method that updates the stored username and password in keychain
    func updateCredentialsInKeychain(_ userName: String, _ password: String, completionHandler: @escaping(_ didUpdate: Bool) -> ()) {
        let keychainAccountQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                                   kSecAttrAccount as String: Constants.keychain_account_name_key]
        let updatingCredentialsDict: [String: Any] = [Constants.userNameKey: userName, Constants.passwordKey: password]
        let updatingData: Data = try! NSKeyedArchiver.archivedData(withRootObject: updatingCredentialsDict, requiringSecureCoding: false)
        let updatingFields: [String: Any] = [kSecAttrAccount as String: Constants.keychain_account_name_key,
                                             kSecValueData as String: updatingData]
        let status = SecItemUpdate(keychainAccountQuery as CFDictionary, updatingFields as CFDictionary)
        if status == noErr {
            print("Successfully updated")
            completionHandler(_: true)
        } else {
            print("Error encountered while trying to update keychain value")
            completionHandler(_: false)
        }
    }

    /// - TAG: A method that deletes all stored keychain records
    func deleteAllKeyChainItems() {
        let secItemClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }
    }

}
