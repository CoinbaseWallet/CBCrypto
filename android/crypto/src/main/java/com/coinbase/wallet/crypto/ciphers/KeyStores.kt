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
    /**
     * Get AES secret key for the given keystore, alias and spec. This method will return the existing key, or
     * create a new key.
     *
     * @param keystore the name of the keystore (in practice, will always be "AndroidKeyStore"
     * @param alias the alias of the secret key to get or create
     * @param keySpec the spec to use to create the key if creation is needed.
     */
    @Throws(
        KeyStoreException::class,
        IOException::class,
        NoSuchAlgorithmException::class,
        CertificateException::class,
        UnrecoverableEntryException::class
    )
    fun getSecretKey(keystore: String, alias: String, spec: KeyGenParameterSpec): SecretKey = CipherLock.withLock {
        // Attempt to fetch existing stored secret key from Android KeyStore
        val keyStore = KeyStore.getInstance(keystore)
        keyStore.load(null)
        val entry = keyStore.getEntry(alias, null) as? KeyStore.SecretKeyEntry
        val secretKey = entry?.secretKey

        if (secretKey != null) return secretKey

        // At this point, no secret key is stored so generate a new one.
        val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, keystore)
        keyGenerator.init(spec)

        return keyGenerator.generateKey()
    }
}
