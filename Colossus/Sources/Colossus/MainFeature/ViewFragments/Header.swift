import SwiftUI
import Foundation

struct Header: View {
    var body: some View {
        HStack(spacing: 30) {
            Text("Name")
                .foregroundStyle(Color("AccentColor"))
            Spacer()
            Text("Bid")
                .foregroundStyle(Color("AccentColor"))
            Text("Ask")
                .foregroundStyle(Color("AccentColor"))
        }
        .padding(.leading)
        .padding(.trailing, 50)
    }
}
