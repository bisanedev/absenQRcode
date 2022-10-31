package controllers

import (
	"os"	
	"log"
	"fmt"			
	"net/http"
	"time"
	"strings"
	"../config"
	"../database"
	"../models"
	"github.com/gin-gonic/gin"
	"golang.org/x/crypto/bcrypt"	
	jwt "github.com/dgrijalva/jwt-go"	
)

type Machine struct {
	Basic	
}

func (Machine) AuthMiddle(c *gin.Context) {
	var machine models.Machine
	/* --- log file --- */
	f, err := os.OpenFile("./logs/machine_access", os.O_RDWR | os.O_CREATE | os.O_APPEND, 0666)
	if err != nil {
    	log.Fatalf("error opening file: %v", err)
	}
	defer f.Close()
	log.SetOutput(f)
	/* --- cek JWT token --- */
	reqToken := (*c).Request.Header.Get("Authorization")
	if reqToken != "" {
		/* --- cek CRSF Token --- */
		CRSF := (*c).Request.Header.Get("CRSF")
		ClientIPAddr := (*c).ClientIP() 
		
		if CRSF != config.Get().HeaderCSRF {			
			log.Println("IP Address:",ClientIPAddr,"=> Penggunaan Aplikasi Ilegal !!!!")		
			result := gin.H{
				"message": "not authorized",
				"error":   "Token tidak benar",
			}
			(*c).JSON(http.StatusUnauthorized, result)
			(*c).Abort()
			return
		}
		
		/* --- END cek CRSF Token --- */
		splitToken := strings.Split(reqToken, " ")
		/* --- Jika Token tidak diawali Bearer --- */
		if splitToken[0] != "Bearer" {		
			result := gin.H{
				"message": "not authorized",
				"error":   "Token tidak benar",
			}
			(*c).JSON(http.StatusUnauthorized, result)
			(*c).Abort()
			return		
		}
		/* --- set token & decode jwt --- */
		tokenString := splitToken[1]
		
		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			if jwt.GetSigningMethod("HS256") != token.Method {
				return nil, fmt.Errorf("Unexpected signing method: %v", token.Header["alg"])
			}
	
			return []byte(config.Get().SignatureJWT), nil
		})
	
		/* --- cek Authorization --- */
		if token != nil && err == nil {		
			/* --- cek token timeunix & device_id --- */
			claims := token.Claims.(jwt.MapClaims)
			if errs := database.DB.Where("expired_token = ?", claims["expired_token"]).Where("username = ?", claims["username"]).First(&machine).Error; errs != nil {
				result := gin.H{
					"message": "not authorized",
					"error":   "Token tidak diketahui",
				}
				(*c).JSON(http.StatusUnauthorized, result)
				(*c).Abort()
				return
			} else {
				/* --- AUTH middleware Jika Berhasil --- */
				(*c).Set("username", claims["username"])
				(*c).Set("id", claims["id"])
				// fmt.Println("Token User:", machine.Username, "Telah Mengakses")
			}
	
		} else {
			/* --- Jika Authorization Kosong --- */
			result := gin.H{
				"message": "not authorized",
				"error":   err.Error(),
			}
			(*c).JSON(http.StatusUnauthorized, result)
			(*c).Abort()
			return
		}
	}else{
		result := gin.H{
			"message": "not authorized",
			"error":   "Authorization Kosong",
		}
		(*c).JSON(http.StatusUnauthorized, result)
		(*c).Abort()
		return
	}
}

func (a *Machine) LoginHandler(c *gin.Context) {
	var machine models.Machine
	var request CredentialMachine
	var unixExpired int64

	if err := (*c).ShouldBind(&request); err != nil {
		(*a).JsonFail(c, http.StatusUnauthorized, "Silahkan Periksa Kembali Input Data !")
		return
	}
	/* set variable */
	unixExpired = time.Now().AddDate(2, 0, 0).Unix()
	

	if database.DB.Where("username = ?", request.Username).First(&machine).Error != nil {
		(*a).JsonFail(c, http.StatusUnauthorized, "Maaf Username Tidak Di Ketahui")
		return
	}

	/* --- Comparing the password with the hash --- */
	if err := bcrypt.CompareHashAndPassword([]byte(machine.Password), []byte(request.Password)); err != nil {			
		(*a).JsonFail(c, http.StatusUnauthorized, "Maaf Password Tidak Di Ketahui")
		return
	}
	
	machine.ExpiredToken = unixExpired

	if err := database.DB.Save(&machine).Error; err != nil {
		(*a).JsonFail(c, http.StatusUnauthorized, err.Error())
		return
	}

	sign := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"id":		 		machine.ID,		
		"username":  		machine.Username,		
		"expired_token": 	unixExpired,
	})

	token, err := (*sign).SignedString([]byte(config.Get().SignatureJWT))

	if err != nil {
		(*a).JsonFail(c, http.StatusUnauthorized, err.Error())
	}

	(*a).JsonSuccess(c, http.StatusOK, gin.H{"message": token})
}

type CredentialMachine struct {
	Username 	string `form:"username" json:"username" binding:"required"`
	Password 	string `form:"password" json:"password" binding:"required"`	
}