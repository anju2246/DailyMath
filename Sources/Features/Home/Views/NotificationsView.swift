import SwiftUI

// MARK: - Notifications View

struct NotificationsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Simulación de notificaciones
    private let notifications = [
        (title: "¡Duelo Aceptado!", body: "Andrés ha aceptado tu reto de Cálculo.", icon: "flag.checkered", color: Color.blue, time: "Hace 2 min"),
        (title: "Comentario Nuevo", body: "Sofía comentó en tu ejercicio de Álgebra.", icon: "bubble.left.fill", color: Color.purple, time: "Hace 15 min"),
        (title: "Ejercicio Validado", body: "Tu ejercicio 'Límites' ha sido aprobado.", icon: "checkmark.seal.fill", color: Color.green, time: "Hace 1 hora"),
        (title: "¡Sigue así!", body: "Has alcanzado una racha de 5 días practicando.", icon: "flame.fill", color: Color.orange, time: "Hace 3 horas")
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<notifications.count, id: \.self) { index in
                    let item = notifications[index]
                    HStack(spacing: 16) {
                        Image(systemName: item.icon)
                            .font(.title2)
                            .foregroundStyle(item.color)
                            .frame(width: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.subheadline.bold())
                            Text(item.body)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(item.time)
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Notificaciones")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
            }
        }
    }
}
