//
//  ContentView.swift
//  MentCare
//
//  Created by BERKAY TURAN on 14.05.2026.
//

import SwiftUI
import SwiftData

enum MenuCategory: Hashable {
    case dashboard, patients, calendar, prescriptions, reports, logout
}

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedMenu: MenuCategory? = .dashboard
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    var body: some View {
        let currentAuth = authManager
        
        #if os(iOS)
        if horizontalSizeClass == .compact {
            tabBarLayout(currentAuth: currentAuth)
        } else {
            sidebarLayout(currentAuth: currentAuth)
        }
        #else
        sidebarLayout(currentAuth: currentAuth)
        #endif
    }
    
    @ViewBuilder
    private func sidebarLayout(currentAuth: AuthManager) -> some View {
        NavigationSplitView {
            List(selection: $selectedMenu) {
                navigationLinks(currentAuth: currentAuth)
            }
            .navigationTitle("MentCare Clinic")
            .safeAreaInset(edge: .bottom) {
                logoutButton(currentAuth: currentAuth)
            }
        } detail: {
            detailView(currentAuth: currentAuth)
        }
    }
    
    @ViewBuilder
    private func tabBarLayout(currentAuth: AuthManager) -> some View {
        TabView(selection: $selectedMenu) {
            DashboardView()
                .tabItem { Label("Dash", systemImage: "square.grid.2x2") }
                .tag(MenuCategory.dashboard)
            
            PatientListView()
                .tabItem { Label("Patients", systemImage: "person.2.fill") }
                .tag(MenuCategory.patients)
            
            ClinicCalendarView()
                .tabItem { Label("Calendar", systemImage: "calendar") }
                .tag(MenuCategory.calendar)
            
            if currentAuth.currentUserRole == "Doctor" {
                Text("Prescriptions Area")
                    .tabItem { Label("Med", systemImage: "pills.fill") }
                    .tag(MenuCategory.prescriptions)
            }
            
            // iPhone için Logout Sekmesi
            Color.clear
                .tabItem { Label("Logout", systemImage: "rectangle.portrait.and.arrow.right") }
                .tag(MenuCategory.logout)
        }
        .onChange(of: selectedMenu) { oldValue, newValue in
            if newValue == .logout {
                currentAuth.logout()
            }
        }
    }
    
    @ViewBuilder
    private func navigationLinks(currentAuth: AuthManager) -> some View {
        NavigationLink(value: MenuCategory.dashboard) {
            Label("Dashboard", systemImage: "square.grid.2x2")
        }
        NavigationLink(value: MenuCategory.patients) {
            Label("Patients", systemImage: "person.2.fill")
        }
        NavigationLink(value: MenuCategory.calendar) {
            Label("Clinic Calendar", systemImage: "calendar")
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
    
    @ViewBuilder
    private func detailView(currentAuth: AuthManager) -> some View {
        switch selectedMenu {
        case .dashboard: DashboardView()
        case .patients: PatientListView()
        case .calendar: ClinicCalendarView()
        case .prescriptions:
            VStack {
                Image(systemName: "pills.fill").font(.system(size: 50)).foregroundColor(.blue)
                Text("Prescription Management").font(.title)
                Text("Doctor ID: \(currentAuth.currentStaffID)").foregroundColor(.secondary)
            }
        case .reports:
            VStack {
                Image(systemName: "chart.bar.fill").font(.system(size: 50)).foregroundColor(.purple)
                Text("Management Dashboard").font(.title)
                Text("Admin Access: Confirmed").foregroundColor(.secondary)
            }
        case .logout: // Logout durumu için boş görünüm
            Text("Logging out...")
        case .none:
            Text("Select a module to continue").foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private func logoutButton(currentAuth: AuthManager) -> some View {
        VStack(spacing: 0) {
            Divider()
            Button(action: { currentAuth.logout() }) {
                HStack {
                    Image(systemName: "arrow.left.square.fill")
                    VStack(alignment: .leading) {
                        Text("Logout").font(.body).fontWeight(.semibold)
                        Text(currentAuth.currentUserRole).font(.caption2).opacity(0.7)
                    }
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(.plain)
            .foregroundColor(.red)
        }
        .background(.ultraThinMaterial)
    }
}
#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
