import ComposableArchitecture
import Combine

extension Effect where Failure == Never {
    public static func keyFrames<S>(
        values: [(output: Output, duration: S.SchedulerTimeType.Stride)],
        scheduler: S
    ) -> Effect where S: Scheduler {
        .concatenate(
            values
                .enumerated()
                .map { index, animationState in
                    index == 0
                    ? Effect(value: animationState.output)
                    : Just(animationState.output)
                        .delay(for: values[index - 1].duration, scheduler: scheduler)
                        .eraseToEffect()
                }
        )
    }
}
