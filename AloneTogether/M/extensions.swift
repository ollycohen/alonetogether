//
//  extensions.swift
//  AloneTogether
//
//  Created by Benjamin Faber on 12/3/20.
//  Copyright © 2020 Oliver K Cohen. All rights reserved.
//

import Foundation
import UIKit



//THIS WAS TAKEN FROM: https://stackoverflow.com/questions/59237515/add-glow-effect-to-text-of-a-ui-button-swift
extension UIView {
    enum GlowEffect: Float {
        case small = 0.4, normal = 2, big = 30
    }

    func doGlowAnimation(withColor color: UIColor, withEffect effect: GlowEffect = .big) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowRadius = 0
        layer.shadowOpacity = 0.8
        layer.shadowOffset = .zero

        let glowAnimation = CABasicAnimation(keyPath: "shadowRadius")
        glowAnimation.fromValue = 0
        glowAnimation.toValue = effect.rawValue
        glowAnimation.fillMode = .removed
        glowAnimation.repeatCount = .infinity
        glowAnimation.duration = 2
        glowAnimation.autoreverses = true
        layer.add(glowAnimation, forKey: "shadowGlowingAnimation")
    }
}

//https://stackoverflow.com/questions/29209453/how-to-hide-a-navigation-bar-from-first-viewcontroller-in-swift
extension UIViewController {
    func hideNavigationBar(animated: Bool){
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

    }

    func showNavigationBar(animated: Bool) {
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

}
