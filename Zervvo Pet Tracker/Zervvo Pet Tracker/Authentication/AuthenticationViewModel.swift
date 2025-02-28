//
//  AuthenticationViewModel.swift
//  Zervvo Pet Tracker
//
//  Created by Anand on 25/02/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

// MARK: - Authentication View Model
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isGuestUser = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    init() {
        setupFirebaseAuthListener()
    }
    
    func setupFirebaseAuthListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.user = user
                self?.isAuthenticated = user != nil
                
            }
        }
    }
    
    func loginAsGuest() {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signInAnonymously { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isGuestUser = true
                // Guest user logged in successfully
                self?.errorMessage = ""
                return
            }
        }
    }
    
    func register(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                // User registered successfully
                self?.errorMessage = ""
            }
        }
    }
    
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                // User logged in successfully
                self?.errorMessage = ""
            }
        }
    }
    
    func signOut() {
        
        if(!self.isGuestUser) {
            do {
                try Auth.auth().signOut()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        else
        {
            
            DispatchQueue.main.async {
                self.isAuthenticated = false
                self.isGuestUser = false
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Bool, String) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(false, error.localizedDescription)
            } else {
                completion(true, "Password reset email sent. Check your inbox.")
            }
        }
    }
}



