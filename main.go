package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
)

func main() {
	http.HandleFunc("/hello", func(w http.ResponseWriter, r *http.Request) {
		b, err := io.ReadAll(r.Body)
		if err != nil {
			fmt.Fprintf(w, "Error while reading body: %s", err)
			return
		}
		fmt.Fprintf(w, "Hello from STC server! Here's the body that was sent: %s", b)
	})
	log.Fatal(http.ListenAndServe(":8080", nil))
}
