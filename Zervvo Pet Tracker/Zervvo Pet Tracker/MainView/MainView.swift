//
//  MainView.swift
//  Zervvo Pet Tracker
//
//  Created by Anand on 25/02/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

// MARK: - Main Tab View
struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            PetListView()
                .tabItem {
                    Label("Missing Pets", systemImage: "pawprint")
                }
            
            AddPetView()
                .tabItem {
                    Label("Report Missing", systemImage: "plus.circle")
                }
                .disabled(Auth.auth().currentUser?.uid == nil )
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}


// MARK: - App Entry Point
@main
struct MissingPetsApp: App {
    @StateObject var authViewModel = AuthViewModel()
    
    init() {
        setupFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
                .environmentObject(authViewModel)
        }
    }
    
    private func setupFirebase() {
        // Configure Firebase
        // Note: In a real app, you would need a GoogleService-Info.plist file
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        FirebaseApp.configure()
    }
}

// MARK: - Additional ContentView for SwiftUI Preview
struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        AuthenticationView()
            .environmentObject(authViewModel)
    }
}

// MARK: - SwiftUI Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
