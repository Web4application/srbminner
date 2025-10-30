import "crypto/rand"
import "math/big"

// Random integer < max
max := big.NewInt(1000000)
n, _ := rand.Int(rand.Reader, max)

// Random 32-byte key
key := make([]byte, 32)
rand.Read(key)
