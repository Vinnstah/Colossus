import SwiftUI
import Foundation

extension MainFeature.View {
    @ViewBuilder
    func header() -> some View {
        HStack(spacing: 30) {
            Picker("Time Interval", selection: $store.timeInterval) {
                ForEach(TimeIntervalMilliseconds.allCases, id: \.self) {
                    Text($0.descrition)
                        .foregroundStyle(Color.black)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(.leading)
        .padding(.trailing, 50)
    }
}
