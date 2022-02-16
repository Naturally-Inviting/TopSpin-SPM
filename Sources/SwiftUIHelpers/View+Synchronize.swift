import SwiftUI

public extension View {
    /// Synchronizes a binding with a Focus State binding.
    /// Very important for syncing store Focused field state with SwiftUI FocusState.
    func synchronize<Value: Equatable>(
        _ first: Binding<Value>,
        _ second: FocusState<Value>.Binding
    ) -> some View {
        self
            .onChange(of: first.wrappedValue) { second.wrappedValue = $0 }
            .onChange(of: second.wrappedValue) { first.wrappedValue = $0 }
    }
}

