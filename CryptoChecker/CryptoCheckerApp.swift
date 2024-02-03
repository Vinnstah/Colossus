import SwiftUI
import ComposableArchitecture

@main
struct MyApp: App {
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
