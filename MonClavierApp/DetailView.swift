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
            
            Text("SOMETHING")
                .font(.title)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Scène de Détail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        DetailView()
    }
}
