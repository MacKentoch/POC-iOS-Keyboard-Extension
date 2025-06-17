import SwiftUI

// MARK: - Modèles de Données

fileprivate struct EmptyCodable: Codable {}

enum KeyAction: Codable, Hashable {
    case insert(String)
    case backspace
    case space
    case switchToNextKeyboard
    case switchToPreviousKeyboard
    
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

struct KeyboardLayout: Codable {
    let rows: [KeyboardRow]
}


// MARK: - Vue pour un Bouton
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
fileprivate enum KeyboardAnimationDirection {
    case forward
    case backward
}

struct KeyboardView: View {
    var textDocumentProxy: UITextDocumentProxy
    
    @State private var allKeyboardLayouts: [KeyboardLayout] = []
    @State private var currentKeyboardIndex: Int = 0
    
    @State private var animationDirection: KeyboardAnimationDirection = .forward
    
    private var currentKeyboardLayout: KeyboardLayout? {
        guard !allKeyboardLayouts.isEmpty, allKeyboardLayouts.indices.contains(currentKeyboardIndex) else {
            return nil
        }
        return allKeyboardLayouts[currentKeyboardIndex]
    }
    
    private let forwardTransition: AnyTransition = .asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal: .move(edge: .leading).combined(with: .opacity)
    )
    
    private let backwardTransition: AnyTransition = .asymmetric(
        insertion: .move(edge: .leading).combined(with: .opacity),
        removal: .move(edge: .trailing).combined(with: .opacity)
    )
    
    var body: some View {
        VStack(spacing: 8) {
            if let layout = currentKeyboardLayout {
                ForEach(layout.rows) { row in
                    HStack(spacing: 4) {
                        ForEach(row.keys) { key in
                            KeyButton(key: key, action: handleAction)
                        }
                    }
                }
            } else {
                ProgressView()
                    .onAppear(perform: loadAllLayouts)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(3)
        .transition(animationDirection == .forward ? forwardTransition : backwardTransition)
        .id(currentKeyboardIndex) // Changer l'id force la vue à se redessiner complètement lors du switch
    }
    
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
            guard !allKeyboardLayouts.isEmpty else { return }
            switchToNextKeyboard()
        case .switchToPreviousKeyboard:
            guard !allKeyboardLayouts.isEmpty else { return }
            switchToPreviousKeyboard()
        }
    }
    
    private func switchToNextKeyboard() {
        guard !allKeyboardLayouts.isEmpty else { return }
        animationDirection = .forward
        
        withAnimation(.easeInOut(duration: 0.25)) {
            currentKeyboardIndex = (currentKeyboardIndex + 1) % allKeyboardLayouts.count
        }
    }
    
    private func switchToPreviousKeyboard() {
        guard !allKeyboardLayouts.isEmpty else { return }
        animationDirection = .backward
        
        withAnimation(.easeInOut(duration: 0.25)) {
            let count = allKeyboardLayouts.count
            
            currentKeyboardIndex = (currentKeyboardIndex - 1 + count) % count // modulo for negative numbers in Swift.
        }
    }
    
    private func loadAllLayouts() {
        guard let url = Bundle.main.url(forResource: "KeyboardLayout", withExtension: "json") else {
            fatalError("Fichier KeyboardLayout.json introuvable.")
        }
        do {
            let data = try Data(contentsOf: url)
            let collection = try JSONDecoder().decode(KeyboardCollection.self, from: data)
            
            self.allKeyboardLayouts = collection.keyboards
            self.currentKeyboardIndex = 0
        } catch {
            print("----- ERREUR DE DÉCODAGE JSON -----")
            print(error)
            fatalError("Échec du décodage du JSON. Voir la console pour les détails.")
        }
    }
    
}
