import SwiftUI

// MARK: - Modèles de Données
// (Toutes vos structures de données sont correctes et restent ici)

fileprivate struct EmptyCodable: Codable {}

enum KeyAction: Codable, Hashable {
    case insert(String)
    case backspace
    case space
    case switchToNextKeyboard
    case switchToPreviousKeyboard
    
    // ... Le reste de votre enum KeyAction ... (pas de changement)
    enum CodingKeys: String, CodingKey {
        case insert, backspace, space, switchToNextKeyboard, switchToPreviousKeyboard
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try container.decodeIfPresent(String.self, forKey: .insert) {
            self = .insert(value)
        } else if container.contains(.backspace) {
            self = .backspace
        } else if container.contains(.space) {
            self = .space
        } else if container.contains(.switchToNextKeyboard) {
            self = .switchToNextKeyboard
        } else if container.contains(.switchToPreviousKeyboard) {
            self = .switchToPreviousKeyboard
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Action de clé non valide")
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .insert(let text):
            try container.encode(text, forKey: .insert)
        case .backspace:
            try container.encode(EmptyCodable(), forKey: .backspace)
        case .space:
            try container.encode(EmptyCodable(), forKey: .space)
        case .switchToNextKeyboard:
            try container.encode(EmptyCodable(), forKey: .switchToNextKeyboard)
        case .switchToPreviousKeyboard:
            try container.encode(EmptyCodable(), forKey: .switchToPreviousKeyboard)
        }
    }
}


enum KeyType: Codable, Hashable {
    case character(String)
    case systemImage(String)
    case svgImage(String)
    
    // ... Le reste de votre enum KeyType ... (pas de changement)
    enum CodingKeys: String, CodingKey {
        case character, systemImage, svgImage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try container.decodeIfPresent(String.self, forKey: .character) { self = .character(value) }
        else if let value = try container.decodeIfPresent(String.self, forKey: .systemImage) { self = .systemImage(value) }
        else if let value = try container.decodeIfPresent(String.self, forKey: .svgImage) { self = .svgImage(value) }
        else { throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "KeyType non valide")) }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .character(let v): try container.encode(v, forKey: .character)
        case .systemImage(let v): try container.encode(v, forKey: .systemImage)
        case .svgImage(let v): try container.encode(v, forKey: .svgImage)
        }
    }
}

struct Key: Codable, Identifiable, Hashable {
    let id = UUID()
    let type: KeyType
    let action: KeyAction
    var width: CGFloat?
    
    enum CodingKeys: String, CodingKey {
        case type, action, width
    }
}

struct KeyboardRow: Codable, Identifiable, Hashable {
    let id = UUID()
    let keys: [Key]
    enum CodingKeys: String, CodingKey { case keys }
}

struct KeyboardCollection: Codable {
    let keyboards: [KeyboardLayout]
}

struct KeyboardLayout: Codable, Hashable {
    let rows: [KeyboardRow]
}


// MARK: - Vue pour un Bouton
// (Votre vue KeyButton est correcte et reste inchangée)
struct KeyButton: View {
    let key: Key
    let action: (KeyAction) -> Void
    
    var body: some View {
        Button(action: {
            action(key.action)
        }) {
            let buttonContent = ZStack {
                switch key.type {
                case .character(let text):
                    Text(text)
                case .systemImage(let imageName):
                    Image(systemName: imageName)
                case .svgImage(let imageName):
                    SVGView(named: imageName)
                }
            }
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.primary)
            
            if let fixedWidth = key.width {
                buttonContent
                    .frame(width: fixedWidth)
                    .frame(minHeight: 45)
            } else {
                buttonContent
                    .frame(maxWidth: .infinity, minHeight: 45)
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.15), radius: 1, y: 1)
    }
}


// MARK: - Vue Principale du Clavier

struct KeyboardView: View {
    var textDocumentProxy: UITextDocumentProxy
    
    @State private var allKeyboardLayouts: [KeyboardLayout] = []
    @State private var currentKeyboardIndex: Int = 0
    
    // L'état qui contrôle si on affiche le clavier ou le spinner
    @State private var isReadyToDisplay: Bool = false
    
    // L'état pour la direction de l'animation
    private enum KeyboardAnimationDirection { case forward, backward }
    @State private var animationDirection: KeyboardAnimationDirection = .forward
    
    // Propriété calculée pour obtenir le layout actuel
    private var currentKeyboardLayout: KeyboardLayout? {
        guard !allKeyboardLayouts.isEmpty, allKeyboardLayouts.indices.contains(currentKeyboardIndex) else {
            return nil
        }
        return allKeyboardLayouts[currentKeyboardIndex]
    }
    
    // Définitions des transitions
    private let forwardTransition: AnyTransition = .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
    private let backwardTransition: AnyTransition = .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
    
    var body: some View {
        VStack(spacing: 8) {
            // On vérifie si on est prêt à afficher
            if isReadyToDisplay, let layout = currentKeyboardLayout {
                // Si oui, on construit le clavier
                ForEach(layout.rows, id: \.self) { row in
                    HStack(spacing: 4) {
                        ForEach(row.keys, id: \.self) { key in
                            KeyButton(key: key, action: handleAction)
                        }
                    }
                }
            } else {
                // Sinon, on affiche un spinner et on déclenche le chargement
                ProgressView()
                    .onAppear(perform: prepareKeyboard)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(3)
        .transition(animationDirection == .forward ? forwardTransition : backwardTransition)
        .id(currentKeyboardIndex) // Force le redessinage lors du changement
    }
    
    // ===== LA CORRECTION PRINCIPALE EST ICI =====
    private func prepareKeyboard() {
        // 1. S'assurer qu'on ne charge les données qu'une seule fois
        guard allKeyboardLayouts.isEmpty else { return }
        
        // 2. Lancer le chargement sur un thread d'arrière-plan pour ne pas bloquer l'UI
        DispatchQueue.global(qos: .userInitiated).async {
            guard let url = Bundle.main.url(forResource: "KeyboardLayout", withExtension: "json") else {
                print("ERREUR: Fichier KeyboardLayout.json introuvable.")
                return
            }
            
            do {
                // 3. Charger et décoder les données (votre logique était déjà bonne)
                let data = try Data(contentsOf: url)
                let collection = try JSONDecoder().decode(KeyboardCollection.self, from: data)
                
                // 4. Mettre à jour l'état sur le thread principal
                DispatchQueue.main.async {
                    self.allKeyboardLayouts = collection.keyboards
                    
                    // 5. LA MAGIE : Attendre le prochain cycle de rendu pour afficher
                    // Cela donne le temps à l'environnement de l'extension de se stabiliser
                    DispatchQueue.main.async {
                        self.isReadyToDisplay = true
                    }
                }
            } catch {
                print("ERREUR DE DÉCODAGE JSON: \(error)")
            }
        }
    }
    
    // --- Le reste de vos fonctions est correct et reste inchangé ---
    
    private func handleAction(_ action: KeyAction) {
        UIDevice.current.playInputClick()
        
        switch action {
        case .insert(let text):
            textDocumentProxy.insertText(text)
        case .backspace:
            textDocumentProxy.deleteBackward()
        case .space:
            textDocumentProxy.insertText(" ")
        case .switchToNextKeyboard:
            switchToNextKeyboard()
        case .switchToPreviousKeyboard:
            switchToPreviousKeyboard()
        }
    }
    
    private func switchToNextKeyboard() {
        guard !allKeyboardLayouts.isEmpty else { return }
        animationDirection = .forward
        withAnimation(.easeInOut(duration: 0.2)) {
            currentKeyboardIndex = (currentKeyboardIndex + 1) % allKeyboardLayouts.count
        }
    }
    
    private func switchToPreviousKeyboard() {
        guard !allKeyboardLayouts.isEmpty else { return }
        animationDirection = .backward
        withAnimation(.easeInOut(duration: 0.2)) {
            let count = allKeyboardLayouts.count
            currentKeyboardIndex = (currentKeyboardIndex - 1 + count) % count
        }
    }
}
