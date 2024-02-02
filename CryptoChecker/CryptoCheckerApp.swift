//
//  CryptoCheckerApp.swift
//  CryptoChecker
//
//  Created by Viktor Jansson on 2024-01-30.
//

import SwiftUI
import ComposableArchitecture

@main
struct MyApp: App {
  var body: some Scene {
    WindowGroup {
        SplashFeature.View(
        store: Store(initialState: SplashFeature.State()) {
          SplashFeature()
        }
      )
    }
  }
}
