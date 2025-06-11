//
//  KeyboardViewController.swift
//  MonClavierExtension
//
//  Created by Rav3n on 12/06/2025.
//
// KeyboardViewController.swift
// KeyboardViewController.swift

import UIKit
import SwiftUI

class KeyboardViewController: UIInputViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Créer la vue SwiftUI en lui passant le proxy
        let keyboardView = KeyboardView(textDocumentProxy: self.textDocumentProxy)

        // 2. Créer un UIHostingController pour héberger notre vue SwiftUI
        let hostingController = UIHostingController(rootView: keyboardView)
        
        // 3. Ajouter la vue de l'hostingController à la vue principale
        // et gérer le cycle de vie du contrôleur
        self.addChild(hostingController)
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        // 4. Configurer les contraintes pour que la vue SwiftUI remplisse tout l'espace du clavier
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // On s'assure que notre vue SwiftUI respecte les guides de la zone de sécurité
        // du clavier, ce qui laissera de la place pour le bouton "globe" du système en bas.
        let constraints = [
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        // --- C'est tout ! Plus de bouton manuel ---
    }
}
