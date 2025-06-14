import SwiftUI
import SwiftSVG

private class BundleFinder {}

struct SVGView: UIViewRepresentable {
    let named: String
    var padding: CGFloat = 8.0

    class InternalSVGHostView: UIView {
        var svgLayer: CALayer?

        override func layoutSubviews() {
            super.layoutSubviews()
            
            guard let svgLayer = self.svgLayer,
                  let contentLayer = svgLayer.sublayers?.first else {
                return
            }
            
            svgLayer.frame = self.bounds
            
            let contentBounds = contentLayer.bounds
            guard contentBounds.width > 0, contentBounds.height > 0 else { return }
            
            let targetSize = self.bounds.insetBy(dx: 8, dy: 8).size
            
            let scaleX = targetSize.width / contentBounds.width
            let scaleY = targetSize.height / contentBounds.height
            
            let scale = min(scaleX, scaleY)
            
            contentLayer.transform = CATransform3DMakeScale(scale, scale, 1)
            contentLayer.position = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        }
    }

    func makeUIView(context: Context) -> InternalSVGHostView {
        let hostView = InternalSVGHostView()
        hostView.clipsToBounds = true
        hostView.backgroundColor = .clear

        let extensionBundle = Bundle(for: BundleFinder.self)

        if let svgURL = extensionBundle.url(forResource: named, withExtension: "svg", subdirectory: "SVG") {
            let svgLayer = CALayer(svgURL: svgURL) { layer in
                layer.backgroundColor = UIColor.clear.cgColor
                hostView.setNeedsLayout()
            }
            hostView.svgLayer = svgLayer
            hostView.layer.addSublayer(svgLayer)
        } else {
            print("🚨 ERREUR : Fichier SVG '\(named).svg' INTROUVABLE dans le sous-dossier 'SVG'.")
        }
        return hostView
    }

    func updateUIView(_ uiView: InternalSVGHostView, context: Context) {
        // Pas d'action nécessaire
    }
}
