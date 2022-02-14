import ComposableArchitecture
import SwiftUI

public struct AddMatchView: View {
    let store: Store<AddMatchState, AddMatchAction>
    @ObservedObject var viewStore: ViewStore<AddMatchState, AddMatchAction>
    
    public init(
        store: Store<AddMatchState, AddMatchAction>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        Form {
            Section(footer: Text("Match Details")) {
                #if os(iOS)
                DatePicker("Date", selection: viewStore.binding(\.$matchDate))
                #endif
                TextField("Player Score", text: viewStore.binding(\.$playerScoreText))
                TextField("Opponent Score", text: viewStore.binding(\.$opponentScoreText))
            }
            
            Section(footer: Text("Workout Details")) {
                Toggle("Enabled", isOn: viewStore.binding(\.$isWorkoutEnabled))
                
                if viewStore.isWorkoutEnabled {
                    #if os(iOS)
                    DatePicker("Start Date", selection: viewStore.binding(\.$workoutStartDate))
                    DatePicker("End Date", selection: viewStore.binding(\.$workoutEndDate))
                    #endif
                    
                    TextField("Active Calories", text: viewStore.binding(\.$activeCaloriesText))
                    TextField("Heart Rate Average", text: viewStore.binding(\.$heartRateAverageText))
                    TextField("Heart Rate Max", text: viewStore.binding(\.$heartRateMaxText))
                    TextField("Heart Rate Min", text: viewStore.binding(\.$heartRateMinText))
                }
            }
        }
        .navigationTitle("Add Match")
        .alert(
            self.store.scope(state: \.alert),
            dismiss: .alertDismissed
        )
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if viewStore.isSaveMatchRequestInFlight {
                    ProgressView()
                } else {
                    Button("Save", action: { viewStore.send(.saveButtonTapped) })
                }
            }
        }
    }
}

struct AddMatchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddMatchView(
                store: Store(
                    initialState: .init(),
                    reducer: addMatchReducer,
                    environment: .init(
                        mainQueue: .main,
                        matchClient: .init(
                            fetch: {
                                .failing("Fetch not setup")
                            }, create: { _ in
                                .failing("Create not setup")
                            }, delete: { _ in
                                .failing("Delete not setup")
                            }
                        )
                    )
                )
            )
        }
    }
}
