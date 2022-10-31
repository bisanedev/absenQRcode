package main

import (
	"fmt"
	"encoding/base64"
	qrcode "github.com/skip2/go-qrcode"
)

func main() {
	// var png []byte	
	if png, err := qrcode.Encode("T7XDnAjMHTfP4QbzABjxgBZRVNuS5E5rucPglH3jdB7MWbgJRf", qrcode.Medium, 256); err != nil {
		fmt.Printf("Error: %s", err.Error())
	} else {
		sEnc := base64.StdEncoding.EncodeToString(png)
	    fmt.Println(sEnc)
		//fmt.Printf("PNG is %d bytes long", png )
	}
}
