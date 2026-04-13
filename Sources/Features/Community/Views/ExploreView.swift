import SwiftUI

// MARK: - Explore View (Community Feed)

struct ExploreView: View {
    @EnvironmentObject var navigation: AppNavigationCoordinator
    @State private var selectedCategory: AppConstants.Category? = nil
    @State private var searchText = ""

    private let sampleExerciseID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    
    var body: some View {
        VStack(spacing: 0) {
            // Category filter chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(
                        title: L10n.communityAll,
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
                        
                        Text(L10n.communityNoExercises)
                            .font(.headline)
                        
                        Text(L10n.communityCreateFirstExercise)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button {
                            navigation.pushCommunity(.exerciseDetail(id: sampleExerciseID))
                        } label: {
                            Text(L10n.communityViewExample)
                                .secondaryButton()
                        }
                    }
                    .cardStyle()
                    .padding(.top, 40)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(L10n.communityExploreTitle)
        .searchable(text: $searchText, prompt: L10n.communitySearchPrompt)
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
