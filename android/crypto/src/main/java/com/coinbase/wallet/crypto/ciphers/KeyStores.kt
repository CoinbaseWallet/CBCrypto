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
    private const val KEYSTORE = "AndroidKeyStore"

    /**
     * Get AES secret key for the given keystore, alias and spec. This method will return the existing key, or
     * create a new key.
     *
     * @param keySpec the spec to use to create the key if creation is needed.
     */
    @Throws(
        KeyStoreException::class,
        IOException::class,
        NoSuchAlgorithmException::class,
        CertificateException::class,
        UnrecoverableEntryException::class
    )
    fun getSecretKey(spec: KeyGenParameterSpec): SecretKey = CipherLock.withLock {
        // Attempt to fetch existing stored secret key from Android KeyStore
        val keyStore = KeyStore.getInstance(KEYSTORE)
        keyStore.load(null)
        val entry = keyStore.getEntry(spec.keystoreAlias, null) as? KeyStore.SecretKeyEntry
        val secretKey = entry?.secretKey

        if (secretKey != null) return secretKey

        // At this point, no secret key is stored so generate a new one.
        val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, KEYSTORE)
        keyGenerator.init(spec)

        return keyGenerator.generateKey()
    }

    /**
     * Check if the given keystore contains the alias
     *
     * @param alias the alias of the key to check if it exists
     */
    fun contains(alias: String): Boolean = CipherLock.withLock {
        val keyStore = KeyStore.getInstance(KEYSTORE)
        keyStore.load(null)
        return keyStore.containsAlias(alias)
    }

    /**
     * Delete the given key alias from the keystore if it exists
     *
     * @param alias the alias of the key to delete
     */
    fun delete(alias: String) = CipherLock.withLock {
        val keyStore = KeyStore.getInstance(KEYSTORE)
        keyStore.load(null)
        if (keyStore.containsAlias(alias)) keyStore.deleteEntry(alias)
    }
}
