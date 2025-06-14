import SwiftUI
import SwiftSVG

struct SVGView: UIViewRepresentable {
    let named: String
    var contentMode: UIView.ContentMode = .scaleAspectFit
    
    func makeUIView(context: Context) -> UIView {
        let uiView = UIView()
        
        if let svgURL = Bundle.main.url(forResource: named, withExtension: "svg", subdirectory: "SVG") {
            print("URL trouvée : \(svgURL)")
            let svgLayer = CALayer(svgURL: svgURL) { layer in
                layer.frame = uiView.bounds
            }
            uiView.layer.addSublayer(svgLayer)
        } else {
            print("ERREUR : Fichier non trouvé -> \(named).svg dans le sous-dossier SVG")
        }
        
        uiView.setContentHuggingPriority(.required, for: .horizontal)
        uiView.setContentHuggingPriority(.required, for: .vertical)
        uiView.clipsToBounds = true
        return uiView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.layer.sublayers?.first?.frame = uiView.bounds
        uiView.contentMode = contentMode
    }
}
