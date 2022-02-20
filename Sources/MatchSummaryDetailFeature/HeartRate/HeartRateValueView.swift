import SwiftUI

struct HeartRateValueView: View {
    var title: String
    var subtitle: String
    
    var body: some View {
        #if os(watchOS)
        VStack(alignment: .leading) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.title2)
        }
        #else
        VStack {
            Text(title.uppercased())
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.title2)
        }
        #endif
    }
}

struct HeartRateValueView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateValueView(title: "AVG", subtitle: "160")
    }
}
