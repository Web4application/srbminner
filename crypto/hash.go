import (
    "crypto/sha256"
    "crypto/sha512"
    "golang.org/x/crypto/sha3"
)

data := []byte("hello")

sha256.Sum256(data)
sha512.Sum512(data)
sha3.Sum256(data)
