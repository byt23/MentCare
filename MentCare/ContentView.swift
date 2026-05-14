//
//  ContentView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import SwiftUI
import SwiftData

enum MenuCategory: Hashable {
    case dashboard, patients, prescriptions, reports
}

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedMenu: MenuCategory? = .dashboard
    
    var body: some View {
        let currentAuth = authManager
        
        NavigationSplitView {
            List(selection: $selectedMenu) {
                NavigationLink(value: MenuCategory.dashboard) {
                    Label("Dashboard", systemImage: "square.grid.2x2")
                }
                
                NavigationLink(value: MenuCategory.patients) {
                    Label("Patients", systemImage: "person.2.fill")
                }
                
                if currentAuth.currentUserRole == "Doctor" {
                    NavigationLink(value: MenuCategory.prescriptions) {
                        Label("Prescriptions", systemImage: "pills.fill")
                    }
                }
                
                if currentAuth.currentUserRole == "Manager" {
                    NavigationLink(value: MenuCategory.reports) {
                        Label("Reports", systemImage: "chart.bar.doc.horizontal")
                    }
                }
            }
            .navigationTitle("MentCare Clinic")
            
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Divider()
                    
                    Button(action: {
                        currentAuth.logout()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left.square.fill")
                            VStack(alignment: .leading) {
                                Text("Logout")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                Text(currentAuth.currentUserRole)
                                    .font(.caption2)
                                    .opacity(0.7)
                            }
                            Spacer()
                        }
                        .padding()
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                }
                .background(.ultraThinMaterial)
            }
            
        } detail: {
            switch selectedMenu {
            case .dashboard:
                DashboardView()
            case .patients:
                PatientListView()
            case .prescriptions:
                VStack {
                    Image(systemName: "pills.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    Text("Prescription Management")
                        .font(.title)
                    Text("Doctor ID: \(currentAuth.currentStaffID)")
                        .foregroundColor(.secondary)
                }
            case .reports:
                VStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.purple)
                    Text("Management Dashboard")
                        .font(.title)
                    Text("Admin Access: Confirmed")
                        .foregroundColor(.secondary)
                }
            case .none:
                Text("Select a module to continue")
                    .foregroundColor(.secondary)
            }
        }
    }
}
#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
