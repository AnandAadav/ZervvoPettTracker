//
//  AddPetView.swift
//  Zervvo Pet Tracker
//
//  Created by Anand on 25/02/25.
//

import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore

// MARK: - Location Manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.33233141, longitude: -122.03121860),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @Published var address = ""
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        locationManager.stopUpdatingLocation()
        
        // Reverse geocode to get address
        getAddressFromLocation(location: location)
    }
    
    func getAddressFromLocation(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            
            if let placemark = placemarks?.first {
                let address = [
                    placemark.thoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
                
                DispatchQueue.main.async {
                    self.address = address
                }
            }
        }
    }
    
    func updateLocation(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.location = location
        self.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        // Reverse geocode to get address
        getAddressFromLocation(location: location)
    }
}

// MARK: - Map Selection View
struct MapSelectionView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var isShowingMap: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map(coordinateRegion: $locationManager.region, interactionModes: .all, showsUserLocation: true, annotationItems: [AnnotationItem(coordinate: locationManager.region.center)]) { item in
                    MapMarker(coordinate: item.coordinate, tint: .red)
                }
                .gesture(
                    LongPressGesture(minimumDuration: 0.3)
                        .sequenced(before: DragGesture(minimumDistance: 0))
                        .onEnded { value in
                            switch value {
                            case .second(_, let drag):
                                if let location = drag?.location {
                                    let coordinate = locationManager.region.center
                                    locationManager.updateLocation(coordinate: coordinate)
                                }
                            default:
                                break
                            }
                        }
                )
                
                VStack {
                    Spacer()
                    
                    Text("Location: \(locationManager.address)")
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                        .padding()
                    
                    Button("Confirm Location") {
                        isShowingMap = false
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.bottom)
                }
            }
            .navigationTitle("Select Last Seen Location")
            .navigationBarItems(trailing: Button("Cancel") {
                isShowingMap = false
            })
        }
    }
}

// Helper model for map annotation
struct AnnotationItem: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

// MARK: - Add Pet View
struct AddPetView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var petViewModel = PetViewModel()
    @StateObject var locationManager = LocationManager()
    
    @State private var petName = ""
    @State private var species = ""
    @State private var description = ""
    @State private var contactInfo = ""
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isShowingMap = false
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private var formIsValid: Bool {
        !petName.isEmpty && !species.isEmpty && !description.isEmpty &&
        !contactInfo.isEmpty && locationManager.location != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Pet Information")) {
                    TextField("Pet Name", text: $petName)
                    
                    Picker("Species", selection: $species) {
                        Text("Select").tag("")
                        Text("Dog").tag("Dog")
                        Text("Cat").tag("Cat")
                        Text("Bird").tag("Bird")
                        Text("Other").tag("Other")
                    }
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .overlay(
                            Text(description.isEmpty ? "Description (appearance, collar, microchipped, etc.)" : "")
                                .foregroundColor(.gray)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8),
                            alignment: .topLeading
                        )
                }
                
                Section(header: Text("Last Seen Location")) {
                    Button(locationManager.address.isEmpty ? "Select Location" : locationManager.address) {
                        isShowingMap = true
                    }
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("Phone number or email", text: $contactInfo)
                }
                
                Section(header: Text("Pet Photo")) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                            .padding(.vertical)
                    }
                    
                    Button(selectedImage == nil ? "Add Photo" : "Change Photo") {
                        isImagePickerPresented = true
                    }
                }
                
                Section {
                    Button("Submit") {
                        submitPet()
                    }
                    .disabled(!formIsValid || isSubmitting)
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Report Missing Pet")
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .sheet(isPresented: $isShowingMap) {
                MapSelectionView(locationManager: locationManager, isShowingMap: $isShowingMap)
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Missing Pet Report"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func submitPet() {
        guard let location = locationManager.location else {
            alertMessage = "Please select a location"
            showAlert = true
            return
        }
        
        isSubmitting = true
        
        let geoPoint = GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        let pet = Pet(
            name: petName,
            species: species,
            description: description,
            lastSeenLocation: geoPoint,
            lastSeenAddress: locationManager.address,
            contactInfo: contactInfo,
            reportedBy: "",  // Will be set in the ViewModel
            reportedDate: Date()
        )
        
        petViewModel.addPet(pet: pet, image: selectedImage) { success, message in
            isSubmitting = false
            alertMessage = message
            showAlert = true
            
            if success {
                // Reset form
                petName = ""
                species = ""
                description = ""
                contactInfo = ""
                selectedImage = nil
            }
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
