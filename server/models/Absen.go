package models

import "time"

type Absen struct {
	ID        		uint64 			`gorm:"primary_key" json:"id"`
	CreatedAt 		time.Time 		`json:"created_at,omitempty"`
	UpdatedAt 		time.Time		`json:"updated_at,omitempty"`	
	PegawaiID 		uint 			`json:"pegawai_id,omitempty"`
	Masuk			time.Time 		`json:"masuk,omitempty"`	
	Pulang 			time.Time 		`json:"pulang,omitempty"`
	MachineID		uint			`gorm:"null" json:"machine_id,omitempty"`		
}