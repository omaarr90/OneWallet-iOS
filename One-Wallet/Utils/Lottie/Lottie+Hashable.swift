//
//  Lottie+Hashable.swift
//  One-Wallet
//
//  Created by Omar Alshammari on 27/02/1442 AH.
//

import Lottie

extension LottieLoopMode: Hashable {
  
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .playOnce:
      hasher.combine(LottieLoopMode.playOnce)
    case .loop:
      hasher.combine(LottieLoopMode.loop)
    case .autoReverse:
      hasher.combine(LottieLoopMode.autoReverse)
    case .repeat(let times):
      hasher.combine(times)
      hasher.combine("Lottie.LottieLoopMode.repeat")
    case .repeatBackwards( let times):
      hasher.combine(times)
      hasher.combine("Lottie.LottieLoopMode.repeatBackwards")
    }
  }
}
