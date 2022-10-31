package controllers

import (
	"fmt"
	"net/http"
	"../config"
	"../database"
	"../models"
	"github.com/gin-gonic/gin"
	jwt "github.com/dgrijalva/jwt-go"
)

type WebsocketX struct {
	Basic
}

/*--- AuthMiddleware --- */
func (a *WebsocketX) AuthMiddleQrcode(c *gin.Context) {

	var kuery Kuery
	var machine models.Machine
	
	if (*c).ShouldBind(&kuery) == nil {	
		/*--- Verifikasi Token Mesin --- */
		if kuery.Tipe == "machine" {
			tokenMachine, err := jwt.Parse(kuery.Token, func(token *jwt.Token) (interface{}, error) {
				if jwt.GetSigningMethod("HS256") != token.Method {
					return nil, fmt.Errorf("Unexpected signing method: %v", token.Header["alg"])
				}
		
				return []byte(config.Get().SignatureJWT), nil
			})	
			if err != nil {			
				(*c).JSON(http.StatusUnauthorized, nil)
				(*c).Abort()
				return
			}				
			/* --- cek token timeunix & device_id --- */
			claims := tokenMachine.Claims.(jwt.MapClaims)
			if errs := database.DB.Where("expired_token = ?", claims["expired_token"]).Where("username = ?", claims["username"]).First(&machine).Error; errs != nil {				
				(*c).JSON(http.StatusUnauthorized, nil)
				(*c).Abort()
				return
			}					
		/*--- End Verifikasi Token Mesin --- */
		} else if kuery.Tipe == "server" {
			if kuery.Token != config.Get().TokenWebsocket {
				(*c).JSON(http.StatusUnauthorized, nil)
				(*c).Abort()
				return
			}			
		/*--- Verifikasi Token server --- */
		/*--- END Verifikasi Token server --- */
		} else {
			(*c).JSON(http.StatusUnauthorized, nil)
			(*c).Abort()
			return	
		}					
	} else {
	/*--- Jika Token dan tipe Tidak Di Temukan --- */		
		(*c).JSON(http.StatusUnauthorized, nil)
		(*c).Abort()
		return	
	}
}

func (a *WebsocketX) AuthMiddleMobile(c *gin.Context) {

	var kuery Kuery
	var pegawai models.Pegawai

	if (*c).ShouldBind(&kuery) == nil {	
		if kuery.Tipe == "mobile" {
			/*--- Verifikasi Token mobile --- */		
				tokenMobile, err := jwt.Parse(kuery.Token, func(token *jwt.Token) (interface{}, error) {
					if jwt.GetSigningMethod("HS256") != token.Method {
						return nil, fmt.Errorf("Unexpected signing method: %v", token.Header["alg"])
					}
			
					return []byte(config.Get().SignatureJWT), nil
				})	
				if err != nil {				
					(*c).JSON(http.StatusUnauthorized, nil)
					(*c).Abort()
					return
				}				
				/* --- cek token timeunix & device_id --- */
				claims := tokenMobile.Claims.(jwt.MapClaims)
				if errs := database.DB.Where("expired_token = ?", claims["expired_token"]).Where("username = ?", claims["username"]).First(&pegawai).Error; errs != nil {				
					(*c).JSON(http.StatusUnauthorized, nil)
					(*c).Abort()
					return
				}
			/*--- End Verifikasi Token mobile --- */
		} else {
			(*c).JSON(http.StatusUnauthorized, nil)
			(*c).Abort()
			return	
		}	
	}
}

type Kuery struct {
	Tipe     string    	`form:"tipe" json:"tipe" binding:"required"`
	Token  	 string    	`form:"token" json:"token" binding:"required"`	
}