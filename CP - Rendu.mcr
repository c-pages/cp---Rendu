/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	HD et LD
	
##########################################################################################################################
	Permet de passer la taille du rendu en 20 mega pixels (HD ) ou 10 mega pixels (LD)
	
##########################################################################################################################
	changelog:
	*v0.1 - [19/10/2016] -----------------------------------------------------------------------------
########################################################################################################################*/
macroScript Rendu
category:"#CPages"
buttonText:"Rendu"
toolTip:"Gestion du rendu (taille, frame rate, denoise Corona...)"
(
	
	global mgr_rendu 
	include "$userScripts\\cp - Rendu\\Rendu.ms"
	mgr_rendu = str_rendu ()
	on execute do 	mgr_rendu.ouvrir ()
)

macroScript Backburner
category:"#CPages"
buttonText:"Backburner"
toolTip:"Envois rendu au backburner"
(
	
	global mgr_backburner
	include "$userScripts\\cp - Rendu\\rendu Backburner.ms"
	mgr_backburner = str_backburner ()
	on execute do 	mgr_backburner.ouvrir ()
)




macroScript RenduEnMpx
category:"#CPages"
buttonText:"Mpx"
toolTip:"Definir taille du rendu en mega pixels."
(
	
	global mgr_MPX
	include "$userScripts\\cp - Rendu\\Rendu en Mpx.ms"
	mgr_MPX = str_MPX ()
	on execute do 	mgr_MPX.ouvrir ()
)


macroScript StartInteractif
category:"#CPages"
buttonText:"Interactif"
toolTip:"Demarrer rendu interactif corona"
(
	if classof renderers.current == CoronaRenderer do CoronaRenderer.startInteractive()
)



macroScript ChangerFrameRate
category:"#CPages"
buttonText:"Frame rate"
toolTip:"Changer le frame rate"
(
	
	global mgr_frameRate 
	include "$userScripts\\cp - Rendu\\frameRate.ms"
	mgr_frameRate 	=	str_frameRate 	()
	on execute do 	mgr_frameRate.ouvrir ()
	
	
)
