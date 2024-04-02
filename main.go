package main

import "fmt"
import "net/http"
import "log"

func main() {
	http.HandleFunc("/hello", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello from STC server!")
	})
	log.Fatal(http.ListenAndServe(":8080", nil))
}
