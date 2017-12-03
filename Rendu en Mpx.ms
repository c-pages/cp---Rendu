/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################
	
	HD et LD
	
##########################################################################################################################
	Permet de passer la taille du MPX en 20 mega pixels (HD ) ou 10 mega pixels (LD)
	
##########################################################################################################################
	changelog:
	*v0.1 - [19/10/2016] -----------------------------------------------------------------------------
########################################################################################################################*/

-- (

	
include "$userScripts\cp - GLOBAL\UI.ms"

------------------------------------------------------------------------------
----------	dragger une fenetre 					--------------------------
------------------------------------------------------------------------------
struct str_drag (
	
	m_prt, 
	
	posOrigineSouris 		= [0,0],
	posOrigineFenetre 	= [0,0],
	enCours 				= false,
	
	fn demarrer 	=(
		enCours 				= true
		posOrigineSouris		= mouse.screenpos 
		posOrigineFenetre 	= GetDialogPos 	m_prt
	),
	fn arreter  	=(
		enCours 				= false
	),
	fn suivreSouris 	 	=(
		if enCours  do (			
			local ecart = ( mouse.screenpos  - posOrigineSouris )
			SetDialogPos  m_prt	( posOrigineFenetre + ecart )
		)
	)
	
) -- fin struct drag --

------------------------------------------------------------------------------
----------	Fenetre								 -------------------------
------------------------------------------------------------------------------
rollout roll_MPX "MPX" width:136 height:70
(
	------------  Membres	----------------------------------------------------------------------------------
	---- Pointeurs ----
	local m_prt				---- pointeur vers la structure de controle ----
	
	---- Structures ----
	local m_drag			---- la structure gerant le drag de la fenetre ----
	
	--- ctro des imgtags ---
	local m_titre
	local m_log
	
	--- liste des btns pour toggle ----
	local m_btns
	
	--- pour savoir si action utilisateur ou ecouteurs ---
	local m_actionEnCours = false
	
	------------  UI	----------------------------------------------------------------------------------		
	---- le bouton pour fermer la fenetre ----
	ImgTag 'ui_btnFermer' "X" pos:[116,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left
	
	checkButton 'btn_20' "20" pos:[8,23] width:20 height:20 align:#left
	checkButton 'btn_15' "15" pos:[28,23] width:20 height:20 align:#left
	checkButton 'btn_10' "10" pos:[48,23] width:20 height:20 align:#left
	checkButton 'btn_5' "5" pos:[68,23] width:20 height:20 align:#left
	checkButton 'btn_1' "1" pos:[88,23] width:20 height:20 align:#left
	checkButton 'btn_demi' "0.5" pos:[108,23] width:20 height:20 align:#left
	
	ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
	ImgTag 'ui_log' "" pos:[8,43] width:66 height:18 align:#left

	
	------------  Fonctions	----------------------------------------------------------------------------------
	---- Gere l'état du bouton  -----
	fn etatBtnFermer		_etat =(
		case _etat of (
			#Repos : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
			#Survol : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[2]	
			#Press : 	ui_btnFermer.bitmap = m_prt.m_icos_fermer[3]	
		)
	)
	
	fn toggleBtns  _btn =(
		for btn in m_btns where btn != _btn do	btn.checked = false
		_btn.checked = true
	)
	fn selectBtn _ID =(
		if _ID >0 do 
			if not m_btns[_ID].checked 
				do	toggleBtns m_btns[_ID]
		
	)
	
	fn nbrEnString 	_nombre =(
		local result =""
		_nombre = _nombre as string
		
		local characPos =  mod _nombre.count 3
		
		
		local i
		while _nombre.count > 0 do (
			if characPos > 0 do (
				for i = 1 to characPos do result+= _nombre[i]
				result+= " "
				_nombre = substring _nombre 	(characPos+1) 	_nombre.count
			)
			characPos = 3
		)
		result
	)
	
	fn actualiser = (
		
		selectBtn  ( m_prt.getRenduPixels () )
		
		local txtLog = ""
		txtLog += nbrEnString  ( renderWidth * renderHeight ) + " Mpx."
		txtLog += "§" + "(" + renderWidth as string + " x " + renderHeight as string + " px.)"
		m_log.setTexte txtLog
	)
	
	---- Initialisation de la fenetre  -----
	fn initialiser = (
		m_btns = #( btn_20, btn_15, btn_10, btn_5, btn_1, btn_demi )
		
		m_drag 		= str_drag 	m_prt:roll_MPX		
		
		m_titre 		= str_label 	m_ui:ui_titre			m_texte:"MPX"
		m_titre.setCouleur (color 255	255	255)
		m_titre.setCouleurFond 	m_prt.col_fenetreFond
		
		m_log 		= str_label 	m_ui:ui_log				m_texte:"..."
		m_log.setPolice (str_policePetite())
		m_log.setCouleur (color 200	200	200)
		m_log.setCouleurFond 	m_prt.col_fenetreFond
		
		
		-- le bouton fermer --
		ui_btnFermer.bitmap = m_prt.m_icos_fermer[1]	
		
		actualiser()

	)
	
	
	------------  Evenements	----------------------------------------------------------------------------------
	on roll_MPX lbuttondown _pos 	do
		m_drag.demarrer ()
	on roll_MPX lbuttonup _pos 	do
		m_drag.arreter ()
	on roll_MPX mouseMove _pos 	do
		m_drag.suivreSouris ()
	on ui_btnFermer mouseover do
		etatBtnFermer #Survol
	on ui_btnFermer mouseout do
		etatBtnFermer #Repos
	on ui_btnFermer mouseDown do
		etatBtnFermer #Press
	on ui_btnFermer mouseUp do
		etatBtnFermer #Repos	
	on ui_btnFermer click do
		m_prt.fermer ()
	
	on btn_20 changed state do (
		m_actionEnCours = true
		
		toggleBtns	 btn_20
		m_prt.setTaille 20
		
		actualiser()
		m_actionEnCours = false
	)
	on btn_15 changed state  do(
		m_actionEnCours = true
		
		toggleBtns	 btn_15
		m_prt.setTaille 15
		
		actualiser()
		m_actionEnCours = false
	)
	on btn_10 changed state  do(
		m_actionEnCours = true
		
		toggleBtns	 btn_10
		m_prt.setTaille 10
		
		actualiser()
		m_actionEnCours = false
	)
	on btn_5 changed state  do(
		m_actionEnCours = true
		
		toggleBtns	 btn_5
		m_prt.setTaille 5
		
		actualiser()
		m_actionEnCours = false
	)
	on btn_1 changed state  do(
		m_actionEnCours = true
		
		toggleBtns	 btn_1
		m_prt.setTaille 1
		
		actualiser()
		m_actionEnCours = false
	)
	on btn_demi changed state  do(
		m_actionEnCours = true
		
		toggleBtns	 btn_demi
		m_prt.setTaille 0.5
		
		actualiser()
		m_actionEnCours = false
	)
)

------------------------------------------------------------------------------
----------	Structure								 -------------------------
------------------------------------------------------------------------------
struct str_MPX (
	
		------------  Membres	----------------------------------------------------------------------------------
	public
		---- pointeurs ----
		m_dialog			= roll_MPX ,		---- le rollout ----
		m_dialogPos 	= [1600,100],
		
		col_fenetreFond			= color 68  68 68, 	----  ----
		col_fenetreTxt				= color 230  230 230, 	----  ----
	
		--- images bouton fermer ---
		ico_btnFermer_R	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg",
		ico_btnFermer_S	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg",
		ico_btnFermer_P	=	"$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg",
		
		m_icos_fermer = #( 					---- les images pour les icones du bouton de fermeture ----
									openBitMap ico_btnFermer_R ,		-- Repos ----
									openBitMap ico_btnFermer_S ,		-- Survol ----
									openBitMap ico_btnFermer_P 		-- Pressé ----
								),
		
		--- liste des valeurs des presets ----
		nbrPx_20 	= 20000000,
		nbrPx_15 	= 15000000,
		nbrPx_10 	= 10000000,
		nbrPx_5 		= 	 5000000,
		nbrPx_1 		= 	 1000000,
		nbrPx_demi = 	   500000,
		
		
		---- ecouteurs ----
		m_ecouteur_renderParams ,
		
		
		------------  Fonctions	----------------------------------------------------------------------------------
	public
		
		fn getRenduPixels =(
			local plusProche 	= 0
			if not m_dialog.m_actionEnCours do (
				local nbrPixelsCourant = renderWidth * renderHeight
	-- 			format "nbrPixelsCourant : %\n" nbrPixelsCourant
				local listNbrPx 	=#( nbrPx_20, nbrPx_15, nbrPx_10, nbrPx_5, nbrPx_1 )
				local valMin 		= 1500000000
				for i = 1 to listNbrPx.count do (
					local nbrPix = listNbrPx[i]
					local diff = abs (nbrPix - nbrPixelsCourant)
	-- 				format "diff : %\n" diff
	-- 				format "valMin : %\n" valMin
	-- 				format "diff < valMin  : %\n" (diff < valMin )
					if diff < valMin do (
						valMin = diff
						plusProche = i
					)
				)
-- 	-- 			format "plusProche : %\n" plusProche
			)
			plusProche
		),
		fn actualiser =(		
			m_dialog.actualiser () 	
		),
		fn setTaille		_taille 	=(
						
			local nbrPx_rendu
			
			local	renderRatio = float renderWidth / float renderHeight
			
			local etaitOuvert = renderSceneDialog.isOpen() 
			
			case _taille of (
				20: 		nbrPx_rendu = nbrPx_20
				15: 		nbrPx_rendu = nbrPx_15
				10: 		nbrPx_rendu = nbrPx_10
				5: 		nbrPx_rendu = nbrPx_5
				1: 		nbrPx_rendu = nbrPx_1
				0.5: 		nbrPx_rendu = nbrPx_demi
			)
			
			
			if etaitOuvert do renderSceneDialog.close()	
			
			renderWidth 	= floor ( sqrt ( renderRatio *  nbrPx_rendu ) )
			renderHeight 	= floor ( renderWidth / renderRatio )
			
			if etaitOuvert do renderSceneDialog.open()
			
			[ renderWidth , renderHeight]
		),
		
		---- fenetre -----
		fn ouvrir =(			
			---- creation de la fenetre ----
			createDialog m_dialog 	bgcolor:				col_fenetreFond 	 \
											fgcolor:				col_fenetreTxt 	\
											style:				#(#style_resizing) \
											lockHeight:			true	\
											lockWidth:			true	\
											pos:					m_dialogPos
			
			---- initialisation de la fenetre ----
			m_dialog.m_prt	 	= this
			m_dialog.initialiser ()
			
			---- initialisation des ecouteurs ----
			callbacks.addScript #renderParamsChanged "mgr_MPX.getRenduPixels(); mgr_MPX.actualiser()" id:#CPages_MPX
			
		),
		
		fn fermer  silence:false =(		---- silence : fermer sans modifier l'état des preferences ---
			
			m_dialogPos = getDialogPos m_dialog
			
			---- fermer la fenêtre ----
			try destroydialog m_dialog catch ()
			
			---- suppression des ecouteurs ----
			callbacks.removeScripts #renderParamsChanged  id:#CPages_MPX
		)
		
		------------  Evenements	----------------------------------------------------------------------------------
	
)


-- global mgr_MPX 	=	str_MPX 	()
-- mgr_MPX.ouvrir ()





-- )