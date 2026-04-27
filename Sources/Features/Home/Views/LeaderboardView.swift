import SwiftUI

// MARK: - Global Top View (Leaderboard)

struct LeaderboardView: View {
    @EnvironmentObject var appState: AppState

    private var topUsers: [UserProfile] {
        appState.profileRepository.topUsers(limit: 10)
    }

    var body: some View {
        ScrollView {
            if topUsers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Aún no hay ranking. Empieza a estudiar y crear ejercicios para sumar puntos.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 80)
            } else {
                VStack(spacing: 20) {
                    podium

                    if topUsers.count > 3 {
                        VStack(spacing: 0) {
                            ForEach(Array(topUsers.enumerated()).filter { $0.offset >= 3 }, id: \.element.id) { idx, user in
                                RankingRow(
                                    position: "\(idx + 1)",
                                    name: user.displayName ?? user.username,
                                    points: "\(user.points) pts"
                                )
                                if idx < topUsers.count - 1 {
                                    Divider().padding(.leading, 60)
                                }
                            }
                        }
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle(L10n.leaderboardTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var podium: some View {
        let users = topUsers
        HStack(alignment: .bottom, spacing: 16) {
            if users.count >= 2 {
                PodiumColumn(
                    name: users[1].displayName ?? users[1].username,
                    points: "\(users[1].points)",
                    icon: "🥈",
                    height: 100
                )
            }
            if let first = users.first {
                PodiumColumn(
                    name: first.displayName ?? first.username,
                    points: "\(first.points)",
                    icon: "🥇",
                    height: 140,
                    isWinner: true
                )
            }
            if users.count >= 3 {
                PodiumColumn(
                    name: users[2].displayName ?? users[2].username,
                    points: "\(users[2].points)",
                    icon: "🥉",
                    height: 80
                )
            }
        }
        .padding(.top, 40)
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
