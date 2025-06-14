import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Créer la vue SwiftUI
        // On passe le textDocumentProxy pour que SwiftUI puisse interagir avec le champ de texte
        let swiftUIView = KeyboardView(textDocumentProxy: self.textDocumentProxy)
        
        // 2. Créer un UIHostingController pour héberger la vue SwiftUI
        let hostingController = UIHostingController(rootView: swiftUIView)
        
        // 3. Ajouter la vue de l'hostingController à la hiérarchie de vues
        self.view.addSubview(hostingController.view)
        
        // 4. Désactiver la traduction des contraintes automatiques
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 5. Configurer les contraintes pour que la vue SwiftUI remplisse tout l'espace
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}
