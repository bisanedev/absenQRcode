package controllers

import (
	"log"
	"encoding/json"
	"github.com/gin-gonic/gin"				
	"github.com/gorilla/websocket"

	"../config"
)

type Basic struct {

}

func (basic *Basic) JsonSuccess (c *gin.Context, status int, h gin.H) {
	h["status"] = true
	(*c).JSON(status , h)
	return
}

func (basic *Basic) JsonFail (c *gin.Context, status int, message string) {
	(*c).JSON(status , gin.H{
		"status" 	: false,
		"message"	: message,
	})
}

func (basic *Basic) Role (c *gin.Context, rules string) bool {
	role := (*c).MustGet("rules").(string)
	if role == rules || role == "superuser" {
		return true
	}else{
		return false
	}
}


func (basic *Basic) SocketSendQRcode (arr QrcodeMSG) {
	u := "ws://"+config.Get().Addr+"/websocket/qrcode?tipe=server&token="+config.Get().TokenWebsocket
	c, _, err := websocket.DefaultDialer.Dial(u, nil)	
	if err != nil {
		log.Println("dial:", err)			
	}
	defer c.Close()	
	emp, _ := json.Marshal(arr)
	c.WriteMessage(websocket.TextMessage, []byte(emp))
	if err != nil {
		log.Println("write:", err)
		return
	}
}

type QrcodeMSG struct {
	From 	string		`json:"from"`
	To 		string		`json:"to"`
	Data 	string		`json:"data"`	
}