package com.coinbase.wallet.crypto.exceptions

import java.lang.Exception

sealed class EncryptionException(msg: String) : Exception(msg) {
    /**
     * Error thrown when encryption fails
     */
    object UnableToEncryptData : EncryptionException("Unable to encrypt data")

    /**
     * Error thrown when decryption fails
     */
    object UnableToDecryptData : EncryptionException("Unabel to decrypt data")
}