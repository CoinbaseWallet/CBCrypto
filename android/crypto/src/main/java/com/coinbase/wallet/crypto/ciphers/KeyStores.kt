package com.coinbase.wallet.crypto.ciphers

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import java.io.IOException
import java.security.KeyStore
import java.security.KeyStoreException
import java.security.NoSuchAlgorithmException
import java.security.UnrecoverableEntryException
import java.security.cert.CertificateException
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import kotlin.concurrent.withLock

object KeyStores {
    @Throws(
        KeyStoreException::class,
        IOException::class,
        NoSuchAlgorithmException::class,
        CertificateException::class,
        UnrecoverableEntryException::class
    )
    fun getSecretKey(keystore: String, alias: String): SecretKey = CipherLock.withLock {
        // Attempt to fetch existing stored secret key from Android KeyStore
        val keyStore = KeyStore.getInstance(keystore)

        keyStore.load(null)

        val entry = keyStore.getEntry(alias, null) as? KeyStore.SecretKeyEntry
        val secretKey = entry?.secretKey

        if (secretKey != null) return secretKey

        // At this point, no secret key is stored so generate a new one.
        val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, keystore)

        val spec = KeyGenParameterSpec
            .Builder(alias, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .build()

        keyGenerator.init(spec)

        return keyGenerator.generateKey()
    }
}
