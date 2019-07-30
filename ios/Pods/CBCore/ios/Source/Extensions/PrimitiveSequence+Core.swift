// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import RxSwift

extension PrimitiveSequence where Trait == RxSwift.SingleTrait {
    /// Helper method to return Single.just(())
    public static func justVoid() -> Single<Void> {
        return .just(())
    }

    /// Maps the current observable to a `Single<Void>`
    public func asVoid() -> PrimitiveSequence<SingleTrait, Void> {
        return map { _ -> Void in () }
    }

    /// Retry Single on error using given delay.
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
    ) -> PrimitiveSequence<SingleTrait, Element> {
        return retryWhen { errors in
            errors.enumerated().flatMap { attempt, error -> Observable<Void> in
                guard maxAttempts > attempt + 1 else { return .error(error) }

                return Observable<Int>.timer(delay, scheduler: scheduler).asVoid()
            }
        }
    }

    /// Retry Single on error if given closure returns true.
    ///
    /// - Paramters:
    ///     - maxAttempts: Maximum number of times to attempt the sequence subscription.
    ///     - shouldRetry: Closure called to determine whether to continue retring
    ///
    /// - Returns: Next sequence in the stream or error is thrown once maxAttempts is reached or closure returns false.
    public func retryIfNeeded(
        _ maxAttempts: Int,
        shouldRetry: @escaping (Error) -> Bool
    ) -> PrimitiveSequence<SingleTrait, Element> {
        return retryWhen { (errors: Observable<Error>) in
            errors.enumerated().flatMap { attempt, error -> Observable<Void> in
                guard maxAttempts > attempt + 1, shouldRetry(error) else { return .error(error) }

                return .just(())
            }
        }
    }
}
