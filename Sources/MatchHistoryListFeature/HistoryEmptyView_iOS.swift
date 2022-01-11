#if os(iOS)
import SwiftUI
import WatchConnectivity

public struct EmptyViewButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    var color: Color
    
    public init(color: Color = .blue) {
        self.color = color
    }
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.system(.title3, design: .default).bold())
            .foregroundColor(self.color)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.clear)
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(self.color, lineWidth: 1)
            )
            .padding()
            .padding(.horizontal)
    }
}

struct HistoryEmptyView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    var isConnected: Bool
    var isWCSessionSupported: Bool
    var onOpenSettingsTapped: () -> Void = {}

    var backgroundColor: Color {
        return colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground)
    }
    
    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                Image(systemName: "applewatch")
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.secondary)
                Text("Start a match on your wrist.\nWhen finished, it will display here.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    if !isConnected && isWCSessionSupported {
                        Button("Open Watch Settings", action: onOpenSettingsTapped)
                            .buttonStyle(EmptyViewButtonStyle())
                    }
                    
//                    Button("Add Manually", action: {})
//                        .font(.headline.bold())
//                        .padding()
//                        .foregroundColor(.secondary)
                }
                
                Spacer()
                Spacer()
            }
        }
    }
}

struct HistoryEmptyView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HistoryEmptyView(isConnected: false, isWCSessionSupported: true)
            HistoryEmptyView(isConnected: false, isWCSessionSupported: true)
                .preferredColorScheme(.dark)
        }
    }
}
#endif
