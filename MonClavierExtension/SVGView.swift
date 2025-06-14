import SwiftUI
import SwiftSVG

private class BundleFinder {}

struct SVGView: UIViewRepresentable {
    let named: String

    class InternalSVGHostView: UIView {
        var svgLayer: CALayer?

        override func layoutSubviews() {
            super.layoutSubviews()
            svgLayer?.frame = self.bounds
        }
    }
    
    func makeUIView(context: Context) -> InternalSVGHostView {
        let hostView = InternalSVGHostView()
        hostView.clipsToBounds = true
        
        let extensionBundle = Bundle(for: BundleFinder.self)
        
        if let svgURL = extensionBundle.url(forResource: named, withExtension: "svg", subdirectory: "SVG") {
            let svgLayer = CALayer(svgURL: svgURL) { (layer) in
                layer.backgroundColor = UIColor.clear.cgColor
                layer.frame = hostView.bounds
            }

            hostView.svgLayer = svgLayer
            hostView.layer.addSublayer(svgLayer)
            
        } else {
            print("🚨 ERREUR : Fichier SVG '\(named).svg' INTROUVABLE dans le sous-dossier 'SVG'.")
        }
        
        return hostView
    }
    
    func updateUIView(_ uiView: InternalSVGHostView, context: Context) {
        //
    }
}
