//
//  PetListingViewModel.swift
//  Zervvo Pet Tracker
//
//  Created by Anand on 26/02/25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift
import FirebaseStorage
import FirebaseCore
import FirebaseFirestoreInternalWrapper
import FirebaseAuth
import CoreLocation
import UIKit

// MARK: - Models
struct Pet: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var species: String
    var description: String
    var lastSeenLocation: GeoPoint
    var lastSeenAddress: String
    var contactInfo: String
    var imageURL: String?
    var reportedBy: String // User ID who reported
    var reportedDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case species
        case description
        case lastSeenLocation
        case lastSeenAddress
        case contactInfo
        case imageURL
        case reportedBy
        case reportedDate
    }
}

// MARK: - Pet View Model
class PetViewModel: ObservableObject {
    @Published var pets: [Pet] = []
    @Published var filteredPets: [Pet] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    

    func fetchAllPets() {
        isLoading = true
        db.collection("pets")
            .order(by: "reportedDate", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = "Error fetching pets: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self.errorMessage = "No pets found"
                        return
                    }
                    
                    self.pets = documents.compactMap { document -> Pet? in
                        try? document.data(as: Pet.self)
                    }
                    
                    // Show all pets if the user is a guest (not logged in)
                    if Auth.auth().currentUser == nil {
                        self.filteredPets = self.pets
                    } else {
                        self.filteredPets = self.pets.filter { $0.reportedBy == Auth.auth().currentUser?.uid }
                    }
                }
            }
    }

    // Add a new pet
    func addPet(pet: Pet, image: UIImage?, completion: @escaping (Bool, String) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false, "User not authenticated")
            return
        }
        
        var newPet = pet
        newPet.reportedBy = userId
        newPet.reportedDate = Date()
        
        // First upload the image if available
        if let image = image {
            uploadImage(image: image) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let url):
                    newPet.imageURL = url
                    self.savePetToFirestore(pet: newPet, completion: completion)
                case .failure(let error):
                    completion(false, "Failed to upload image: \(error.localizedDescription)")
                }
            }
        } else {
            savePetToFirestore(pet: newPet, completion: completion)
        }
    }
    
    private func savePetToFirestore(pet: Pet, completion: @escaping (Bool, String) -> Void) {
        do {
            _ = try db.collection("pets").addDocument(from: pet)
            completion(true, "Pet added successfully")
        } catch {
            completion(false, "Failed to save pet: \(error.localizedDescription)")
        }
    }
    
    private func uploadImage(image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            completion(.failure(NSError(domain: "com.missingpets", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
            return
        }
        
        let imageName = UUID().uuidString
        let storageRef = storage.reference().child("pet_images/\(imageName).jpg")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "com.missingpets", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                    return
                }
                
                completion(.success(downloadURL.absoluteString))
            }
        }
    }
    
    // Filter pets by species or location
    func filterPets(by searchText: String) {
        if searchText.isEmpty {
            filteredPets = pets
            return
        }
        
        filteredPets = pets.filter { pet in
            pet.species.lowercased().contains(searchText.lowercased()) ||
            pet.lastSeenAddress.lowercased().contains(searchText.lowercased())
        }
    }
}
