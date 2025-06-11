//
//  KeyboardView.swift
//  MonClavierApp
//
//  Created by Rav3n on 12/06/2025.
//

// KeyboardView.swift

// KeyboardView.swift

import SwiftUI

struct Key: Identifiable {
    let id = UUID()
    let value: String
}

struct KeyboardView: View {
    var textDocumentProxy: UITextDocumentProxy

    let row1 = "AZERTYUIOP".map { Key(value: String($0)) }
    let row2 = "QSDFGHJKLM".map { Key(value: String($0)) }
    let row3 = "WXCVBN".map { Key(value: String($0)) }

    var body: some View {
        // Le VStack principal va s'étirer pour remplir l'espace donné par le HostingController
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(row1) { key in KeyButton(letter: key.value, action: insert) }
            }
            HStack(spacing: 4) {
                ForEach(row2) { key in KeyButton(letter: key.value, action: insert) }
            }
            HStack(spacing: 4) {
                // On ajoute des "Spacer" pour centrer la dernière rangée, qui est plus courte.
                Spacer()
                ForEach(row3) { key in KeyButton(letter: key.value, action: insert) }
                Spacer()
            }
            
            // Dernière rangée avec espace et supprimer
            HStack(spacing: 4) {
                // Bouton pour les chiffres/symboles (exemple)
                KeyButton(letter: "123", action: { _ in /* Logique pour changer de vue */ })
                    .frame(width: 80) // Largeur fixe
                
                // Le bouton espace est flexible et prend le reste
                KeyButton(letter: "espace", action: insert)
                
                KeyButton(systemImage: "delete.left.fill", action: delete)
                    .frame(width: 55)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // S'étire dans les deux sens
        .padding()
        .background(Color(.systemGray6)) // Une couleur de fond neutre
    }

    private func insert(_ text: String) {
        if text == "espace" {
            textDocumentProxy.insertText(" ")
        } else {
            textDocumentProxy.insertText(text)
        }
    }

    private func delete() {
        textDocumentProxy.deleteBackward()
    }
}


// KeyButton.swift reste inchangé
struct KeyButton: View {
    var letter: String?
    var systemImage: String?
    var action: (String) -> Void
    var deleteAction: (() -> Void)?

    init(letter: String, action: @escaping (String) -> Void) {
        self.letter = letter
        self.action = action
    }

    init(systemImage: String, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.deleteAction = action
        self.action = { _ in }
    }

    var body: some View {
        Button(action: {
            if let letter = letter {
                action(letter)
            } else if let deleteAction = deleteAction {
                deleteAction()
            }
        }) {
            ZStack {
                if let letter = letter {
                    Text(letter.uppercased())
                } else if let systemImage = systemImage {
                    Image(systemName: systemImage)
                }
            }
            .font(.system(size: 18, weight: .regular))
            .frame(maxWidth: .infinity, minHeight: 45)
            .background(Color(.systemBackground))
            .foregroundColor(.primary)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.15), radius: 1, y: 1)
        }
    }
}
