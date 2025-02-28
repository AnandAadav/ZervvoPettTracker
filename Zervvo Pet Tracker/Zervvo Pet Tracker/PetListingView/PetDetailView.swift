//
//  PetDetailView.swift
//  Zervvo Pet Tracker
//
//  Created by Anand on 27/02/25.
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

// MARK: - Pet Detail View
struct PetDetailView: View {
    let pet: Pet
    @State private var region: MKCoordinateRegion
    
    init(pet: Pet) {
        self.pet = pet
        let coordinate = CLLocationCoordinate2D(
            latitude: pet.lastSeenLocation.latitude,
            longitude: pet.lastSeenLocation.longitude
        )
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Pet Image
                if let imageURL = pet.imageURL, let url = URL(string: imageURL) {
                    KFImage(url)
                        .resizable()
                        .placeholder {
                            ProgressView()
                                .frame(height: 250)
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .clipped()
                } else {
                    Image(systemName: "pawprint.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                // Pet Info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Label(pet.name, systemImage: "tag.fill")
                            .font(.title)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(pet.species)
                            .font(.headline)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Divider()
                    
                    Text("Description")
                        .font(.headline)
                    
                    Text(pet.description)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("Last Seen")
                        .font(.headline)
                    
                    Label(pet.lastSeenAddress, systemImage: "mappin.and.ellipse")
                        .foregroundColor(.secondary)
                    
                    Text("Date reported: \(formattedDate)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Map
                    Map(coordinateRegion: $region, annotationItems: [AnnotationItem(coordinate: region.center)]) { item in
                        MapMarker(coordinate: item.coordinate, tint: .red)
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .padding(.top, 8)
                    
                    Divider()
                    
                    Text("Contact Information")
                        .font(.headline)
                    
                    Label(pet.contactInfo, systemImage: "person.crop.circle")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .navigationTitle("Missing Pet Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: pet.reportedDate)
    }
}
