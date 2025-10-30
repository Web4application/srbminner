package main

import (
    "io/ioutil"
    "os/exec"
    "log"
)

func main() {
    // 1. Write cheat‑sheet markdown to file
    mdContent := `# Go Crypto Cheat Sheet
    …
    // (paste content here)
    `
    err := ioutil.WriteFile("cheatsheet.md", []byte(mdContent), 0644)
    if err != nil {
        log.Fatal(err)
    }

    // 2. Invoke Pandoc to convert to PDF
    cmd := exec.Command("pandoc", "cheatsheet.md", "-o", "cheatsheet.pdf", "--highlight-style=pygments")
    err = cmd.Run()
    if err != nil {
        log.Fatal(err)
    }

    log.Println("PDF generated: cheatsheet.pdf")
}
