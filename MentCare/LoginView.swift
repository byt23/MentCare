//
//  LoginView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @State private var email = ""
    @State private var pin = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // 1. Arka Plan: Modern Gradyan ve "Blur" (Bulanıklık) Efekti
            LinearGradient(colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            Circle()
                .fill(Color.teal.opacity(0.4))
                .frame(width: 300)
                .blur(radius: 60)
                .offset(x: -200, y: -150)
            
            Circle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 400)
                .blur(radius: 80)
                .offset(x: 200, y: 150)
            
            // 2. Cam Efektli (Glassmorphism) Giriş Kartı
            VStack(spacing: 25) {
                
                // İkon: Tıbbi Haç ve Güvenlik Kalkanı
                ZStack {
                    Image(systemName: "cross.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.cyan)
                    
                    Image(systemName: "checkmark.shield.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                        .offset(x: 20, y: 20)
                }
                .padding(.bottom, 10)
                
                // Başlıklar
                VStack(spacing: 5) {
                    Text("MentCare System")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Authorized Personnel Login")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Hata Mesajı
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                
                // Girdi Alanları
                VStack(spacing: 15) {
                    // Email Alanı
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        
                        #if os(iOS)
                        TextField("Staff Email", text: $email)
                            .textFieldStyle(.plain)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        #else
                        TextField("Staff Email", text: $email)
                            .textFieldStyle(.plain)
                        #endif
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(10)
                    
                    // Şifre Alanı
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        
                        SecureField("PIN / Password", text: $pin)
                            .textFieldStyle(.plain)
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(10)
                    
                    // Şifremi Unuttum Metni
                    HStack {
                        Spacer()
                        Button("Forgot PIN?") {
                            // Şifre sıfırlama işlemi eklenecek
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                        .buttonStyle(.plain) // Mac'te buton arka planını temizlemek için
                    }
                }
                
                // Giriş Butonu
                Button(action: performLogin) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Secure Login")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(email.isEmpty || pin.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(email.isEmpty || pin.isEmpty)
                
                // Alt Bilgi
                Text("M4 Encrypted Connection Active")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
            }
            .padding(40)
            // Asıl cam efektini veren sihirli kod:
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
            .frame(maxWidth: 400) // Mac ve iPad'de çok genişlemesini engeller
            .padding()
        }
    }
    
    private func performLogin() {
        isLoading = true
        errorMessage = ""
        
        authManager.login(email: email, pin: pin) { success, error in
            isLoading = false
            if !success {
                errorMessage = error ?? "Login failed. Please check your credentials."
            }
        }
    }
}
