#if os(watchOS)
import SwiftUI

struct HistoryEmptyView: View {
    var body: some View {
        Text("Start a Match for it to appear in Match History.")
            .font(.headline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
    }
}

struct HistoryEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HistoryEmptyView()
            HistoryEmptyView()
                .preferredColorScheme(.dark)
        }
    }
}
#endif
