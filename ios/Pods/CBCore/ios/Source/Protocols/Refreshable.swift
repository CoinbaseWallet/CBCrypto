// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import RxSwift

/// Represents an object that can be refreshed manually
public protocol Refreshable {
    /// Called to refresh conformers of this protocol
    ///
    /// - Parameters:
    ///     - isForced: Indicates whether conformer of this protocol should ignore all conditions and force a refresh
    ///
    /// - Returns: A single void indicating the refresh operation completed
    func refresh(isForced: Bool) -> Single<Void>
}
