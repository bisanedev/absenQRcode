package models

import "time"

type Model struct {	
	ID        uint 			`gorm:"primary_key" json:"id"`
	CreatedAt time.Time 	`json:"created_at,omitempty"`
	UpdatedAt time.Time		`json:"updated_at,omitempty"`		
}