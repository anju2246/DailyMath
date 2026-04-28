# Plan de Implementación: Segunda Entrega - DailyMath

Este plan se enfoca en cumplir con el 100% de los requerimientos funcionales para la entrega final de la Fase 2.

## Fase 1: Estructura de Datos y Sesión (Día 1)
1.  **Persistencia de Sesión (Equivalente DataStore):**
    *   Crear `SessionDataStore` en `Data/Local/` usando `UserDefaults`.
    *   Almacenar el `userId` y `role` al loguearse.
2.  **Strings (Internacionalización):**
    *   Migrar todos los textos de las vistas en `Features/` al archivo `Resources/Localization/Localizable.xcstrings`.
    *   Asegurar que el `L10n.swift` use `NSLocalizedString` o el nuevo sistema de Swift.

## Fase 2: Desarrollo de Pantallas Faltantes (Día 2-3)
1.  **Módulo de Moderador:**
    *   Implementar `ModeratorDashboardView`: Lista de ejercicios pendientes de validar.
    *   Implementar `RejectionReasonView`: Formulario para escribir por qué se rechaza un ejercicio.
2.  **Módulo de Duelos (Funcionalidad básica):**
    *   Completar `DuelLobbyView`.
    *   Crear una vista de "Resultado de Duelo" (aunque la lógica sea simulada).
3.  **Módulo de Perfil:**
    *   Completar `ProfileView` para mostrar insignias y estadísticas (datos simulados en repositorio).

## Fase 3: Navegación y Conectividad (Día 4)
1.  **Integración de Navegación:**
    *   Asegurar que al loguearse se cambie el `rootView` de `LoginView` a `MainTabView`.
    *   Implementar el "Logout" que limpie el `UserDefaults`.
2.  **Inyección de Dependencias:**
    *   Centralizar la creación de Repositorios en el `DailymathApp.swift` o un `DependencyContainer` para evitar crear instancias en las Views.

## Fase 4: Validación y QA (Día 5)
1.  **Pruebas de Flujo:**
    *   Registro -> Login -> Home -> Crear Ejercicio -> Logout.
2.  **Revisión de Textos:**
    *   Asegurar que no existan Strings en español/inglés directamente en el código de SwiftUI.

## Archivos Críticos a Tener en Cuenta
*   `Sources/Core/Navigation/NavigationRoutes.swift`: Define el mapa de la app.
*   `Sources/Data/Local/FlashcardStore.swift`: Base para la persistencia en memoria.
*   `Sources/Domain/Models/User.swift`: Define los roles (Usuario/Moderador).
*   `Resources/Localization/Localizable.xcstrings`: Todos los textos de la app.
*   `Sources/App/AppState.swift`: Estado global de la sesión.
