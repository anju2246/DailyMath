import SwiftUI

struct ExploreView: View {
    @EnvironmentObject var navigation: AppNavigationCoordinator
    @State private var selectedCategory: AppConstants.Category? = nil
    @State private var searchText = ""
    @State private var showCreate = false

    private var filtered: [SampleExercise] {
        SampleExercises.all.filter { ex in
            (selectedCategory == nil || ex.category == selectedCategory!) &&
            (searchText.isEmpty ||
             ex.title.localizedCaseInsensitiveContains(searchText) ||
             ex.statement.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        ZStack {
            Color.dmBackground.ignoresSafeArea()
            VStack(spacing: DMSpacing.md) {
                header
                searchBar
                categoryStrip
                if filtered.isEmpty {
                    emptyState
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: DMSpacing.sm) {
                            ForEach(filtered) { ex in
                                Button { navigation.pushCommunity(.exerciseDetail(id: ex.id)) } label: {
                                    exerciseCard(ex)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.bottom, DMSpacing.xxl)
                    }
                }
            }
            .padding(.horizontal, DMSpacing.lg)
            .padding(.top, DMSpacing.sm)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showCreate) { CreateExerciseView() }
    }

    private var header: some View {
        HStack {
            Text("Explorar").font(DMFont.largeTitle())
            Spacer()
            Button { showCreate = true } label: {
                ZStack {
                    Circle().fill(Color.dmSuccess).frame(width: 36, height: 36)
                    Image(systemName: "plus").foregroundStyle(.white).font(.headline)
                }
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: DMSpacing.xs) {
            Image(systemName: "magnifyingglass").foregroundStyle(Color.dmTextSecondary)
            TextField("Buscar ejercicios...", text: $searchText)
                .font(DMFont.callout())
        }
        .padding(.horizontal, DMSpacing.md)
        .padding(.vertical, DMSpacing.sm)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.md)
    }

    private var categoryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DMSpacing.sm) {
                FilterChip(title: "Todos", isSelected: selectedCategory == nil) { selectedCategory = nil }
                ForEach(AppConstants.Category.allCases, id: \.self) { category in
                    FilterChip(title: category.displayName, icon: category.icon, isSelected: selectedCategory == category) {
                        selectedCategory = category
                    }
                }
            }
        }
    }

    private func exerciseCard(_ ex: SampleExercise) -> some View {
        VStack(alignment: .leading, spacing: DMSpacing.xs) {
            HStack {
                Text(ex.category.displayName.uppercased())
                    .font(DMFont.caption2())
                    .foregroundStyle(Color.dmTextSecondary)
                Spacer()
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up").font(.caption)
                    Text("\(ex.votes)").font(DMFont.caption())
                }
                .foregroundStyle(Color.dmSuccess)
            }
            Text(ex.title).font(DMFont.calloutEmphasized()).foregroundStyle(.primary)
            Text(ex.statement)
                .font(DMFont.footnote())
                .foregroundStyle(Color.dmTextSecondary)
                .lineLimit(2)
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundStyle(Color.dmTextSecondary)
                Text(ex.author)
                    .font(DMFont.caption())
                    .foregroundStyle(Color.dmTextSecondary)
            }
            .padding(.top, DMSpacing.xxs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DMSpacing.md)
        .background(Color.dmSurface)
        .cornerRadius(DMRadius.lg)
    }

    private var emptyState: some View {
        VStack(spacing: DMSpacing.sm) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(Color.dmTextSecondary.opacity(0.5))
            Text("No hay ejercicios").font(DMFont.headline()).foregroundStyle(Color.dmTextSecondary)
            Text("Prueba con otra búsqueda o categoría")
                .font(DMFont.footnote())
                .foregroundStyle(Color.dmTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DMSpacing.xl)
    }
}

struct FilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon).font(.caption)
                }
                Text(title).font(DMFont.callout())
            }
            .padding(.horizontal, DMSpacing.md)
            .padding(.vertical, DMSpacing.xs)
            .background(isSelected ? Color.dmOnDark : Color.dmSurface)
            .foregroundStyle(isSelected ? Color.dmSurface : .primary)
            .cornerRadius(DMRadius.pill)
        }
    }
}
