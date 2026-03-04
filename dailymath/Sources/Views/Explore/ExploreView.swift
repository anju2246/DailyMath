import SwiftUI
import Combine

// MARK: - Explore View (Community Feed)

struct ExploreView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: AppConstants.Category? = nil
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterChip(
                            title: "Todos",
                            isSelected: selectedCategory == nil
                        ) {
                            selectedCategory = nil
                        }
                        
                        ForEach(AppConstants.Category.allCases, id: \.self) { category in
                            FilterChip(
                                title: category.displayName,
                                icon: category.icon,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // Exercise list placeholder
                ScrollView {
                    VStack(spacing: 16) {
                        // Empty state
                        VStack(spacing: 12) {
                            Image(systemName: "tray")
                                .font(.system(size: 48))
                                .foregroundStyle(.secondary)
                            
                            Text("No hay ejercicios aún")
                                .font(.headline)
                            
                            Text("Sé el primero en crear un ejercicio para la comunidad")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .cardStyle()
                        .padding(.top, 40)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Explorar")
            .searchable(text: $searchText, prompt: "Buscar ejercicios...")
        }
    }
}

// MARK: - Filter Chip Component

struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.dmPrimary : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}
