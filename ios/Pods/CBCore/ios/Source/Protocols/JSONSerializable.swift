// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

/// Protocol representing a class that's serializable
public protocol JSONSerializable {
    var asJSONDictionary: [String: Any]? { get }
    var asJSONString: String? { get }
}

/// Default implementation for Codable conformers
extension JSONSerializable where Self: Codable {
    public var asJSONDictionary: [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            return data.jsonDictionary
        } catch {
            return nil
        }
    }

    public var asJSONString: String? {
        do {
            let data = try JSONEncoder().encode(self)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
