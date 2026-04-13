import SwiftUI

// MARK: - Global Top View (Leaderboard)

struct LeaderboardView: View {
    @EnvironmentObject var appState: AppState
    
    // Simulación de los mejores del ranking
    private let topUsers = [
        ("Sofia_Math", 2540, "🥇"),
        ("Andres_Calc", 2100, "🥈"),
        ("Carlos_Uniquindio", 1950, "🥉"),
        ("Laura_Algebra", 1800, "4"),
        ("Pedro_Trig", 1750, "5"),
        ("Maria_Log", 1600, "6")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Podio
                HStack(alignment: .bottom, spacing: 16) {
                    PodiumColumn(name: "Andres_Calc", points: "2100", icon: "🥈", height: 100)
                    PodiumColumn(name: "Sofia_Math", points: "2540", icon: "🥇", height: 140, isWinner: true)
                    PodiumColumn(name: "Carlos_U", points: "1950", icon: "🥉", height: 80)
                }
                .padding(.top, 40)
                
                // Lista de Ranking
                VStack(spacing: 0) {
                    ForEach(3..<topUsers.count, id: \.self) { index in
                        RankingRow(
                            position: "\(index + 1)",
                            name: topUsers[index].0,
                            points: "\(topUsers[index].1) pts"
                        )
                        if index < topUsers.count - 1 {
                            Divider().padding(.leading, 60)
                        }
                    }
                }
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
            }
        }
        .navigationTitle("Top Global")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Helper Views

struct PodiumColumn: View {
    let name: String
    let points: String
    let icon: String
    let height: CGFloat
    var isWinner: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            Text(icon).font(.system(size: 32))
            
            VStack {
                Text(name)
                    .font(.caption.bold())
                    .lineLimit(1)
                Text(points)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Rectangle()
                .fill(isWinner ? Color.yellow.gradient : Color.gray.opacity(0.3).gradient)
                .frame(width: 80, height: height)
                .cornerRadius(12, corners: [.topLeft, .topRight])
        }
    }
}

struct RankingRow: View {
    let position: String
    let name: String
    let points: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(position)
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 30)
            
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay(Text(name.prefix(1)).font(.caption.bold()))
            
            Text(name)
                .font(.subheadline.bold())
            
            Spacer()
            
            Text(points)
                .font(.caption)
                .foregroundStyle(.tint)
                .padding(6)
                .background(Color.dmPrimary.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
    }
}

// MARK: - Extension for Corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
