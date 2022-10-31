package database

import (
	"fmt"	

	"../config"
	"../models"
	_ "github.com/go-sql-driver/mysql"
	"github.com/jinzhu/gorm"		
	"database/sql"		
)

var DB *gorm.DB

func InitDB() (*gorm.DB, error) {
	conf := config.Get()
	// create database if not exits
	dbCreate, err2 := sql.Open("mysql", conf.UsernameDB+":"+conf.PasswordDB+"@tcp("+conf.HostDB+")/?charset=utf8&parseTime=True&loc=Local")
	if err2 != nil {		
		fmt.Println("Koneksi Database Tak Tersambung :", err2)
	}
	defer dbCreate.Close()
	_,err3 := dbCreate.Exec("CREATE DATABASE IF NOT EXISTS "+conf.NamaDB)
	if err3 != nil {		
		fmt.Println("Koneksi Database Tak Tersambung ! :", err3)
	}
	// end create database if not exits
	db, err := gorm.Open("mysql", conf.UsernameDB+":"+conf.PasswordDB+"@tcp("+conf.HostDB+")/"+conf.NamaDB+"?charset=utf8&parseTime=True&loc=Local")
	// debug
	// db.LogMode(true)	
	// Error
	if err == nil {
		db.DB().SetMaxIdleConns(500)
		DB = db
		// migrate
		db.AutoMigrate(&models.Absen{}, &models.Machine{}, &models.Pegawai{})		
		db.Model(models.Absen{}).AddForeignKey("machine_id", "machines(id)", "CASCADE", "CASCADE")	
		db.Model(models.Absen{}).AddForeignKey("pegawai_id", "pegawais(id)", "SET NULL", "SET NULL")		
		// end migrate
		return db, err

	}

	return nil, err
}
