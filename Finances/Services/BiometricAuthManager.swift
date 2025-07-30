//
//  BiometricAuthManager.swift
//  Finances
//
//  Created by Felipe Felicio on 17/07/25.
//

import LocalAuthentication
import Security
import UIKit

class BiometricAuthManager {
    
    // MARK: - Singleton
    static let shared = BiometricAuthManager()
    private init() {}
    
    // MARK: - Keychain Keys
    private let biometricCredentialsKey = "biometric_user_credentials"
    
    // MARK: - Biometric Availability
    func isBiometricAvailable() -> (isAvailable: Bool, biometryType: LABiometryType, error: String?) {
        let context = LAContext()
        var error: NSError?
        
        // Check if device supports biometric authentication
        let isAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        if let error = error {
            return (false, .none, error.localizedDescription)
        }
        
        return (isAvailable, context.biometryType, nil)
    }
    
    // MARK: - Save Credentials to Keychain
    func saveBiometricCredentials(email: String, password: String, name: String) -> Bool {
        let credentials = "\(email):\(password):\(name)"
        guard let data = credentials.data(using: .utf8) else { return false }
        
        // Delete existing credentials first
        deleteBiometricCredentials()
        
        // Keychain query for saving
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: biometricCredentialsKey,
            kSecValueData as String: data,
            kSecAttrAccessControl as String: createAccessControl()
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Load Credentials from Keychain
    func loadBiometricCredentials(completion: @escaping (String?, String?, String?) -> Void) {
        let context = LAContext()
        context.localizedReason = "Access your saved credentials"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: biometricCredentialsKey,
            kSecReturnData as String: true,
            kSecUseAuthenticationContext as String: context
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let credentials = String(data: data, encoding: .utf8) {
            
            let components = credentials.components(separatedBy: ":")
            if components.count == 3 {
                completion(components[0], components[1], components[2]) // email, password, name
                return
            }
        }
        
        completion(nil, nil, nil)
    }
    
    // MARK: - Delete Credentials
    func deleteBiometricCredentials() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: biometricCredentialsKey
        ]
        
        SecItemDelete(query as CFDictionary)
    }
    
    // MARK: - Access Control
    private func createAccessControl() -> SecAccessControl {
        return SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryAny,
            nil
        )!
    }
    
    // MARK: - Authenticate with Biometrics
    func authenticateWithBiometrics(completion: @escaping (Bool, String?) -> Void) {
        let context = LAContext()
        let reason = "Use biometrics to access your account quickly and securely"
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(true, nil)
                } else {
                    let errorMessage = error?.localizedDescription ?? "Biometric authentication failed"
                    completion(false, errorMessage)
                }
            }
        }
    }
}
