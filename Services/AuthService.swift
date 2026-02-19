import Foundation
import Supabase

// MARK: - Auth Service

@MainActor
class AuthService: ObservableObject {
    @Published var currentUser: UserProfile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var client: SupabaseClient { SupabaseService.shared.client }
    
    init() {
        Task {
            await checkSession()
        }
    }
    
    // MARK: - Check existing session
    
    func checkSession() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let session = try await client.auth.session
            await fetchProfile(userId: session.user.id)
            isAuthenticated = true
        } catch {
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    // MARK: - Sign Up
    
    func signUp(email: String, password: String, displayName: String, university: String?) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let response = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["display_name": .string(displayName)]
            )
            
            // Create profile in profiles table
            if let userId = response.session?.user.id {
                let profile: [String: AnyJSON] = [
                    "id": .string(userId.uuidString),
                    "display_name": .string(displayName),
                    "email": .string(email),
                    "university": university.map { .string($0) } ?? .null,
                    "points": .integer(0),
                    "level": .integer(1),
                    "study_streak": .integer(0),
                    "role": .string("user")
                ]
                
                try await client.from("profiles")
                    .insert(profile)
                    .execute()
                
                await fetchProfile(userId: userId)
                isAuthenticated = true
            }
        } catch {
            errorMessage = parseAuthError(error)
        }
    }
    
    // MARK: - Sign In
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            await fetchProfile(userId: session.user.id)
            isAuthenticated = true
        } catch {
            errorMessage = parseAuthError(error)
        }
    }
    
    // MARK: - Password Recovery
    
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await client.auth.resetPasswordForEmail(email)
        } catch {
            errorMessage = parseAuthError(error)
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() async {
        do {
            try await client.auth.signOut()
            isAuthenticated = false
            currentUser = nil
        } catch {
            errorMessage = "Error al cerrar sesión"
        }
    }
    
    // MARK: - Delete Account
    
    func deleteAccount() async {
        guard let userId = currentUser?.id else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await client.from("profiles")
                .delete()
                .eq("id", value: userId.uuidString)
                .execute()
            
            await signOut()
        } catch {
            errorMessage = "Error al eliminar la cuenta"
        }
    }
    
    // MARK: - Fetch Profile
    
    func fetchProfile(userId: UUID) async {
        do {
            let profile: UserProfile = try await client.from("profiles")
                .select()
                .eq("id", value: userId.uuidString)
                .single()
                .execute()
                .value
            
            currentUser = profile
        } catch {
            print("Error fetching profile: \(error)")
        }
    }
    
    // MARK: - Update Profile
    
    func updateProfile(displayName: String?, university: String?) async {
        guard let userId = currentUser?.id else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            var updates: [String: AnyJSON] = [:]
            if let displayName = displayName {
                updates["display_name"] = .string(displayName)
            }
            if let university = university {
                updates["university"] = .string(university)
            }
            
            try await client.from("profiles")
                .update(updates)
                .eq("id", value: userId.uuidString)
                .execute()
            
            await fetchProfile(userId: userId)
        } catch {
            errorMessage = "Error al actualizar perfil"
        }
    }
    
    // MARK: - Error Parsing
    
    private func parseAuthError(_ error: Error) -> String {
        let desc = error.localizedDescription.lowercased()
        if desc.contains("invalid login") || desc.contains("invalid_credentials") {
            return "Email o contraseña incorrectos"
        } else if desc.contains("already registered") || desc.contains("already_exists") {
            return "Este email ya está registrado"
        } else if desc.contains("password") && desc.contains("short") {
            return "La contraseña debe tener al menos 6 caracteres"
        } else if desc.contains("network") || desc.contains("connection") {
            return "Error de conexión. Verifica tu internet"
        }
        return "Ha ocurrido un error. Intenta de nuevo"
    }
}
