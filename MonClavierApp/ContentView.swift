// ContentView.swift
import SwiftUI

struct ContentView: View {
    // État pour contrôler l'affichage de la feuille d'instructions
    @State private var showInstructions = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                
                NavigationLink(destination: DetailView()) {
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 100))
                        Text("IMAGE")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .padding(40)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)

                // Le bouton n'ouvre plus directement les réglages.
                // Il affiche la feuille d'instructions.
                Button(action: {
                    showInstructions = true
                }) {
                    Text("Activer mon clavier") // Texte plus descriptif
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 20)
            .navigationTitle("Mon clavier extension")
            // .sheet est un modificateur qui présente une nouvelle vue par-dessus l'actuelle.
            .sheet(isPresented: $showInstructions) {
                // Lorsque showInstructions devient true, cette vue est présentée.
                KeyboardActivationInstructionsView()
            }
        }
    }
}

#Preview {
    ContentView()
}
