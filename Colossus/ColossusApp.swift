import SwiftUI
import ComposableArchitecture

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
            
        }
    }
}
