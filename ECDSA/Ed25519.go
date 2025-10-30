import (
    "crypto/ecdsa"
    "crypto/elliptic"
    "crypto/rand"
    "crypto/ed25519"
)

// ECDSA
priv, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
pub := &priv.PublicKey

// Ed25519
pubEd, privEd, _ := ed25519.GenerateKey(rand.Reader)
msg := []byte("message")
sig := ed25519.Sign(privEd, msg)
ed25519.Verify(pubEd, msg, sig)
