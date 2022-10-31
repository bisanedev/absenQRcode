package controllers

import (	
	"time"
	"strconv"
	"net/http"		
	"../database"
	"../models"
	"github.com/biezhi/gorm-paginator/pagination"
	"github.com/gin-gonic/gin"
)

type Absensi struct {
	Basic
}

/*--- Index --- */
func (a *Absensi) Index(c *gin.Context) {

	tanggal := (*c).DefaultQuery("tanggal", "null")
	order := (*c).DefaultQuery("order", "masuk")
	by := (*c).DefaultQuery("by", "desc")	
	page, _ := strconv.Atoi((*c).DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi((*c).DefaultQuery("limit", "3"))
	
	pegawaiID := (*c).MustGet("id")
	var absen []QueryAbsen

	if tanggal == "null" {
	/*--- tampilkan semuanya --- */	
		paginator := pagination.Paging(&pagination.Param{
			DB:      database.DB.Table("absens").Select("absens.id,absens.masuk,absens.pulang,absens.pegawai_id,absens.machine_id,machines.nama as machine_name").Joins("left join machines on machines.id = absens.machine_id").Where("absens.pegawai_id = ?", pegawaiID),
			Page:    page,
			Limit:   limit,
			OrderBy: []string{order + " " + by},
			ShowSQL: false,
		}, &absen)
		(*c).JSON(200, paginator)		
	} else {
	/*--- tampilkan berdasarkan Waktu --- */
		loc, _ := time.LoadLocation("Asia/Jakarta")
		tgl, _ := time.ParseInLocation("2006-01-02", tanggal, loc)
		paginator := pagination.Paging(&pagination.Param{
			DB:      database.DB.Table("absens").Select("absens.id,absens.masuk,absens.pulang,absens.pegawai_id,absens.machine_id,machines.nama as machine_name").Joins("left join machines on machines.id = absens.machine_id").Where("absens.pegawai_id = ?", pegawaiID).Where("DATE(masuk) = ?", tgl),
			Page:    page,
			Limit:   limit,
			OrderBy: []string{order + " " + by},
			ShowSQL: false,
		}, &absen)
		(*c).JSON(200, paginator)
	}	
}

/*--- Masuk --- */
func (a *Absensi) Masuk(c *gin.Context) {

	var (
		request RequestAbsensiMasuk
		machine models.Machine
		absen models.Absen
		count int
	)

	PegawainID := (*c).MustGet("id").(float64)		

	if err := (*c).ShouldBind(&request); err != nil {
	/*--- Kalau Gak ada Post --- */
		(*a).JsonFail(c, http.StatusBadRequest, err.Error())
		return
	}
	/*--- Sudah Absen Apa Belum Hari ini ? --- */	
	database.DB.Where("pegawai_id = ?", uint(PegawainID)).Where("DATE(masuk) = ?", time.Now().Format("2006-01-02")).First(&absen).Count(&count)
	if count > 0 {
		(*a).JsonFail(c, http.StatusBadRequest,"Anda Sudah Absen Masuk Pukul "+absen.Masuk.Format("15:04:05"))
		return			
	}	
	/*--- Cari Username Mesin --- */
	if database.DB.Where("username = ?", request.Machine).Where("secret = ?", request.Secret).First(&machine).Error != nil {														
		(*a).JsonFail(c, http.StatusBadRequest, "Mesin Absensi atau secret Tidak Terverifikasi")
		return			
	}	
	/* --- insert / store Absen --- */
	insert := &models.Absen{
				PegawaiID: uint(PegawainID),
				MachineID: machine.ID,
				Masuk: time.Now(),			
			}
			
	if err := database.DB.Create(&insert).Error; err != nil {
		(*a).JsonFail(c, http.StatusBadRequest, err.Error())
		return
	}
	/* --- Update Secret dulu kirim perintah --- */
	(*a).SocketSendQRcode(QrcodeMSG{From:machine.Username,To:"server",Data:"refresh"})
	(*a).JsonSuccess(c, http.StatusCreated, gin.H{"message": "Absensi Masuk Sukses"})		
}

/*--- Pulang --- */
func (a *Absensi) Pulang(c *gin.Context) {
	
	var (
		request RequestAbsensiPulang
		machine models.Machine
		absen models.Absen		
	)

	PegawainID := (*c).MustGet("id").(float64)		

	if err := (*c).ShouldBind(&request); err != nil {
	/*--- Kalau Gak ada Post --- */
		(*a).JsonFail(c, http.StatusBadRequest, err.Error())
		return
	}
	/*--- Sudah Absen Apa Belum Hari ini ? --- */	
	database.DB.Where("id = ?", request.AbsenID).Where("pegawai_id = ?", uint(PegawainID)).First(&absen)
	if absen.Pulang.IsZero() == false  {
		(*a).JsonFail(c, http.StatusBadRequest,"Anda Sudah Absen Pulang Pukul "+absen.Pulang.Format("15:04:05"))
		return			
	}	
	/*--- Cari Username Mesin --- */
	if database.DB.Where("id = ?", absen.MachineID).Where("username = ?", request.Machine).Where("secret = ?", request.Secret).First(&machine).Error != nil {														
		(*a).JsonFail(c, http.StatusBadRequest, "Mesin Absensi atau secret Tidak Terverifikasi")
		return			
	}	
	/* --- Update Absen Pulang --- */	
	absen.Pulang = time.Now()

	if err := database.DB.Save(&absen).Error; err != nil {
		(*a).JsonFail(c, http.StatusUnauthorized, err.Error())
		return
	}	

	/* --- Update Secret dulu kirim perintah --- */
	(*a).SocketSendQRcode(QrcodeMSG{From:machine.Username,To:"server",Data:"refresh"})
	(*a).JsonSuccess(c, http.StatusCreated, gin.H{"message": "Absensi Pulang Sukses"})	
}

type QueryAbsen struct {
	ID        		uint64 			`json:"id"`			
	Masuk			time.Time 		`json:"masuk,omitempty"`	
	Pulang 			time.Time 		`json:"pulang,omitempty"`
	PegawaiID 		uint 			`json:"pegawai_id,omitempty"`
	MachineID		uint			`json:"machine_id,omitempty"`	
	MachineName		string			`json:"machine_name,omitempty"`
}

type RequestAbsensiMasuk struct {
	Machine 			string 	`form:"machine" json:"machine" binding:"required"`
	Secret 				string 	`form:"secret" json:"secret" binding:"required"`	
}

type RequestAbsensiPulang struct {
	Machine 			string 	`form:"machine" json:"machine" binding:"required"`
	Secret 				string 	`form:"secret" json:"secret" binding:"required"`	
	AbsenID   			string 	`form:"absensi_id" json:"absensi_id" binding:"required"`
}