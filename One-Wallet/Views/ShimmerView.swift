//
//  ShimmerView.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 09/03/1442 AH.
//

// based on https://github.com/VasudhaJha/ShimmerAnimationComplete/blob/master/ShimmerAnimationComplete/ShimmerView.swift

import UIKit

protocol ShimmerView where Self: UIView {
  var gradientColorOne: CGColor { get }
  var gradientColorTwo: CGColor { get }
  func addGradientLayer() -> CAGradientLayer
  func addAnimation() -> CABasicAnimation
  func startAnimating()
}

extension ShimmerView {
  func addGradientLayer() -> CAGradientLayer {
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.frame = self.bounds
    gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
    gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
    gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
    gradientLayer.locations = [0.0, 0.5, 1.0]
    self.layer.addSublayer(gradientLayer)
    
    return gradientLayer
  }
  
  func addAnimation() -> CABasicAnimation {
    
    let animation = CABasicAnimation(keyPath: "locations")
    animation.fromValue = [-1.0, -0.5, 0.0]
    animation.toValue = [1.0, 1.5, 2.0]
    animation.repeatCount = .infinity
    animation.duration = 0.9
    return animation
  }
  
  func startAnimating() {
    let gradientLayer = addGradientLayer()
    let animation = addAnimation()
    
    gradientLayer.add(animation, forKey: animation.keyPath)
  }
}

extension UIView: ShimmerView {
  var gradientColorOne: CGColor {
    UIColor(white: 0.85, alpha: 1.0).cgColor
  }
  
  var gradientColorTwo: CGColor {
    UIColor(white: 0.95, alpha: 1.0).cgColor
  }
}
