import SwiftUI
import SVGKit

private class BundleFinder {}

struct SVGView: View {
    let named: String
    @State private var uiImage: UIImage? = nil
    
    var body: some View {
        if let image = uiImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        } else {
            Rectangle()
                .fill(Color.clear)
                .onAppear(perform: loadImage)
        }
    }
    
    private func loadImage() {
        guard uiImage == nil else { return }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let extensionBundle = Bundle(for: BundleFinder.self)
            
            guard let svgURL = extensionBundle.url(forResource: named, withExtension: "svg", subdirectory: "SVG") else {
                print("⚠️ Erreur: Fichier SVG '\(named).svg' introuvable dans le sous-dossier 'SVG'.")
                return
            }
            
            guard let svgImage = SVGKImage(contentsOf: svgURL) else {
                print("⚠️ Erreur: Impossible de parser le fichier SVG à l'URL : \(svgURL)")
                return
            }

            DispatchQueue.main.async {
                self.uiImage = svgImage.uiImage
            }
        }
    }
}
