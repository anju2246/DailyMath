# **📱 ESPECIFICACIÓN TÉCNICA DE ARQUITECTURA Y ESTRUCTURA**

## **Proyecto: DailyMath (iOS \- SwiftUI)**

---

# **1\. DESCRIPCIÓN GENERAL DEL SISTEMA**

DailyMath es una plataforma móvil educativa para iOS diseñada para optimizar el aprendizaje de matemáticas mediante metodologías de aprendizaje activo y gamificación competitiva. El sistema busca resolver la falta de constancia en el estudio mediante un ecosistema interactivo, reactivo y social.

---

## **🎯 Objetivos Principales**

* **Retención:** facilitar el aprendizaje progresivo mediante práctica estructurada.  
* **Práctica constante:** fomentar el hábito diario con mecánicas de engagement.  
* **Competencia:** incentivar la participación mediante duelos y rankings.

---

## **👥 Roles del Sistema**

### **Usuario**

* Resuelve ejercicios  
* Participa en duelos 1v1  
* Se une a torneos  
* Consulta estadísticas  
* Interactúa en la comunidad

### **Moderador**

* Valida contenido generado por usuarios  
* Asegura calidad de ejercicios

---

## **🧩 Módulos Principales**

* **Práctica diaria:** ejercicios organizados por dificultad  
* **Comunidad:** feed social de ejercicios con comentarios y votación  
* **Desafíos:** duelos 1v1 y torneos semanales  
* **Agilidad mental:** práctica rápida con cronómetro  
* **Perfil y estadísticas:** métricas de rendimiento

---

# **2\. ARQUITECTURA DE SOFTWARE (MVVM)**

El proyecto adopta el patrón **Model-View-ViewModel (MVVM)**, estándar en desarrollo iOS moderno con SwiftUI.

---

## **🧱 Responsabilidades de las Capas**

### **Model (Modelo)**

* Representa entidades de dominio  
* Gestiona acceso a datos mediante repositorios  
* Incluye persistencia local (SwiftData/CoreData)  
* Maneja comunicación con servicios remotos (Supabase)

---

### **View (Vista)**

* Implementada con **SwiftUI**  
* Declarativa y reactiva  
* No contiene lógica de negocio

---

### **ViewModel**

* Gestiona el estado de la UI  
* Expone propiedades observables (`@Published`)  
* Maneja eventos del usuario

---

## **📱 Contexto en la Arquitectura de iOS**

La aplicación opera sobre las siguientes capas:

1. **Kernel Darwin (Unix-based):** gestión de memoria y procesos  
2. **Core OS:** networking, seguridad, sistema de archivos  
3. **Core Services:** Foundation, Combine  
4. **UIKit / SwiftUI:** capa de interfaz de usuario

---

# **3\. ENTIDADES DE DOMINIO Y MODELADO DE DATOS**

Se utilizan `struct` en Swift para representar entidades de negocio, favoreciendo inmutabilidad y seguridad.

---

## **📦 Entidades Principales**

### **User**

struct User: Identifiable {  
   let id: String  
   let name: String  
   let email: String  
   let role: UserRole  
   let university: String?  
   let profilePictureUrl: String?  
   let points: Int  
}  
---

### **Exercise**

struct Exercise: Identifiable {  
   let id: String  
   let title: String  
   let description: String  
   let category: ExerciseCategory  
   let difficulty: DifficultyLevel  
   let solution: String  
   let ownerId: String  
}  
---

### **Location**

struct Location {  
   let latitude: Double  
   let longitude: Double  
   let institutionName: String  
}  
---

## **🔢 Enumeraciones**

enum UserRole {  
   case user, admin  
}

enum DifficultyLevel {  
   case facil, normal, dificil  
}

enum ExerciseCategory {  
   case algebra, calculo, trigonometria, probabilidad  
}  
---

# **4\. ESTRUCTURA DE ARCHIVOS Y ORGANIZACIÓN**

DailyMath/  
├── App/  
│   └── DailyMathApp.swift  
├── Core/  
│   ├── UI/  
│   ├── Navigation/  
│   ├── Theme/  
│   └── Utils/  
├── Data/  
│   ├── Repositories/  
│   ├── Remote/  
│   └── Local/  
├── Domain/  
│   ├── Models/  
│   └── Repositories/  
├── Features/  
│   ├── Home/  
│   ├── Community/  
│   ├── Challenges/  
│   └── Profile/  
---

# **5\. DISEÑO DE LA INTERFAZ DE USUARIO**

La interfaz se construye con **SwiftUI**, siguiendo el paradigma declarativo.

---

## **🧱 Componentes Básicos**

* `Text`  
* `Button`  
* `Image`  
* `Label`

---

## **📐 Layouts**

* `VStack`: organización vertical  
* `HStack`: organización horizontal  
* `ZStack`: superposición

---

## **⚡ Listas y Grillas**

* `List`: feed de ejercicios  
* `LazyVGrid`: leaderboard

---

## **🎨 Modifiers**

* `.padding()`  
* `.background()`  
* `.cornerRadius()`  
* `.onTapGesture()`

---

# **6\. GESTIÓN DE ESTADO Y FORMULARIOS**

SwiftUI maneja la reactividad mediante propiedades observables.

---

## **🧠 Manejo de Estado**

* `@State`: estado local  
* `@StateObject`: instancia de ViewModel  
* `@Published`: propiedades reactivas  
* `ObservableObject`: ViewModel

---

## **🔄 State Hoisting**

El estado se gestiona en el ViewModel y se pasa a la vista.

---

## **✅ Validación de Formularios**

Se implementa un helper:

struct ValidatedField {  
   var value: String  
   var isValid: (String) \-\> Bool  
}  
---

# **7\. NAVEGACIÓN Y FLUJO DE PANTALLAS**

---

## **📍 Navegación Principal**

Se utiliza `NavigationStack` para gestionar rutas.

NavigationStack {  
   HomeView()  
}  
---

## **📱 Tab Bar**

TabView {  
   HomeView()  
   CommunityView()  
   ChallengeView()  
   CreateView()  
   ProfileView()  
}  
---

## **🔐 Flujo de Autenticación**

Separación entre:

* Login / Registro  
* Aplicación principal

---

# **8\. LÓGICA DE NEGOCIO Y FUNCIONALIDADES**

---

## **⚔️ Duelos 1v1**

* Resolución simultánea de ejercicios  
* Comparación de progreso en tiempo real

---

## **📡 Sincronización en Tiempo Real**

Uso de **Supabase Realtime (WebSockets)** para:

* actualizar progreso  
* sincronizar estado de duelos

---

## **🤖 Integración de IA**

* Clasificación automática de ejercicios  
* Sugerencia de categoría y dificultad

---

# **9\. STACK TECNOLÓGICO**

---

## **🧑‍💻 Lenguaje**

* Swift

## **🎨 UI**

* SwiftUI

## **☁️ Backend**

* Supabase:  
  * Auth  
  * Database (PostgreSQL)  
  * Realtime  
  * Storage

## **💾 Persistencia Local**

* SwiftData (recomendado)  
* CoreData (alternativa)

---

# **10\. CICLO DE VIDA Y CONSIDERACIONES**

---

## **🔄 Ciclo de Vida en SwiftUI**

* `onAppear()`: carga de datos  
* `onDisappear()`: limpieza de recursos

---

## **⚠️ Gestión de Recursos**

* cerrar conexiones realtime en duelos  
* evitar fugas de memoria

---

## **🔐 Seguridad**

* validación de respuestas en backend  
* detección de comportamiento sospechoso  
* control de sesiones

---

# **✅ CONCLUSIÓN**

Esta arquitectura en SwiftUI:

* mantiene separación clara de responsabilidades  
* permite escalabilidad  
* es consistente con estándares modernos de iOS

