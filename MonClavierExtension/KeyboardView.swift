import SwiftUI

// MARK: - Modèles de Données

// Petite structure vide pour représenter un objet JSON vide `{}`
fileprivate struct EmptyCodable: Codable {}

// --- Énumération KeyAction avec son implémentation Codable manuelle ---
enum KeyAction: Codable, Hashable {
    case insert(String)
    case backspace
    case space
    case switchKeyboard

    // Les clés que nous nous attendons à trouver dans le JSON pour l'action
    enum CodingKeys: String, CodingKey {
        case insert, backspace, space, switchKeyboard
    }

    // Comment transformer le JSON en une de nos énumérations
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try container.decodeIfPresent(String.self, forKey: .insert) {
            self = .insert(value)
        } else if container.contains(.backspace) {
            self = .backspace
        } else if container.contains(.space) {
            self = .space
        } else if container.contains(.switchKeyboard) {
            self = .switchKeyboard
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Action de clé non valide")
            )
        }
    }

    // Comment transformer une de nos énumérations en JSON
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .insert(let text):
            try container.encode(text, forKey: .insert)
        case .backspace:
            try container.encode(EmptyCodable(), forKey: .backspace)
        case .space:
            try container.encode(EmptyCodable(), forKey: .space)
        case .switchKeyboard:
            try container.encode(EmptyCodable(), forKey: .switchKeyboard)
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
struct KeyboardView: View {
    var textDocumentProxy: UITextDocumentProxy
    
    @State private var keyboardLayout: KeyboardLayout?

    var body: some View {
        VStack(spacing: 8) {
            if let layout = keyboardLayout {
                ForEach(layout.rows) { row in
                    HStack(spacing: 4) {
                        ForEach(row.keys) { key in
                            KeyButton(key: key, action: handleAction)
                        }
                    }
                }
            } else {
                ProgressView()
                    .onAppear(perform: loadLayout)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(3)
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
        case .switchKeyboard:
            print("Changement de clavier demandé. Implémentez la logique ici.")
        }
    }
    
    private func loadLayout() {
        guard let url = Bundle.main.url(forResource: "KeyboardLayout", withExtension: "json") else {
            fatalError("Fichier KeyboardLayout.json introuvable.")
        }
        do {
            let data = try Data(contentsOf: url)
            self.keyboardLayout = try JSONDecoder().decode(KeyboardLayout.self, from: data)
        } catch {
            // Un message d'erreur plus détaillé pendant le développement
            print("----- ERREUR DE DÉCODAGE JSON -----")
            print(error)
            if let decodingError = error as? DecodingError {
                print("----- DÉTAILS DE L'ERREUR -----")
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("Type Mismatch: \(type) in \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("Value Not Found: \(type) in \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                case .keyNotFound(let key, let context):
                    print("Key Not Found: \(key) in \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                case .dataCorrupted(let context):
                    print("Data Corrupted: \(context.debugDescription)")
                    print("Coding Path: \(context.codingPath)")
                @unknown default:
                    fatalError("Nouvelle erreur de décodage non gérée")
                }
            }
            fatalError("Échec du décodage du JSON. Voir la console pour les détails.")
        }
    }
}
