package routes

import (
	"log"
	"time"
	"math/rand"
	"encoding/json"
	"encoding/base64"
	"../config"
	"../database"
	"../models"
	"github.com/gorilla/websocket"
	qrcode "github.com/skip2/go-qrcode"	
)

var seededRand *rand.Rand = rand.New(rand.NewSource(time.Now().UnixNano()))
const charset = "abcdefghijklmnopqrstuvwxyz" + "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" + "!@#$&"


func QRreader() {	
	u := "ws://"+config.Get().Addr+"/websocket/qrcode?tipe=server&token="+config.Get().TokenWebsocket
	conn, _, err := websocket.DefaultDialer.Dial(u, nil)
	
	if err != nil {
		log.Println("dial:", err)			
	}

	defer conn.Close()
    for {
    /* --- cek always and read in a message --- */	
        messageType, p, err := conn.ReadMessage()
        if err != nil {
            log.Println(messageType,err)
            return
        }	
		CekDanKirim(p,conn);		
	}   
}
/* --- Fungsi kirim pesan ---*/
func CekDanKirim(pesan []byte,conn *websocket.Conn) {
	var machine models.Machine
	var qmsg QrcodeMSG	
	/* --- check username di database --- */  
	if err := json.Unmarshal(pesan, &qmsg); err != nil {		
		log.Println("JSON:",err)
	} 					
	if qmsg.To == "server" {
		if qmsg.Data == "get" {
			if database.DB.Where("username = ?", qmsg.From).First(&machine).Error != nil {								
				if err := conn.WriteMessage(websocket.TextMessage, []byte("Username Tidak Di temukan")); err != nil {					 
					log.Println(err)
				}	
				log.Println("Username Tidak Di temukan")
				return
			}
			JsonQR, _ := json.Marshal(Qencode{Username:machine.Username,Secret:machine.Secret})	
			if png, err := qrcode.Encode(string(JsonQR), qrcode.Medium, 512); err != nil {						
				log.Println(err.Error())
			} else {
				sEnc := base64.StdEncoding.EncodeToString(png)					 
				dataWS, _ := json.Marshal(QrcodeMSG{From:"server",To:machine.Username,Data:sEnc})
				if err := conn.WriteMessage(websocket.TextMessage, []byte(dataWS)); err != nil {					
					log.Println(err)
				}										
			}
		}
		if qmsg.Data == "refresh" {
			/* --- cari dulu --- */
			if database.DB.Where("username = ?", qmsg.From).First(&machine).Error != nil {								
				if err := conn.WriteMessage(websocket.TextMessage, []byte("Username Tidak Di temukan")); err != nil {
					log.Println(err)               	
				}	
				log.Println("Username Tidak Di temukan")
				return
			}

			/* --- Update Secret dulu --- */
			machine.Secret = SecretGen(20)

			if err := database.DB.Save(&machine).Error; err != nil {				
				if err := conn.WriteMessage(websocket.TextMessage, []byte(err.Error())); err != nil {
					log.Println(err)               	
				}	
				log.Println(err) 
			}

			/* --- Tampilkan Secret Terbaru --- */			
			JsonQR, _ := json.Marshal(Qencode{Username:machine.Username,Secret:machine.Secret})			
			if png, err := qrcode.Encode(string(JsonQR), qrcode.Medium, 512); err != nil {						
				log.Println(err.Error())
			} else {
				sEnc := base64.StdEncoding.EncodeToString(png)					 				
				dataWS, _ := json.Marshal(QrcodeMSG{From:"server",To:machine.Username,Data:sEnc})
				if err := conn.WriteMessage(websocket.TextMessage, []byte(dataWS)); err != nil {
					log.Println(err)					
				}										
			}		
		}
	}
}

/* --- Genereator secret fungsi ---*/
func StringWithCharset(length int, charset string) string {
	b := make([]byte, length)
	for i := range b {
	  b[i] = charset[seededRand.Intn(len(charset))]
	}
	return string(b)
}

func SecretGen(length int) string {
	return StringWithCharset(length, charset)
}
  
/* --- Struct ---*/
type Qencode struct {
	Username 	string		`json:"username"`
	Secret 		string		`json:"secret"`
}
type QrcodeMSG struct {
	From 	string		`json:"from"`
	To 		string		`json:"to"`
	Data 	string		`json:"data"`	
}