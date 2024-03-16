package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/gorilla/mux"
)

func helloWorld(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(os.Stdout, "Hello, Golang!")
	fmt.Fprintf(w, "Hello, Golang!")
}

func main() {
	router := mux.NewRouter()
	router.HandleFunc("/", helloWorld).Methods("GET")

	http.ListenAndServe(":8000", router)
}
