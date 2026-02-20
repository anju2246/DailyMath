import SwiftUI
import Combine

// MARK: - Profile View

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showEditProfile = false
    @State private var showDeleteConfirmation = false
    
    private var user: UserProfile? { appState.currentUser }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Avatar & Name
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Text(user?.displayName?.prefix(1).uppercased() ?? "?")
                                .font(.largeTitle.bold())
                                .foregroundStyle(.white)
                        }
                        
                        Text(user?.displayName ?? "Usuario")
                            .font(.title2.bold())
                        
                        if let university = user?.university, !university.isEmpty {
                            Label(university, systemImage: "building.columns")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Level badge
                        if let user = user {
                            HStack(spacing: 6) {
                                Image(systemName: user.userLevel.icon)
                                Text(user.userLevel.name)
                                Text("•")
                                Text("\(user.points) pts")
                            }
                            .font(.subheadline.bold())
                            .foregroundStyle(.tint)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.top)
                    
                    // Stats Grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        StatCard(title: "Puntos", value: "\(user?.points ?? 0)", icon: "star.fill", color: .orange)
                        StatCard(title: "Racha", value: "\(user?.studyStreak ?? 0) días", icon: "flame.fill", color: .red)
                        StatCard(title: "Nivel", value: user?.userLevel.name ?? "—", icon: "trophy.fill", color: .yellow)
                    }
                    .padding(.horizontal)
                    
                    // Menu items
                    VStack(spacing: 2) {
                        MenuRow(icon: "pencil", title: "Editar perfil", color: .blue) {
                            showEditProfile = true
                        }
                        
                        MenuRow(icon: "medal", title: "Insignias", color: .orange) {
                            // TODO: Navigate to badges
                        }
                        
                        MenuRow(icon: "chart.bar", title: "Estadísticas", color: .green) {
                            // TODO: Navigate to stats
                        }
                        
                        if appState.isModerator {
                            MenuRow(icon: "shield.checkered", title: "Panel de Moderador", color: .purple) {
                                // TODO: Navigate to moderator dashboard
                            }
                        }
                    }
                    .cardStyle()
                    .padding(.horizontal)
                    
                    // Danger zone
                    VStack(spacing: 2) {
                        MenuRow(icon: "rectangle.portrait.and.arrow.right", title: "Cerrar sesión", color: .secondary) {
                            Task { try? await appState.authService.signOut() }
                        }
                        
                        MenuRow(icon: "trash", title: "Eliminar cuenta", color: .red) {
                            showDeleteConfirmation = true
                        }
                    }
                    .cardStyle()
                    .padding(.horizontal)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Perfil")
            .alert("¿Eliminar cuenta?", isPresented: $showDeleteConfirmation) {
                Button("Cancelar", role: .cancel) { }
                Button("Eliminar", role: .destructive) {
                    Task { try? await appState.authService.deleteAccount() }
                }
            } message: {
                Text("Esta acción es permanente. Se eliminarán todos tus datos.")
            }
        }
    }
}

// MARK: - Supporting Components

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.headline.bold())
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct MenuRow: View {
    let icon: String
    let title: String
    let color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
        }
    }
}
