import (
    "crypto/hmac"
    "crypto/sha256"
)

key := []byte("secret")
msg := []byte("hello")

mac := hmac.New(sha256.New, key)
mac.Write(msg)
sum := mac.Sum(nil)
