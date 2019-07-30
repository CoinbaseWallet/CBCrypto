// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import RxSwift

/// Represents an object that can be destroyed
public protocol Destroyable {
    /// Called to destroy conformers of this protocol
    func destroy() -> Single<Bool>
}
