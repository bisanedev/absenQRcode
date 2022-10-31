package main

import (
	"fmt"

	"./config"
	"./database"
	"./routes"
)

func main() {
	if err := config.Load("config.yaml"); err != nil {
		fmt.Println("Failed to load configuration")
		return
	}

	db, err := database.InitDB()
	if err != nil {
		fmt.Println("err open databases")
		return
	}

	defer db.Close()

	router := routes.InitRouter()
	router.Run(config.Get().Addr)
}
