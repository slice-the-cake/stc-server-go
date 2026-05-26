package main

import (
	"context"
	"fmt"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"io"
	"log"
	"log/slog"
	"net/http"
	"os"
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
	http.HandleFunc("/users", func(w http.ResponseWriter, r *http.Request) {
		ctx := context.Background()
		dbpool, err := pgxpool.New(ctx, os.Getenv("DB_URL"))
		if err != nil {
			slog.Error("Error while creating the pg pool: %s", err)
			w.WriteHeader(500)
			w.Write([]byte("Database pool error"))
			return
		}
		defer dbpool.Close()
		var tx pgx.Tx
		tx, err = dbpool.Begin(ctx)
		if err != nil {
			slog.Error("Error while beginning a pg transaction: %s", err)
			w.WriteHeader(500)
			w.Write([]byte("Database transaction error"))
			return
		}
		defer tx.Rollback(ctx)
		defer tx.Conn().Close(ctx)
		w.Write([]byte("Connected!"))
	})
	log.Fatal(http.ListenAndServe(":8090", nil))
}
