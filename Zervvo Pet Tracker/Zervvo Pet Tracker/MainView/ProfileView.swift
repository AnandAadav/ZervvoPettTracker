//
//  ProfileView.swift
//  Zervvo Pet Tracker
//
//  Created by Anand on 27/02/25.
//


import SwiftUI
import MapKit
import CoreLocation
import FirebaseStorage
import Kingfisher

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("ACCOUNT INFORMATION")) {
                    HStack {
                        Text("Username")
                        Spacer()
                        Text("\(authViewModel.user?.email ?? "Guest User")")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        
                        Text("\(authViewModel.user?.email ?? "Guest User")")
                            .foregroundColor(.gray)
                    }
                }
                
                
                Section(header: Text("APP INFORMATION")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("01")
                            .foregroundColor(.gray)
                    }
                }
                
                Section {
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Text("Logout")
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Your Profile")
            
        }
        
    }
}
