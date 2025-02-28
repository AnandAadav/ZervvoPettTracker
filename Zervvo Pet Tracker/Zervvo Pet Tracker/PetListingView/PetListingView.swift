//
//  PetListingView.swift
//  Zervvo Pet Tracker
//
//  Created by Anand on 26/02/25.
//

import SwiftUI
import MapKit
import CoreLocation
import FirebaseStorage
import FirebaseAppCheckInterop
import FirebaseAuthInterop
import FirebaseCore
import GTMSessionFetcherCore
import Kingfisher

// MARK: - Pet List View
struct PetListView: View {
    @StateObject var petViewModel = PetViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search by species or location", text: $searchText)
                        .onChange(of: searchText) { _ in
                            petViewModel.filterPets(by: searchText)
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            petViewModel.filterPets(by: "")
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                if petViewModel.isLoading {
                    ProgressView("Loading pets...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if petViewModel.filteredPets.isEmpty {
                    VStack {
                        Image(systemName: "pawprint.circle")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        
                        Text("No pets found")
                            .font(.headline)
                            .padding(.top)
                        
                        Text("Try adjusting your search or check back later.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(petViewModel.filteredPets) { pet in
                            NavigationLink(destination: PetDetailView(pet: pet)) {
                                PetRowView(pet: pet)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Missing Pets")
            .onAppear {
                petViewModel.fetchAllPets()
            }
        }
    }
}

// MARK: - Pet Row View
struct PetRowView: View {
    let pet: Pet
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageURL = pet.imageURL, let url = URL(string: imageURL) {
                KFImage(url)
                    .resizable()
                    .placeholder {
                        Image(systemName: "pawprint")
                            .font(.largeTitle)
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            } else {
                Image(systemName: "pawprint")
                    .font(.largeTitle)
                    .frame(width: 80, height: 80)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(.headline)
                
                Text(pet.species)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(pet.lastSeenAddress)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text("Missing since: \(dateFormatter.string(from: pet.reportedDate))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}


