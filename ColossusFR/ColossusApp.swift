import SwiftUI
import ComposableArchitecture
import SwiftData
@_exported import Colossus

@main
struct Colossus: App {
    var body: some Scene {
        WindowGroup { 
            AppFeature.View(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                        ._printChanges()
                }
            )
            .buttonStyle(.borderedProminent)
        }
    }
}

