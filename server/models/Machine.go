package models


type Machine struct {
	Model
	Nama  			string	 `gorm:"type:varchar(300);not null;default:''" json:"nama,omitempty"`
	Secret  		string	 `gorm:"type:varchar(22);not null;default:''" json:"secret,omitempty"`
	Username  		string	 `gorm:"type:varchar(30);unique_index" json:"username,omitempty"`
	Password  		string	 `gorm:"type:varchar(300);not null;default:''" json:"password,omitempty"`	
	ExpiredToken  	int64	 `json:"expired_token,omitempty"`
}