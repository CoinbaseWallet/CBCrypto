// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import RxSwift

/// Represents an object that can be started
public protocol Startable {
    /// Called to start conformers of this protocol
    func start()
}
