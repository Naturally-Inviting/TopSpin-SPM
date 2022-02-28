import ComposableArchitecture
import SwiftUI
import SwiftUIHelpers
import World

// MARK: - Match Controller

public typealias MatchControllerReducer = Reducer<MatchControllerState, MatchControllerAction, MatchControllerEnvironment>

public struct MatchControllerState: Equatable {
    public init(
        isPaused: Bool = false,
        isWorkoutAvailable: Bool = true,
        alert: AlertState<MatchControllerAction>? = nil
    ) {
        self.isWorkoutAvailable = isWorkoutAvailable
        self.isPaused = isPaused
        self.alert = alert
    }
    
    var isWorkoutAvailable: Bool = true
    var isPaused: Bool = false
    @BindableState var alert: AlertState<MatchControllerAction>? = nil
}

public enum MatchControllerAction: Equatable, BindableAction {
    case binding(BindingAction<MatchControllerState>)
    case pauseTapped
    case cancelTapped
    case cancelWorkoutTapped
    
    case workoutCancelled
    case matchCancelled
    
    case alertDismissed
}

public struct MatchControllerEnvironment {}

public let matchControllerReducer = MatchControllerReducer
{ state, action, environment in
    switch action {
    case .alertDismissed:
        state.alert = nil
        return .none
        
    case .cancelTapped:
        state.alert = .init(
            title: .init("Cancel Match?"),
            message: .init("This will cancel your workout as well."),
            buttons: [
                .destructive(.init("Yes, Cancel"), action: .send(.matchCancelled)),
                .default(.init("No"), action: .send(.alertDismissed))
            ]
        )
        
        return .none
        
    case .cancelWorkoutTapped:
        state.alert = .init(
            title: .init("Cancel Workout?"),
            message: .init("Current workout data will still be saved."),
            buttons: [
                .destructive(.init("Yes, Cancel"), action: .send(.workoutCancelled)),
                .default(.init("No"), action: .send(.alertDismissed))
            ]
        )
        
        return .none
    case .pauseTapped:
        state.isPaused.toggle()
        return .none
        
    default:
        return .none
    }
}
.binding()

public struct MatchControllerView: View {
    let store: Store<MatchControllerState, MatchControllerAction>
    @ObservedObject var viewStore: ViewStore<MatchControllerState, MatchControllerAction>
    
    public init(
        store: Store<MatchControllerState, MatchControllerAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        VStack {
            HStack {
                VStack {
                    Button(action: { viewStore.send(.cancelTapped) }) {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderedButtonStyle(tint: .red))
                    
                    Text("Cancel")
                }
                
                VStack {
                    Button(action: { viewStore.send(.pauseTapped) }) {
                        Image(systemName: viewStore.isPaused ? "arrow.clockwise" : "pause")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(BorderedButtonStyle(tint: .blue))
                    
                    Text(viewStore.isPaused ? "Resume" : "Pause")
                }
            }
            
            HStack {
                Spacer()
                
                VStack {
                    Button(action: { viewStore.send(.cancelWorkoutTapped) }) {
                        Image(systemName: "heart")
                            .font(.title3)
                            .foregroundColor(.yellow)
                    }
                    .buttonStyle(BorderedButtonStyle(tint: .yellow))
                    
                    Text("Cancel Workout")
                }
                
                Spacer()
            }
            .isHidden(!viewStore.isWorkoutAvailable, remove: true)
        }
        .alert(
            self.store.scope(state: \.alert),
            dismiss: .alertDismissed
        )
    }
}

struct MatchControllerView_Previews: PreviewProvider {
    
    static var previews: some View {
        MatchControllerView(
            store: Store(
                initialState: .init(),
                reducer: matchControllerReducer,
                environment: .init()
            )
        )
    }
}
