//
//  UserProfileViewModel.swift
//  Finances
//
//  Created by Felipe Felicio on 18/07/25.
//

import Foundation
import UIKit

class UserProfileViewModel: ObservableObject {
    
    // MARK: - Properties
    private let coreDataManager = CoreDataManager.shared
    @Published var profileImage: UIImage?
    @Published var userName: String = "User"
    
    // MARK: - Methods
    func loadUserData() {
        loadUserName()
        loadProfileImage()
    }
    
    private func loadUserName() {
        if let savedName = UserDefaults.standard.string(forKey: "user_name"), !savedName.isEmpty {
            userName = savedName
        } else {
            // Fallback to email if no saved name
            if let email = getCurrentUserEmail() {
                userName = email.components(separatedBy: "@").first?.capitalized ?? "User"
            }
        }
    }
    
    private func loadProfileImage() {
        if let user = coreDataManager.fetchUser(),
           let filename = user.profileImageFilename,
           let image = loadImageFromDisk(filename: filename) {
            profileImage = image
        } else {
            profileImage = UIImage(systemName: "person.circle.fill")
        }
    }
    
    func updateProfileImage(_ image: UIImage) {
        if let filename = saveImageToDisk(image: image) {
            coreDataManager.updateUserProfileImage(filename: filename)
            profileImage = image
        }
    }
    
    // MARK: - Helper Methods
    private func getCurrentUserEmail() -> String? {
        // This function will be implemented when integrating with Auth
        return nil
    }
    
    private func saveImageToDisk(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let filename = UUID().uuidString + ".jpg"
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    private func loadImageFromDisk(filename: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(filename)
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
