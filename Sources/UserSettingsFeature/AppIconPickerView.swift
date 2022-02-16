import SwiftUI

struct AppIconImageView: View {
    var appIcon: AppIcon
    
    var body: some View {
        Image(uiImage: UIImage(named: appIcon.rawValue, in: Bundle.module, with: nil)!)
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

public struct AppIconPickerView: View {
    @Binding var appIcon: AppIcon?
    @Environment(\.colorScheme) var colorScheme

    public var body: some View {
        ZStack {
            Color(colorScheme == .light ? .secondarySystemBackground : .systemBackground)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 16) {
                    ForEach(AppIcon.allCases, id: \.self) { icon in
                        
                        Button(action: { appIcon = icon }) {
                            if self.appIcon == icon {
                                AppIconImageView(appIcon: icon)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(.secondary, lineWidth: 2)
                                    )
                                    .id(icon)
                            } else {
                                AppIconImageView(appIcon: icon)
                                    .id(icon)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding()
            }
            .navigationTitle("App Icon")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AppIconPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                AppIconPickerView(appIcon: .constant(.cadence))
            }
            
            NavigationView {
                AppIconPickerView(appIcon: .constant(.cadence))
            }
            .preferredColorScheme(.dark)
        }
    }
}

