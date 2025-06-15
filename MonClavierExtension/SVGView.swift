import SwiftUI
import SVGKit

private class BundleFinder {}

struct SVGView: View {
    let named: String
    
    private var svgUIImage: UIImage {
        let extensionBundle = Bundle(for: BundleFinder.self)
        guard let svgURL = extensionBundle.url(forResource: named, withExtension: "svg", subdirectory: "SVG") else {
            return UIImage()
        }
        
        guard let svgImage = SVGKImage(contentsOf: svgURL) else {
            return UIImage()
        }
        
        return svgImage.uiImage
    }

    var body: some View {
        Image(uiImage: svgUIImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
