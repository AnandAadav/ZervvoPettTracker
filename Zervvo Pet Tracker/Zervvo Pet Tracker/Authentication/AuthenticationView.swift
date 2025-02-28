//
//  AuthenticationView.swift
//  Zervvo Pet Tracker
//
//  Created by Anand on 25/02/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth


// MARK: - Login View
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false
    @State private var showForgotPassword = false
    @State private var resetEmail = ""
    @State private var showResetAlert = false
    @State private var resetAlertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Logo and App Name
                VStack(spacing: 20) {
                    Image(systemName: "pawprint.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                    
                    Text("Zervvo Pet Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Find your missing pets")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)
                .padding(.bottom, 30)
                
                // Form
                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    if !authViewModel.errorMessage.isEmpty {
                        Text(authViewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, -10)
                    }
                    
                    Button(action: {
                        if isRegistering {
                            authViewModel.register(email: email, password: password)
                        } else {
                            authViewModel.login(email: email, password: password)
                        }
                    }) {
                        HStack {
                            if (authViewModel.isLoading && !email.isEmpty) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                            
                            Text(isRegistering ? "Register" : "Login")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
                    
                    Button(action: {
                                    authViewModel.loginAsGuest()
                                }) {
                                    HStack {
                                        if (authViewModel.isLoading && email.isEmpty) {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                .padding(.trailing, 5)
                                        }
                                        
                                        Text("Continue as Guest")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.blue))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                                .disabled(authViewModel.isLoading)
                    
                    Button(action: {
                        isRegistering.toggle()
                    }) {
                        Text(isRegistering ? "Already have an account? Login" : "Don't have an account? Register")
                            .foregroundColor(.blue)
                    }
                    
                    if !isRegistering {
                        Button(action: {
                            showForgotPassword = true
                            resetEmail = email
                        }) {
                            Text("Forgot password?")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Footer
                VStack {
                    Text("By using this app, you agree to our")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 5) {
                        Text("Terms of Service")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("and")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Privacy Policy")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 20)
            }
            .sheet(isPresented: $showForgotPassword) {
                forgotPasswordView
            }
            .alert(isPresented: $showResetAlert) {
                Alert(
                    title: Text("Password Reset"),
                    message: Text(resetAlertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    var forgotPasswordView: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Reset Password")
                    .font(.headline)
                    .padding(.top, 20)
                
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Email", text: $resetEmail)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button(action: {
                    authViewModel.resetPassword(email: resetEmail) { success, message in
                        resetAlertMessage = message
                        showResetAlert = true
                        if success {
                            showForgotPassword = false
                        }
                    }
                }) {
                    Text("Send Reset Link")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(resetEmail.isEmpty)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarItems(trailing: Button("Cancel") {
                showForgotPassword = false
            })
        }
    }
}

// MARK: - Authentication Wrapper View
struct AuthenticationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if (authViewModel.isAuthenticated || authViewModel.isGuestUser) {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
