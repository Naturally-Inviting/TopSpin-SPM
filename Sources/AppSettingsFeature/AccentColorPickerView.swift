import SwiftUI

struct AccentColorPickerView: View {
    @Binding var accentColor: AccentColor
    
    var body: some View {
        List(AccentColor.allCases) { color in
            Button(action: { accentColor = color }) {
                HStack {
                    color.color
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    
                    Text(color.title.capitalized)
                        .foregroundColor(.primary)
                    Spacer()
                    
                    if color == accentColor {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .navigationTitle("Accent Color")
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct AccentColorPickerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AccentColorPickerView(accentColor: .constant(.blue))
            
            NavigationView {
                AccentColorPickerView(accentColor: .constant(.blue))
                    .preferredColorScheme(.dark)
            }
        }
    }
}
