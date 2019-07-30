// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import RxSwift

extension Observable {
    /// Take one entry from an observable and return it as a single
    public func takeSingle() -> Single<Element> {
        return take(1).asSingle()
    }

    /// Helper method to return Single.just(())
    public static func justVoid() -> Observable<Void> {
        return Observable<Void>.just(())
    }

    /// Maps the current observable to a `Observable<Void>`
    public func asVoid() -> Observable<Void> {
        return map { _ in () }
    }

    /// Retry Observable on error using given delay.
    ///
    /// - Parameters:
    ///     - maxAttempts: Maximum number of times to attempt the sequence subscription.
    ///     - delay: Number of miliseconds to wait before firing the next retry attempt
    ///     - sceduler: Scheduler to run delay timers on.
    ///
    /// - Returns: Next sequence in the stream or error is thrown once maxAttempts is reached.
    public func retry(
        _ maxAttempts: Int,
        delay: RxTimeInterval,
        scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    ) -> Observable<Element> {
        return retryWhen { errors in
            errors.enumerated().flatMap { attempt, error -> Observable<Void> in
                guard maxAttempts > attempt + 1 else { return .error(error) }

                return Observable<Int>.timer(delay, scheduler: scheduler).asVoid()
            }
        }
    }
}

extension Observable where Element: OptionalType {
    /// Safe unwrap element. Note this will block the chain until a valid non-nil value is available
    public func unwrap() -> Observable<Element.Wrapped> {
        return filter { $0.asOptional != nil }
            .map { element in
                guard let element = element.asOptional else { throw ObservableError.unableToUnwrap }
                return element
            }
    }
}

public protocol OptionalType {
    associatedtype Wrapped
    var asOptional: Wrapped? { get }
}

extension Optional: OptionalType {
    public var asOptional: Wrapped? { return self }
}

private enum ObservableError: Error {
    // shoud never be thrown. Needed to support `unwrap()` function above
    case unableToUnwrap
}
