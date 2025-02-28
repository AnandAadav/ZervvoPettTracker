# ZervvoPetTracker 

Find Your Missing Pets

Zervvo Pet Tracker is a SwiftUI-based iOS application that helps users report and find missing pets. The app utilizes Firebase for authentication, data storage, and image hosting.

Features

* User authentication (Login, Registration, Password Reset)
* Report missing pets with location and photo
* View a list of missing pets
* View pet details including last seen location on a map
* User profile management
  
Requirements

* macOS with Xcode installed
* iOS 15.0+ deployment target
* Swift 5+
* Firebase account with Firestore and Storage configured
* GoogleService-Info.plist (Firebase configuration file)
  
Installation

1. Clone the repository: git clone https://github.com/your-repo/zervvo-pet-tracker.git
2. cd zervvo-pet-tracker
3. Open the project in Xcode: open ZervvoPetTracker.xcodeproj
4. Install dependencies using CocoaPods: pod install Open the .xcworkspace file instead of .xcodeproj after running this.
5. Add Firebase Configuration:
    * Download GoogleService-Info.plist from your Firebase project.
    * Place it in the Xcode project's root directory.
6. Enable Firebase Services:
    * Firestore Database
    * Firebase Authentication (Email/Password Sign-in)
    * Firebase Storage (for pet images)
      
Running the App

1. Select a simulator or connected iOS device in Xcode.
2. Click Run (⌘ + R) to build and launch the app.
   
Project Structure

Zervvo Pet Tracker

│── Views
│   ├── AuthenticationView.swift  # Login/Register UI
│   ├── MainView.swift            # Tab-based navigation
│   ├── ProfileView.swift         # User profile screen
│   ├── AddPetView.swift          # Report missing pet
│   ├── PetListingView.swift      # List of missing pets
│   ├── PetDetailView.swift       # Detailed pet info with map
│── ViewModels
│   ├── AuthenticationViewModel.swift # Handles user authentication
│   ├── PetListingViewModel.swift      # Fetch and filter missing pets
│── Models
│   ├── Pet.swift  # Defines the Pet model
│── Resources
│   ├── GoogleService-Info.plist  # Firebase config (not included in repo)
│── ZervvoPetTrackerApp.swift  # App entry point


Notes

* Ensure location services are enabled for accurate reporting.
* The app currently supports only English.
 

