// DetailView.swift
import SwiftUI

struct DetailView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.fill")
                .font(.system(size: 200))
                .foregroundColor(.blue)

            Text("IMAGE")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            Text("! . .")
                .font(.title)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Scène de Détail") // Titre de la nouvelle vue
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    // Pour prévisualiser la DetailView dans un contexte de navigation
    NavigationStack {
        DetailView()
    }
}
