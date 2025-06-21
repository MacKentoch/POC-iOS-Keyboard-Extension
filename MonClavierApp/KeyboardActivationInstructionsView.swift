// KeyboardActivationInstructionsView.swift
import SwiftUI

struct KeyboardActivationInstructionsView: View {
    // Pour pouvoir fermer la vue
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            Text("Comment activer 'Mon clavier extension'")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom)

            // Instruction 1
            HStack(alignment: .top) {
                Image(systemName: "1.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("Appuyez sur le bouton ci-dessous pour ouvrir les **Réglages** de l'iPhone.")
            }
            
            // Instruction 2
            HStack(alignment: .top) {
                Image(systemName: "2.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("Allez dans **Général > Clavier > Claviers**.")
            }
            
            // Instruction 3
            HStack(alignment: .top) {
                Image(systemName: "3.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("Appuyez sur **Ajouter un clavier...** et sélectionnez **MonClavierExtension — MonClavierApp** dans la liste.")
            }
            
            // Instruction 4
            HStack(alignment: .top) {
                Image(systemName: "4.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("Appuyez sur **MonClavierExtension — MonClavierApp** dans votre liste de claviers et activez **'Autoriser l'accès complet'**.")
            }
            
            Spacer()
            
            // Le bouton qui ouvre l'application Réglages
            Button(action: {
                openSettings()
            }) {
                HStack {
                    Image(systemName: "gear")
                    Text("Ouvrir les Réglages")
                }
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            // Bouton pour fermer cette feuille d'instructions
            Button("Terminé") {
                dismiss() // Ferme la vue
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)

        }
        .padding(30)
    }

    /// Ouvre l'application Réglages.
    /// C'est la seule méthode autorisée par Apple pour envoyer un utilisateur
    /// vers les réglages depuis une app tierce.
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
}

#Preview {
    KeyboardActivationInstructionsView()
}
