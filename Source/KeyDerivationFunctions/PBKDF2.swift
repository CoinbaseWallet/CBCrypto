// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import CommonCrypto
import CryptoSwift

public struct PBKDF2 {
    private static let keySize = kCCKeySizeAES256

    public static let pbkdf2Rounds: UInt32 = 50000

    public static func deriveKey(
        forPassword password: Data,
        withSalt salt: Data,
        iterations: UInt32 = pbkdf2Rounds
    ) -> Data {
        return password.withUnsafeBytes { (passwordPointer: UnsafePointer<Int8>) in
            salt.withUnsafeBytes { (saltPtr: UnsafePointer<UInt8>) -> Data in
                var derivedKey = Data(count: keySize)

                derivedKey.withUnsafeMutableBytes { (derivedKeyPointer: UnsafeMutablePointer<UInt8>) in
                    let algorithm = CCPBKDFAlgorithm(kCCPBKDF2)
                    let pseudoRandomAlgorithm = CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256)

                    let result = CCCryptorStatus(
                        CCKeyDerivationPBKDF(
                            algorithm,
                            passwordPointer,
                            password.count,
                            saltPtr,
                            salt.count,
                            pseudoRandomAlgorithm,
                            iterations,
                            derivedKeyPointer,
                            keySize
                        )
                    )

                    guard result == CCCryptorStatus(kCCSuccess) else {
                        fatalError("SECURITY FAILURE: Could not derive secure password (\(result))")
                    }
                }

                return derivedKey
            }
        }
    }
}
