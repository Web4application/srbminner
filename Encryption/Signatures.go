import (
    "crypto/rsa"
    "crypto/rand"
    "crypto/sha256"
)

priv, _ := rsa.GenerateKey(rand.Reader, 2048)
pub := &priv.PublicKey

ciphertext, _ := rsa.EncryptOAEP(sha256.New(), rand.Reader, pub, []byte("secret"), nil)
plaintext, _ := rsa.DecryptOAEP(sha256.New(), rand.Reader, priv, ciphertext, nil)
