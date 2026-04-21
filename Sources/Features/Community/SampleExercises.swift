import Foundation

struct SampleExercise: Identifiable {
    let id: UUID
    let title: String
    let category: AppConstants.Category
    let statement: String
    let solution: String
    let author: String
    let votes: Int
    let comments: Int
}

enum SampleExercises {
    static let all: [SampleExercise] = [
        .init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
              title: "Derivada de sen(x)",
              category: .calculoDiferencial,
              statement: "¿Cuál es la derivada de sen(x)?",
              solution: "cos(x)\n\nPor definición, d/dx [sen(x)] = cos(x).",
              author: "Ana M.", votes: 42, comments: 8),
        .init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
              title: "Integral por partes",
              category: .calculoIntegral,
              statement: "Calcula ∫ x·cos(x) dx",
              solution: "Usando integración por partes con u=x, dv=cos(x)dx:\ndu=dx, v=sen(x)\n\n∫ x·cos(x) dx = x·sen(x) - ∫ sen(x) dx = x·sen(x) + cos(x) + C",
              author: "Carlos R.", votes: 31, comments: 5),
        .init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
              title: "Identidad trigonométrica",
              category: .trigonometria,
              statement: "Demuestra que sen²(x) + cos²(x) = 1",
              solution: "Sea un triángulo rectángulo con hipotenusa c y catetos a, b.\nsen(x) = a/c, cos(x) = b/c\n\nsen²(x) + cos²(x) = a²/c² + b²/c² = (a²+b²)/c²\n\nPor el teorema de Pitágoras, a² + b² = c², entonces:\n(a²+b²)/c² = c²/c² = 1 ∎",
              author: "Laura P.", votes: 28, comments: 12),
        .init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
              title: "Ecuación lineal",
              category: .algebraLineal,
              statement: "Resuelve el sistema 2x+3y=7, x-y=1",
              solution: "De la segunda ecuación: x = y + 1\nSustituyendo en la primera: 2(y+1) + 3y = 7\n2y + 2 + 3y = 7 → 5y = 5 → y = 1\nEntonces x = 1 + 1 = 2\n\nSolución: (x, y) = (2, 1)",
              author: "Diego F.", votes: 19, comments: 3),
        .init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
              title: "Probabilidad condicional",
              category: .probabilidad,
              statement: "Si P(A)=0.4 y P(B|A)=0.5, halla P(A∩B)",
              solution: "Por definición de probabilidad condicional:\nP(B|A) = P(A∩B) / P(A)\n\nDespejando: P(A∩B) = P(B|A) · P(A) = 0.5 · 0.4 = 0.2",
              author: "Sofia G.", votes: 15, comments: 2),
        .init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
              title: "EDO de primer orden",
              category: .ecuacionesDiferenciales,
              statement: "Resuelve dy/dx = 2xy",
              solution: "Separando variables: dy/y = 2x·dx\n\nIntegrando ambos lados:\nln|y| = x² + C₁\n\ny = e^(x² + C₁) = C·e^(x²)\n\nSolución general: y = C·e^(x²)",
              author: "Mateo L.", votes: 12, comments: 4)
    ]

    static func find(id: UUID) -> SampleExercise? {
        all.first { $0.id == id }
    }
}
