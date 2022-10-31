package routes

import (
	"../controllers"	
	"github.com/gin-gonic/contrib/static"
	"github.com/gin-gonic/gin"	
)

func InitRouter() *gin.Engine {		
	router := gin.New()
	/* --- websocket service --- */		
	go h.run()	
	//router.Use(gin.Logger())	
	/* --- Set a lower memory limit for multipart forms (default is 32 MiB) ---*/ 
	router.MaxMultipartMemory = 8 << 20 // 8 MiB
	/* --- Release Mode ---*/ 
	// gin.SetMode(gin.ReleaseMode)
	/* --- Public ---*/ 
	router.Use(static.Serve("/", static.LocalFile("./public", true)))	
	/* --- Controller ---*/
	WebsocketX := new(controllers.WebsocketX)
	Mobile := new(controllers.Mobile)
	Machine := new(controllers.Machine)	
	Absensi := new(controllers.Absensi)
	// Rekap := new(controllers.Rekap)		
	// Pegawai := new(controllers.Pegawai)
	/* ---- login ---*/
	router.POST("/login/mobile", Mobile.LoginHandler)
	router.POST("/login/machine", Machine.LoginHandler)
	/* --- Mobile Api ---*/
	mobileApi := router.Group("/api/mobile")
	mobileApi.Use(Mobile.AuthMiddle)
	{		
		mobileApi.GET("/absensi", Absensi.Index)		
		mobileApi.POST("/absensi/masuk", Absensi.Masuk)
		mobileApi.POST("/absensi/pulang", Absensi.Pulang)
		// mobileApi.GET("/pegawai/user/:username", Pegawai.Index)
	}			
	/* --- absensi Api ---*/
	// absenApi := router.Group("/api/machine")
	// absenApi.Use(Machine.AuthMiddle)
	// {
	// 	absenApi.GET("/qrcode", Machine.QRcode)	
	// }
	/* --- Websocket ---*/
	router.Use(WebsocketX.AuthMiddleQrcode).GET("/websocket/:channelId",func(c *gin.Context) {
		channelId := (*c).Param("channelId")
		serveWs((*c).Writer, (*c).Request, channelId)
	})
	go QRreader()
	/* --- End Websocket ---*/ 	
	/* ---- DATA storage ---*/
	// router.Use(static.Serve("/storage", static.LocalFile("./storage", true)))
	return router
}