import (
    "crypto/aes"
    "crypto/cipher"
    "crypto/rand"
)

key := []byte("32-byte-long-secret-key-for-AES-256")
plaintext := []byte("data")

block, _ := aes.NewCipher(key)
gcm, _ := cipher.NewGCM(block)
nonce := make([]byte, gcm.NonceSize())
rand.Read(nonce)

ciphertext := gcm.Seal(nil, nonce, plaintext, nil)
