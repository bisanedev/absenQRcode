package controllers

import (
	"net/http"

	// "../database"
	// "../models"
	"github.com/gin-gonic/gin"
)

type Rekap struct {
	Basic
}

/*--- Index --- */
func (a *Rekap) Index(c *gin.Context) {	
	(*a).JsonSuccess(c, http.StatusOK, gin.H{"Test":"Middleware Auth Berhasil"})
}
