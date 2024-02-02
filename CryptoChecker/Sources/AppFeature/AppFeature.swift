import ComposableArchitecture
import Foundation
import SwiftUI

public struct AppFeature {}

extension AppFeature {
    @ObservableState
    public struct State: Equatable {}
    
    public enum Action: Equatable {}
}

extension AppFeature {
    struct View: SwiftUI.View {
        
        var body: some SwiftUI.View {
            Text("AppFeature")
        }
    }
}
