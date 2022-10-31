package models


type Pegawai struct {
	Model
	Nama  			string	 `gorm:"type:varchar(300);not null;default:''" json:"nama,omitempty"`	
	Username  		string	 `gorm:"type:varchar(50);unique_index" json:"username,omitempty"`	
	Password  		string	 `gorm:"type:varchar(300);not null;default:''" json:"password,omitempty"`
	DeviceID  		string	 `gorm:"type:varchar(50);unique_index" json:"device_id,omitempty"`
	ExpiredToken  	int64	 `json:"expired_token,omitempty"`
}