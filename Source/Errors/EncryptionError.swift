// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

enum EncryptionError: Error {
    /// Error thrown when we are unable to generate an authentication tag
    case unableToGenerateAuthenticationTag

    /// Error thrown when supplied with invalid AES-256 GCM parameters
    case invalidAES256GCMData

    /// Error thrown when encryption fails
    case unableToEncryptData

    /// Error thrown when decryption fails
    case unableToDecryptData
}
