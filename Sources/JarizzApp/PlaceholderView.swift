import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("jarizz")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
