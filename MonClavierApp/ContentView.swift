import SwiftUI
import UIKit // Nécessaire pour UITextInputMode

struct ContentView: View {
    // MARK: - Propriétés d'état
    @State private var showInstructions = false
    @State private var isKeyboardEnabled = false
    
    let keyboardBundleID = "fr.eda.MonClavierApp"
    
    // MARK: - Corps de la Vue
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                
                // 1. NAVIGATION VERS LA SCÈNE DE DÉTAIL
                NavigationLink(destination: DetailView()) {
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 100))
                        Text("IMAGE")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(40)
                    .background(Color(UIColor.systemGray6)) // Couleur de fond neutre
                    .cornerRadius(10)
                }
                .buttonStyle(.plain) // Style pour que ça ressemble à du contenu, pas à un bouton
                
                // 2. BOUTON D'ACTIVATION INTELLIGENT
                Button(action: {
                    // L'action du bouton est d'afficher les instructions.
                    // Le bouton sera désactivé si le clavier est déjà actif.
                    showInstructions = true
                }) {
                    HStack {
                        // L'icône change en fonction de l'état
                        Image(systemName: isKeyboardEnabled ? "checkmark.circle.fill" : "keyboard.fill")
                        
                        // Le texte change en fonction de l'état
                        Text(isKeyboardEnabled ? "Clavier activé !" : "Activer mon clavier")
                    }
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    // La couleur de fond change pour un retour visuel clair
                    .background(isKeyboardEnabled ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                // Désactive le bouton si le clavier est déjà activé.
                .disabled(isKeyboardEnabled)
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("APP")
            
            // 3. GESTION DE LA FEUILLE MODALE
            // Présente la vue d'instructions quand `showInstructions` est `true`.
            .sheet(isPresented: $showInstructions) {
                KeyboardActivationInstructionsView()
            }
            
            // 4. VÉRIFICATION DU STATUT DU CLAVIER
            // Vérifie une première fois quand la vue apparaît.
            .onAppear(perform: checkKeyboardStatus)
            // Vérifie à chaque fois que l'app revient au premier plan
            // (par exemple, après que l'utilisateur soit allé dans les Réglages).
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                checkKeyboardStatus()
            }
        }
    }
    
    // MARK: - Fonctions utilitaires
    private func checkKeyboardStatus() {
        // Nous utilisons la méthode de vérification qui est compatible avec toutes les versions d'iOS.
        let isEnabled = UITextInputMode.activeInputModes.contains { mode in
            // Un clavier personnalisé est identifié par son "Bundle ID" dans la propriété `primaryLanguage`.
            if let language = mode.primaryLanguage, language.contains(keyboardBundleID) {
                return true
            }
            return false
        }
        
        // Met à jour la propriété d'état, ce qui rafraîchit l'interface utilisateur.
        self.isKeyboardEnabled = isEnabled
        
        if isEnabled {
            print("✅ Le clavier personnalisé (\(keyboardBundleID)) est activé.")
        } else {
            print("❌ Le clavier personnalisé n'est pas encore activé.")
        }
    }
}

// MARK: - Prévisualisation
#Preview {
    ContentView()
}
