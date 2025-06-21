import SwiftUI
import UIKit // Nécessaire pour UITextInputMode

struct ContentView: View {
    // MARK: - Propriétés d'état
    @State private var showInstructions = false
    @State private var isKeyboardEnabled = false
    
    let keyboardBundleID = "fr.eda.MonClavierApp.MonClavierExtension"
    
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
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                
                // 2. BOUTON D'ACTIVATION INTELLIGENT
                Button(action: {
                    showInstructions = true
                }) {
                    HStack {
                        Image(systemName: isKeyboardEnabled ? "checkmark.circle.fill" : "keyboard.fill")
                        
                        Text(isKeyboardEnabled ? "Clavier activé !" : "Activer mon clavier")
                    }
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isKeyboardEnabled ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(isKeyboardEnabled)
                
                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("APP")
            
            // 3. GESTION DE LA MODALE
            .sheet(isPresented: $showInstructions) {
                KeyboardActivationInstructionsView()
            }
            
            // 4. VÉRIFICATION DU STATUT DU CLAVIER
            .onAppear(perform: checkKeyboardStatus)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                checkKeyboardStatus()
            }
        }
    }
    
    // MARK: - Fonctions utilitaires
    private func checkKeyboardStatus() {
        // Méthode de vérification qui est compatible avec toutes les versions d'iOS.
        let isEnabled = UITextInputMode.activeInputModes.contains { mode in
            // Un clavier personnalisé est identifié par son "Bundle ID" dans la propriété `primaryLanguage`.
            if let language = mode.primaryLanguage, language.contains(keyboardBundleID) {
                return true
            }
            return false
        }
        
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
